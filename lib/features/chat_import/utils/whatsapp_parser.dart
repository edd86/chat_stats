import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/models/chat_model.dart';
import '../domain/models/chat_message_model.dart';
import '../domain/models/participant_model.dart';

class ParsedChatResult {
  final ChatModel chat;
  final List<ChatMessageModel> messages;
  final List<ParticipantModel> participants;

  const ParsedChatResult({
    required this.chat,
    required this.messages,
    required this.participants,
  });
}

class WhatsAppParser {
  // Regex for WhatsApp line start (Android / Standard format): "Date, Time - Body" or "Date Time - Body"
  // Supports formats:
  // "3/7/24 14:31 - ..."
  // "03/07/2024, 14:31 - ..."
  // "3/7/24, 2:31 p.m. - ..."
  static final RegExp _androidLineRegex = RegExp(
    r'^(\d{1,2}\/\d{1,2}\/\d{2,4})[,\s]+(\d{1,2}:\d{2}(?::\d{2})?(?:\s*[aApP]\.?\s*[mM]\.?)?)\s*-\s*(.+)$',
  );

  // Regex for WhatsApp line start (iOS format): "[Date, Time] Body" or "[Date, Time] - Body"
  // Supports formats:
  // "[03/07/2024, 14:31:00] ..."
  // "[3/7/24, 2:31:00 p. m.] ..."
  static final RegExp _iosLineRegex = RegExp(
    r'^\[(\d{1,2}\/\d{1,2}\/\d{2,4})[,\s]+(\d{1,2}:\d{2}(?::\d{2})?(?:\s*[aApP]\.?\s*[mM]\.?)?)\]\s*(?:-\s*)?(.+)$',
  );

  // Invisible bidi and control characters used by WhatsApp (e.g. U+2068 FSI, U+2069 PDI, U+200E, U+200F)
  static final RegExp _bidiRegex = RegExp(
    r'[\u200e\u200f\u202a-\u202e\u2066-\u2069\u200b\ufeff]',
  );

  /// Checks if a message text corresponds to a recognized WhatsApp system message.
  static bool isWhatsAppSystemMessage(String text) {
    final lower = text.toLowerCase();
    return lower.contains('cifrad') ||
        lower.contains('encrypt') ||
        lower.contains('creaste') ||
        lower.contains('creó') ||
        lower.contains('created') ||
        lower.contains('grupo') ||
        lower.contains('group') ||
        lower.contains('añadió') ||
        lower.contains('added') ||
        lower.contains('cambió') ||
        lower.contains('changed') ||
        lower.contains('eliminó') ||
        lower.contains('deleted') ||
        lower.contains('salió') ||
        lower.contains('left') ||
        lower.contains('seguridad') ||
        lower.contains('security') ||
        lower.contains('llamada') ||
        lower.contains('call');
  }

  /// Determines whether the parsed chat corresponds to a legitimate WhatsApp chat.
  static bool isValidWhatsAppChat(ParsedChatResult parsed) {
    if (parsed.messages.isEmpty) return false;
    // If it has participants who sent messages, it's a valid chat
    if (parsed.participants.isNotEmpty) return true;
    // Or if it only contains valid WhatsApp system events
    return parsed.messages.any((m) => isWhatsAppSystemMessage(m.content));
  }

