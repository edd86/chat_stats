class MessageWord {
  final String word;
  final int count;

  const MessageWord({required this.word, required this.count});
}

class MessageEmoji {
  final String emoji;
  final int count;

  const MessageEmoji({required this.emoji, required this.count});
}

class ParticipantAnalysis {
  final String name;
  final double avgChars;
  final int longestMsg;
  final String longestPreview;
  final int shortestMsg;
  final int editedCount;
  final int deletedCount;
  final int textCount;
  final int mediaCount;
  final double textPct;
  final double mediaPct;
  final List<MessageEmoji> topEmojis;

  const ParticipantAnalysis({
    required this.name,
    required this.avgChars,
    required this.longestMsg,
    required this.longestPreview,
    required this.shortestMsg,
    required this.editedCount,
    required this.deletedCount,
    required this.textCount,
    required this.mediaCount,
    required this.textPct,
    required this.mediaPct,
    required this.topEmojis,
  });
}

class MessageAnalysis {
  final List<MessageWord> topWords;
  final List<MessageEmoji> topEmojisGeneral;
  final Map<String, List<MessageEmoji>> topEmojisByPerson;
  final List<ParticipantAnalysis> participants;
  final int uniqueWordsCount;
  final int totalEdited;
  final int totalDeleted;

  const MessageAnalysis({
    required this.topWords,
    required this.topEmojisGeneral,
    required this.topEmojisByPerson,
    required this.participants,
    required this.uniqueWordsCount,
    required this.totalEdited,
    required this.totalDeleted,
  });

  static MessageAnalysis empty() => const MessageAnalysis(
    topWords: [],
    topEmojisGeneral: [],
    topEmojisByPerson: {},
    participants: [],
    uniqueWordsCount: 0,
    totalEdited: 0,
    totalDeleted: 0,
  );

