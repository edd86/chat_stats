import 'package:flutter_test/flutter_test.dart';
import 'package:chat_stats/features/chat_import/utils/whatsapp_parser.dart';
import 'package:chat_stats/features/chat_dashboard/domain/models/message_analysis.dart';
import 'package:chat_stats/features/chat_dashboard/domain/models/conversation_dynamics.dart';

void main() {
  group('WhatsAppParser Unit Tests', () {
    test(
      'extractChatTitle extracts room title after "Chat de WhatsApp con"',
      () {
        const fileName =
            'Chat de WhatsApp con En este grupo no se Admiten Ronalds 😅.txt';
        final title = WhatsAppParser.extractChatTitle(fileName);
        expect(title, equals('En este grupo no se Admiten Ronalds 😅'));
      },
    );

    test('extractChatTitle falls back to clean filename when no prefix', () {
      const fileName = 'Mi Grupo Familiar.txt';
      final title = WhatsAppParser.extractChatTitle(fileName);
      expect(title, equals('Mi Grupo Familiar'));
    });

    test(
      'parseChatContent accurately parses messages, senders, system events and media',
      () async {
        const sampleText = '''
3/7/24 14:31 - Los mensajes y las llamadas están cifrados de extremo a extremo.
3/7/24 14:31 - Creaste este grupo
3/7/24 14:32 - EdDⓈ: Buenas tardes chicos en este grupo estamos los q contratamos el servicio de Disney plus...
3/7/24 14:34 - Amael Vargas: Ok, administrador
3/7/24 14:35 - EdDⓈ: <Multimedia omitido>
3/7/24 14:51 - Daniel Torres: me agrada el nombre del grupo <Se editó este mensaje.>
''';

        final result = await WhatsAppParser.parseChatContent(
          rawFileName: 'Chat de WhatsApp con Disney Group.txt',
          fileContent: sampleText,
        );

        expect(result.chat.name, equals('Disney Group'));
        expect(result.chat.totalMessages, equals(6));
        expect(result.chat.totalMedia, equals(1));
        expect(result.participants.length, equals(3));

        // EdDⓈ sent 2 messages (1 media)
        final edd = result.participants.firstWhere((p) => p.name == 'EdDⓈ');
        expect(edd.messageCount, equals(2));
        expect(edd.mediaCount, equals(1));

        // System messages
        final systemMessages = result.messages
            .where((m) => m.isSystem)
            .toList();
        expect(systemMessages.length, equals(2));

        // Edited message check
        final editedMsg = result.messages.firstWhere((m) => m.isEdited);
        expect(editedMsg.sender, equals('Daniel Torres'));
      },
    );

    test(
      'parseChatContent and MessageAnalysis correctly process mentions with bidi control characters',
      () async {
        const sampleText = '''
7/9/26 12:28 - Papa: Hola a todos
7/9/26 12:28 - Mama: Hola hijo
7/9/26 12:29 - EdD🧐: @\u2068Papa\u2069 @\u2068Mama\u2069
''';

        final result = await WhatsAppParser.parseChatContent(
          rawFileName: 'Chat de WhatsApp con Familia.txt',
          fileContent: sampleText,
        );

        final messagesMap = result.messages
            .map(
              (m) => {
                'sender': m.sender,
                'content': m.content,
                'char_count': m.charCount,
                'is_deleted': m.isDeleted ? 1 : 0,
                'is_media': m.isMedia ? 1 : 0,
              },
            )
            .toList();

        final analysis = MessageAnalysis.process(messagesMap, [], []);

        final eddParticipant = analysis.participants.firstWhere(
          (p) => p.name == 'EdD🧐',
        );
        expect(eddParticipant.mentionsCount, equals(2));
        expect(analysis.mentionsReceived['Papa'], equals(1));
        expect(analysis.mentionsReceived['Mama'], equals(1));
      },
    );

    test('parseChatContent supports iOS bracket format [date, time]', () async {
      const sampleText = '''
[3/7/24, 14:31:05] Maria: Hola chicos
[3/7/24, 14:32:10] Juan: Hola Maria, ¿cómo estás?
''';

      final result = await WhatsAppParser.parseChatContent(
        rawFileName: '_chat.txt',
        fileContent: sampleText,
      );

      expect(result.messages.length, equals(2));
      expect(result.participants.length, equals(2));
      expect(
        result.participants.map((p) => p.name),
        containsAll(['Maria', 'Juan']),
      );
      expect(WhatsAppParser.isValidWhatsAppChat(result), isTrue);
    });

    test('isValidWhatsAppChat returns false for non-chat text files', () async {
      const sampleText = '''
This is a shopping list:
- Apples
- Bananas
- Milk
''';

      final result = await WhatsAppParser.parseChatContent(
        rawFileName: 'notes.txt',
        fileContent: sampleText,
      );

      expect(result.messages.isEmpty, isTrue);
      expect(WhatsAppParser.isValidWhatsAppChat(result), isFalse);
    });

    test(
      'isValidWhatsAppChat returns false for generic logs without senders or WhatsApp system messages',
      () async {
        const sampleText = '''
01/01/2024, 12:00 - Database connection established
01/01/2024, 12:01 - Server listening on port 8080
''';

        final result = await WhatsAppParser.parseChatContent(
          rawFileName: 'server_log.txt',
          fileContent: sampleText,
        );

        expect(result.messages.length, equals(2));
        expect(result.participants.isEmpty, isTrue);
        expect(WhatsAppParser.isValidWhatsAppChat(result), isFalse);
      },
    );

    test(
      'isValidWhatsAppChat returns true for chat with WhatsApp encryption system message',
      () async {
        const sampleText = '''
03/07/2024, 14:31 - Los mensajes y las llamadas están cifrados de extremo a extremo.
''';

        final result = await WhatsAppParser.parseChatContent(
          rawFileName: 'Chat de WhatsApp con Test.txt',
          fileContent: sampleText,
        );

        expect(result.messages.length, equals(1));
        expect(WhatsAppParser.isValidWhatsAppChat(result), isTrue);
      },
    );

    test('parseChatContent handles US date format MM/DD/YY accurately', () async {
      const sampleText = '''
04/28/24, 10:15 - Alice: Hello from US locale format!
04/28/24, 10:16 - Bob: Hey Alice!
''';

      final result = await WhatsAppParser.parseChatContent(
        rawFileName: 'WhatsApp Chat with Alice.txt',
        fileContent: sampleText,
      );

      expect(result.messages.length, equals(2));
      final dt = DateTime.fromMillisecondsSinceEpoch(result.messages.first.timestamp);
      expect(dt.month, equals(4));
      expect(dt.day, equals(28));
    });

    test('ConversationDynamics correctly calculates streaks', () {
      final baseTs = DateTime(2024, 1, 1).millisecondsSinceEpoch;
      final day2Ts = DateTime(2024, 1, 2).millisecondsSinceEpoch;
      final day3Ts = DateTime(2024, 1, 3).millisecondsSinceEpoch;
      final day5Ts = DateTime(2024, 1, 5).millisecondsSinceEpoch;

      final stream = [
        {'sender': 'Alice', 'timestamp': baseTs, 'content': 'Day 1'},
        {'sender': 'Bob', 'timestamp': day2Ts, 'content': 'Day 2'},
        {'sender': 'Alice', 'timestamp': day3Ts, 'content': 'Day 3'},
        {'sender': 'Bob', 'timestamp': day5Ts, 'content': 'Day 5'},
      ];

      final dynamics = ConversationDynamics.process(stream);
      expect(dynamics.longestStreakDays, equals(3));
      expect(dynamics.currentStreakDays, equals(1));
    });

    test('MessageAnalysis correctly tracks night messages (El Noctámbulo)', () {
      final nightTs = DateTime(2024, 1, 1, 3, 30).millisecondsSinceEpoch; // 03:30 AM
      final dayTs = DateTime(2024, 1, 1, 14, 0).millisecondsSinceEpoch; // 02:00 PM

      final messages = [
        {
          'sender': 'Búho',
          'content': 'Despierto a las 3:30',
          'char_count': 20,
          'is_deleted': 0,
          'is_media': 0,
          'timestamp': nightTs,
        },
        {
          'sender': 'Alondra',
          'content': 'Buenas tardes',
          'char_count': 13,
          'is_deleted': 0,
          'is_media': 0,
          'timestamp': dayTs,
        },
      ];

      final analysis = MessageAnalysis.process(messages, [], []);
      expect(analysis.totalNightMessages, equals(1));
      expect(analysis.nightMessagesByPerson['Búho'], equals(1));

      final buho = analysis.participants.firstWhere((p) => p.name == 'Búho');
      expect(buho.nightMessagesCount, equals(1));
    });
  });
}