  /// Extract chat title from file name
  /// e.g., "Chat de WhatsApp con En este grupo no se Admiten Ronalds 😅.txt" -> "En este grupo no se Admiten Ronalds 😅"
  static String extractChatTitle(String rawFileName) {
    String cleanName = rawFileName
        .replaceAll(RegExp(r'\.txt$', caseSensitive: false), '')
        .replaceAll(_bidiRegex, '')
        .trim();

    final prefixMatch = RegExp(
      r'^(?:Chat de WhatsApp con|WhatsApp Chat with|Chat de WhatsApp|WhatsApp Chat)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(cleanName);
    if (prefixMatch != null && prefixMatch.group(1) != null) {
      return prefixMatch.group(1)!.trim();
    }
    return cleanName;
  }

  /// Parses raw text content of a WhatsApp chat file asynchronously
  static Future<ParsedChatResult> parseChatContent({
    required String rawFileName,
    required String fileContent,
  }) async {
    return compute(_parseInBackground, {
      'fileName': rawFileName,
      'content': fileContent,
    });
  }

  static ParsedChatResult _parseInBackground(Map<String, String> data) {
    final fileName = data['fileName']!;
    final content = data['content']!;
    final chatTitle = extractChatTitle(fileName);

    final lines = const LineSplitter().convert(content);

    final List<_RawMessage> rawMessages = [];
    _RawMessage? currentMsg;

    for (final line in lines) {
      final sanitizedLine = line.replaceAll(_bidiRegex, '');
      final match =
          _androidLineRegex.firstMatch(sanitizedLine) ??
          _iosLineRegex.firstMatch(sanitizedLine);
      if (match != null) {
        if (currentMsg != null) {
          rawMessages.add(currentMsg);
        }
        currentMsg = _RawMessage(
          dateStr: match.group(1)!.trim(),
          timeStr: match.group(2)!.trim(),
          body: match.group(3)!.trim(),
        );
      } else if (currentMsg != null) {
        // Multi-line continuation
        currentMsg.body = '${currentMsg.body}\n$sanitizedLine';
      }
    }
    if (currentMsg != null) {
      rawMessages.add(currentMsg);
    }

    final List<ChatMessageModel> messages = [];
    final Map<String, _ParticipantStats> participantMap = {};

    int totalMedia = 0;
    int totalWords = 0;
    int? firstTimestamp;
    int? lastTimestamp;

    for (final raw in rawMessages) {
      final parsedBody = _parseMessageBody(raw.body);
      final timestamp = _parseDateTimeToTimestamp(raw.dateStr, raw.timeStr);

      if (firstTimestamp == null || timestamp < firstTimestamp) {
        firstTimestamp = timestamp;
      }
      if (lastTimestamp == null || timestamp > lastTimestamp) {
        lastTimestamp = timestamp;
      }

      final wordCount = _calculateWordCount(parsedBody.content);
      totalWords += wordCount;

      if (parsedBody.isMedia) {
        totalMedia++;
      }

      if (!parsedBody.isSystem && parsedBody.sender.isNotEmpty) {
        final pStats = participantMap.putIfAbsent(
          parsedBody.sender,
          () => _ParticipantStats(name: parsedBody.sender),
        );
        pStats.messageCount++;
        pStats.wordCount += wordCount;
        if (parsedBody.isMedia) {
          pStats.mediaCount++;
        }
      }

      messages.add(
        ChatMessageModel(
          chatId: 0, // Assigned upon DB insert
          timestamp: timestamp,
          dateStr: raw.dateStr,
          timeStr: raw.timeStr,
          sender: parsedBody.sender,
          content: parsedBody.content,
          isSystem: parsedBody.isSystem,
          isMedia: parsedBody.isMedia,
          isEdited: parsedBody.isEdited,
          isDeleted: parsedBody.isDeleted,
          wordCount: wordCount,
          charCount: parsedBody.content.length,
        ),
      );
    }

    final List<ParticipantModel> participants =
        participantMap.values
            .map(
              (p) => ParticipantModel(
                chatId: 0,
                name: p.name,
                messageCount: p.messageCount,
                mediaCount: p.mediaCount,
                wordCount: p.wordCount,
              ),
            )
            .toList()
          ..sort((a, b) => b.messageCount.compareTo(a.messageCount));

    final chat = ChatModel(
      name: chatTitle,
      fileName: fileName,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      totalMessages: messages.length,
      totalMedia: totalMedia,
      totalWords: totalWords,
      participantCount: participants.length,
      firstMessageTime: firstTimestamp,
      lastMessageTime: lastTimestamp,
    );

    return ParsedChatResult(
      chat: chat,
      messages: messages,
      participants: participants,
    );
  }

  static _ParsedBody _parseMessageBody(String body) {
    // Check if sender exists e.g. "Sender Name: Message text"
    final colonIndex = body.indexOf(': ');
    if (colonIndex != -1) {
      final sender = body.substring(0, colonIndex).trim();
      final content = body.substring(colonIndex + 2).trim();

      final isMedia = _checkIsMedia(content);
      final isEdited = _checkIsEdited(content);
      final isDeleted = _checkIsDeleted(content);

      return _ParsedBody(
        sender: sender,
        content: content,
        isSystem: false,
        isMedia: isMedia,
        isEdited: isEdited,
        isDeleted: isDeleted,
      );
    } else {
      // System message
      return _ParsedBody(
        sender: 'Sistema',
        content: body,
        isSystem: true,
        isMedia: false,
        isEdited: false,
        isDeleted: false,
      );
    }
  }

  static bool _checkIsMedia(String text) {
    final lower = text.toLowerCase();
    return lower.contains('<multimedia omitido>') ||
        lower.contains('<media omitted>') ||
        lower.contains('<foto omitida>') ||
        lower.contains('<video omitido>') ||
        lower.contains('<audio omitido>') ||
        lower.contains('<documento omitido>');
  }

  static bool _checkIsEdited(String text) {
    final lower = text.toLowerCase();
    return lower.contains('<se editó este mensaje.>') ||
        lower.contains('<this message was edited>');
  }

  static bool _checkIsDeleted(String text) {
    final lower = text.toLowerCase();
    return lower.contains('se eliminó este mensaje.') ||
        lower.contains('<este mensaje fue eliminado>') ||
        lower.contains('<se borró este mensaje>') ||
        lower.contains('<this message was deleted>');
  }

  static int _calculateWordCount(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  static int _parseDateTimeToTimestamp(String dateStr, String timeStr) {
    try {
      final dateParts = dateStr.split('/');
      if (dateParts.length == 3) {
        int day = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int year = int.parse(dateParts[2]);
        if (year < 100) {
          year += 2000;
        }

        // Clean time string e.g. "14:31" or "2:31 p.m."
        int hour = 0;
        int minute = 0;

        final cleanTime = timeStr.replaceAll(RegExp(r'[^\d:]'), '').trim();
        final timeParts = cleanTime.split(':');
        if (timeParts.length >= 2) {
          hour = int.parse(timeParts[0]);
          minute = int.parse(timeParts[1]);

          final lowerTime = timeStr.toLowerCase();
          if (lowerTime.contains('p') && hour < 12) {
            hour += 12;
          } else if (lowerTime.contains('a') && hour == 12) {
            hour = 0;
          }
        }

        return DateTime(year, month, day, hour, minute).millisecondsSinceEpoch;
      }
    } catch (_) {
      // Fallback
    }
    return DateTime.now().millisecondsSinceEpoch;
  }
}

class _RawMessage {
  final String dateStr;
  final String timeStr;
  String body;

  _RawMessage({
    required this.dateStr,
    required this.timeStr,
    required this.body,
  });
}

class _ParsedBody {
  final String sender;
  final String content;
  final bool isSystem;
  final bool isMedia;
  final bool isEdited;
  final bool isDeleted;

  _ParsedBody({
    required this.sender,
    required this.content,
    required this.isSystem,
    required this.isMedia,
    required this.isEdited,
    required this.isDeleted,
  });
}

class _ParticipantStats {
  final String name;
  int messageCount = 0;
  int mediaCount = 0;
  int wordCount = 0;

  _ParticipantStats({required this.name});
}
