class ResponsePair {
  final String from;
  final String to;
  final int count;

  const ResponsePair({required this.from, required this.to, required this.count});
}

class ChatSilence {
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final String lastSenderBefore;
  final String firstSenderAfter;

  const ChatSilence({
    required this.start,
    required this.end,
    required this.duration,
    required this.lastSenderBefore,
    required this.firstSenderAfter,
  });
}

class ParticipantResponseTime {
  final String name;
  final Duration avgResponseTime;
  final int responsesCount;

  const ParticipantResponseTime({
    required this.name,
    required this.avgResponseTime,
    required this.responsesCount,
  });
}

class ConversationThread {
  final DateTime start;
  final DateTime end;
  final int messageCount;
  final List<String> participants;

  const ConversationThread({
    required this.start,
    required this.end,
    required this.messageCount,
    required this.participants,
  });

  Duration get duration => end.difference(start);
}

class ConversationDynamics {
  final Map<String, int> initiators;
  final List<ResponsePair> responseRates;
  final ConversationThread? longestThread;
  final Map<String, int> consecutiveMax;
  final int totalDays;
  final ChatSilence? longestSilence;
  final List<ParticipantResponseTime> responseTimes;

  const ConversationDynamics({
    required this.initiators,
    required this.responseRates,
    required this.longestThread,
    required this.consecutiveMax,
    required this.totalDays,
    this.longestSilence,
    this.responseTimes = const [],
  });

  static ConversationDynamics empty() => const ConversationDynamics(
    initiators: {},
    responseRates: [],
    longestThread: null,
    consecutiveMax: {},
    totalDays: 0,
    longestSilence: null,
    responseTimes: [],
  );

  static ConversationDynamics process(List<Map<String, dynamic>> stream) {
    if (stream.isEmpty) return empty();

    final initiators = <String, int>{};
    final responseMatrix = <String, Map<String, int>>{};
    final consecutiveMax = <String, int>{};
    final userResponseGaps = <String, List<int>>{};

    int maxGapMs = 0;
    int silenceStartIndex = -1;

    String? prevSender;
    int currentStreak = 0;
    String? streakSender;

    // Longest thread tracking
    ConversationThread? longestThread;

    final DateTime firstMsgTime = DateTime.fromMillisecondsSinceEpoch(
      stream.first['timestamp'] as int,
    );
    final DateTime lastMsgTime = DateTime.fromMillisecondsSinceEpoch(
      stream.last['timestamp'] as int,
    );
    final totalDays = lastMsgTime.difference(firstMsgTime).inDays + 1;

    // Track first message per day for initiators
    final seenDays = <String, bool>{};

    for (int i = 0; i < stream.length; i++) {
      final row = stream[i];
      final sender = row['sender'] as String;
      final ts = row['timestamp'] as int;
      final dt = DateTime.fromMillisecondsSinceEpoch(ts);
      final dayKey = '${dt.year}-${dt.month}-${dt.day}';

      // Initiator: first message of each day
      if (seenDays[dayKey] != true) {
        seenDays[dayKey] = true;
        initiators[sender] = (initiators[sender] ?? 0) + 1;
      }

      if (i > 0) {
        final prevTs = stream[i - 1]['timestamp'] as int;
        final gapMs = ts - prevTs;

        // Longest silence tracking
        if (gapMs > maxGapMs) {
          maxGapMs = gapMs;
          silenceStartIndex = i - 1;
        }

        // Response time tracking (gaps under 24 hours between different senders)
        if (prevSender != null && prevSender != sender && gapMs > 0 && gapMs <= 86400000) {
          userResponseGaps.putIfAbsent(sender, () => []);
          userResponseGaps[sender]!.add(gapMs);
        }
      }

      // Response matrix
      if (prevSender != null && prevSender != sender) {
        responseMatrix.putIfAbsent(prevSender, () => {});
        responseMatrix[prevSender]![sender] =
            (responseMatrix[prevSender]![sender] ?? 0) + 1;
      }

      // Consecutive messages
      if (sender == streakSender) {
        currentStreak++;
      } else {
        streakSender = sender;
        currentStreak = 1;
      }
      final prevMax = consecutiveMax[sender] ?? 0;
      if (currentStreak > prevMax) {
        consecutiveMax[sender] = currentStreak;
      }

      prevSender = sender;
    }

    // Longest silence object
    ChatSilence? longestSilence;
    if (silenceStartIndex >= 0 && maxGapMs > 0) {
      longestSilence = ChatSilence(
        start: DateTime.fromMillisecondsSinceEpoch(
          stream[silenceStartIndex]['timestamp'] as int,
        ),
        end: DateTime.fromMillisecondsSinceEpoch(
          stream[silenceStartIndex + 1]['timestamp'] as int,
        ),
        duration: Duration(milliseconds: maxGapMs),
        lastSenderBefore: stream[silenceStartIndex]['sender'] as String,
        firstSenderAfter: stream[silenceStartIndex + 1]['sender'] as String,
      );
    }

    // Response times per user (sorted fastest to slowest)
    final responseTimes = <ParticipantResponseTime>[];
    userResponseGaps.forEach((user, gaps) {
      if (gaps.isNotEmpty) {
        final totalMs = gaps.reduce((a, b) => a + b);
        final avgMs = (totalMs / gaps.length).round();
        responseTimes.add(
          ParticipantResponseTime(
            name: user,
            avgResponseTime: Duration(milliseconds: avgMs),
            responsesCount: gaps.length,
          ),
        );
      }
    });
    responseTimes.sort((a, b) => a.avgResponseTime.compareTo(b.avgResponseTime));

    // Find longest conversation thread (gap > 1 hour)
    if (stream.length >= 2) {
      int threadStart = 0;
      int bestStart = 0;
      int bestCount = 1;

      for (int i = 1; i < stream.length; i++) {
        final prevTs = stream[i - 1]['timestamp'] as int;
        final currTs = stream[i]['timestamp'] as int;
        final gapMs = currTs - prevTs;

        if (gapMs > 3600000) {
          // Gap > 1 hour: end current thread, start new one
          final threadCount = i - threadStart;
          if (threadCount > bestCount) {
            bestCount = threadCount;
            bestStart = threadStart;
          }
          threadStart = i;
        }
      }
      // Check last thread
      final lastThreadCount = stream.length - threadStart;
      if (lastThreadCount > bestCount) {
        bestCount = lastThreadCount;
        bestStart = threadStart;
      }

      if (bestCount > 1) {
        final startTs = stream[bestStart]['timestamp'] as int;
        final endTs = stream[bestStart + bestCount - 1]['timestamp'] as int;
        final participants = <String>{};
        for (int i = bestStart; i < bestStart + bestCount; i++) {
          participants.add(stream[i]['sender'] as String);
        }
        longestThread = ConversationThread(
          start: DateTime.fromMillisecondsSinceEpoch(startTs),
          end: DateTime.fromMillisecondsSinceEpoch(endTs),
          messageCount: bestCount,
          participants: participants.toList()..sort(),
        );
      }
    }

    // Sort response rates
    final responseList = <ResponsePair>[];
    responseMatrix.forEach((from, toMap) {
      toMap.forEach((to, count) {
        responseList.add(ResponsePair(from: from, to: to, count: count));
      });
    });
    responseList.sort((a, b) => b.count.compareTo(a.count));

    return ConversationDynamics(
      initiators: initiators,
      responseRates: responseList,
      longestThread: longestThread,
      consecutiveMax: consecutiveMax,
      totalDays: totalDays,
      longestSilence: longestSilence,
      responseTimes: responseTimes,
    );
  }
}