  static MessageAnalysis process(
    List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>> editedStats,
    List<Map<String, dynamic>> contentStats,
  ) {
    if (messages.isEmpty) return empty();

    // --- Word frequency ---
    const stopWords = {
      // Media/system
      'multimedia', 'omitido', 'omitted', 'media', 'foto', 'omitida',
      'video', 'audio', 'documento', 'sticker', 'estíquer', 'adjunto',
      'mensaje', 'editó', 'eliminó', 'borró', 'deleted', 'edited',
      'this', 'was',

      // Conjunctions/prepositions
      'que', 'los', 'del', 'las', 'por', 'con', 'para', 'una', 'un',
      'como', 'pero', 'mas', 'más', 'sin', 'sus', 'son', 'nos',

      // Demonstratives
      'este', 'esta', 'estos', 'estas', 'ese', 'esa', 'esos', 'esas',
      'aquel', 'aquella', 'aquellos', 'aquellas',

      // Personal pronouns
      'yo', 'tú', 'él', 'ella', 'usted', 'nosotros', 'vosotros',
      'ellos', 'ellas', 'ustedes',

      // Object pronouns
      'me', 'te', 'se', 'lo', 'la', 'le', 'les',

      // Possessive pronouns
      'mío', 'mía', 'tuyo', 'tuya', 'suyo', 'suya',
      'nuestro', 'nuestra', 'vuestro', 'vuestra',

      // Adverbs
      'muy', 'poco', 'nada', 'mucho', 'siempre', 'nunca', 'antes',
      'después', 'aquí', 'allí', 'ahí', 'ahora', 'hoy', 'ayer',
      'mañana', 'también', 'tampoco', 'solo', 'apenas', 'quizás',
      'bien', 'mal', 'así', 'entonces', 'todavía', 'ya',
    };

    final laughPattern = RegExp(r'^(ja|je|ji|ju|ha|he|hi)+$');

    final wordCount = <String, int>{};
    final emojiPattern = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE00}-\u{FE0F}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{200D}\u{20E3}\u{FE0F}\u{2000}-\u{206F}]',
      unicode: true,
    );
    final wordCleanPattern = RegExp(r"[^\w\sáéíóúñü']|[_']");
    final emojiCountGeneral = <String, int>{};
    final emojiCountByPerson = <String, Map<String, int>>{};

    // Per-participant data accumulators
    final Map<String, List<int>> charCounts = {};
    final Map<String, int> longestMsg = {};
    final Map<String, String> longestPreview = {};
    final Map<String, int> shortestMsg = {};
    final Map<String, int> deletedCount = {};

    for (final row in messages) {
      final sender = row['sender'] as String;
      final content = row['content'] as String;
      final charCount = row['char_count'] as int;
      final isDeleted = (row['is_deleted'] as int?) == 1;

      // Words
      final cleaned = content.replaceAll(wordCleanPattern, '').toLowerCase();
      final words = cleaned
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 2 && !stopWords.contains(w) && !laughPattern.hasMatch(w));
      for (final w in words) {
        wordCount[w] = (wordCount[w] ?? 0) + 1;
      }

      // Emojis - extract individual emojis
      final emojis = emojiPattern.allMatches(content).map((m) => m.group(0)!);
      for (final emoji in emojis) {
        emojiCountGeneral[emoji] = (emojiCountGeneral[emoji] ?? 0) + 1;
        emojiCountByPerson.putIfAbsent(sender, () => {});
        emojiCountByPerson[sender]![emoji] =
            (emojiCountByPerson[sender]![emoji] ?? 0) + 1;
      }

      // Per-participant char analysis
      charCounts.putIfAbsent(sender, () => []);
      charCounts[sender]!.add(charCount);

      if (!longestMsg.containsKey(sender) || charCount > longestMsg[sender]!) {
        longestMsg[sender] = charCount;
        final preview = content.length > 50
            ? '${content.substring(0, 50)}...'
            : content;
        longestPreview[sender] = preview;
      }
      if (!shortestMsg.containsKey(sender) ||
          charCount < shortestMsg[sender]!) {
        shortestMsg[sender] = charCount;
      }

      if (isDeleted) {
        deletedCount[sender] = (deletedCount[sender] ?? 0) + 1;
      }
    }

    // Sort words
    final sortedWords = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topWords = sortedWords
        .take(10)
        .map((e) => MessageWord(word: e.key, count: e.value))
        .toList();

    // Sort emojis general
    final sortedEmojis = emojiCountGeneral.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmojisGeneral = sortedEmojis
        .take(5)
        .map((e) => MessageEmoji(emoji: e.key, count: e.value))
        .toList();

    // Sort emojis by person
    final topEmojisByPerson = <String, List<MessageEmoji>>{};
    emojiCountByPerson.forEach((person, emojiMap) {
      final sorted = emojiMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topEmojisByPerson[person] = sorted
          .take(5)
          .map((e) => MessageEmoji(emoji: e.key, count: e.value))
          .toList();
    });

    // Edited stats map
    final editedMap = <String, int>{};
    for (final row in editedStats) {
      editedMap[row['sender'] as String] = row['count'] as int;
    }

    // Content stats map
    final contentMap = <String, Map<String, int>>{};
    for (final row in contentStats) {
      contentMap[row['sender'] as String] = {
        'media_count': row['media_count'] as int,
        'text_count': row['text_count'] as int,
        'total': row['total'] as int,
      };
    }

    // Build participant analysis
    final participantList = <ParticipantAnalysis>[];
    for (final sender in charCounts.keys) {
      final counts = charCounts[sender]!;
      final avg = counts.isNotEmpty
          ? counts.reduce((a, b) => a + b) / counts.length
          : 0.0;
      final contentData = contentMap[sender];
      final total = contentData?['total'] ?? 1;
      final mediaCount = contentData?['media_count'] ?? 0;
      final textCount = contentData?['text_count'] ?? 0;

      participantList.add(
        ParticipantAnalysis(
          name: sender,
          avgChars: avg,
          longestMsg: longestMsg[sender] ?? 0,
          longestPreview: longestPreview[sender] ?? '',
          shortestMsg: shortestMsg[sender] ?? 0,
          editedCount: editedMap[sender] ?? 0,
          deletedCount: deletedCount[sender] ?? 0,
          textCount: textCount,
          mediaCount: mediaCount,
          textPct: total > 0 ? textCount / total * 100 : 0,
          mediaPct: total > 0 ? mediaCount / total * 100 : 0,
          topEmojis: topEmojisByPerson[sender] ?? [],
        ),
      );
    }
    participantList.sort(
      (a, b) => (b.textCount + b.mediaCount) - (a.textCount + a.mediaCount),
    );

    final totalEdited = editedMap.values.fold(0, (s, v) => s + v);
    final totalDeleted = deletedCount.values.fold(0, (s, v) => s + v);

    return MessageAnalysis(
      topWords: topWords,
      topEmojisGeneral: topEmojisGeneral,
      topEmojisByPerson: topEmojisByPerson,
      participants: participantList,
      uniqueWordsCount: wordCount.length,
      totalEdited: totalEdited,
      totalDeleted: totalDeleted,
    );
  }
}
