class ChatMessageModel {
  final int? id;
  final int chatId;
  final int timestamp; // Unix Epoch MS
  final String dateStr;
  final String timeStr;
  final String sender;
  final String content;
  final bool isSystem;
  final bool isMedia;
  final bool isEdited;
  final bool isDeleted;
  final int wordCount;
  final int charCount;

  const ChatMessageModel({
    this.id,
    required this.chatId,
    required this.timestamp,
    required this.dateStr,
    required this.timeStr,
    required this.sender,
    required this.content,
    required this.isSystem,
    required this.isMedia,
    required this.isEdited,
    required this.isDeleted,
    required this.wordCount,
    required this.charCount,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'chat_id': chatId,
      'timestamp': timestamp,
      'date_str': dateStr,
      'time_str': timeStr,
      'sender': sender,
      'content': content,
      'is_system': isSystem ? 1 : 0,
      'is_media': isMedia ? 1 : 0,
      'is_edited': isEdited ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'word_count': wordCount,
      'char_count': charCount,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as int?,
      chatId: map['chat_id'] as int,
      timestamp: map['timestamp'] as int,
      dateStr: map['date_str'] as String,
      timeStr: map['time_str'] as String,
      sender: map['sender'] as String,
      content: map['content'] as String,
      isSystem: (map['is_system'] as int) == 1,
      isMedia: (map['is_media'] as int) == 1,
      isEdited: (map['is_edited'] as int) == 1,
      isDeleted: (map['is_deleted'] as int?) == 1,
      wordCount: map['word_count'] as int,
      charCount: map['char_count'] as int,
    );
  }
}
