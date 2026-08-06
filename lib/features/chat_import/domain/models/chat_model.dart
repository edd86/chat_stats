class ChatModel {
  final int? id;
  final String name;
  final String fileName;
  final int createdAt;
  final int totalMessages;
  final int totalMedia;
  final int totalWords;
  final int participantCount;
  final int? firstMessageTime;
  final int? lastMessageTime;

  const ChatModel({
    this.id,
    required this.name,
    required this.fileName,
    required this.createdAt,
    required this.totalMessages,
    required this.totalMedia,
    required this.totalWords,
    required this.participantCount,
    this.firstMessageTime,
    this.lastMessageTime,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'file_name': fileName,
      'created_at': createdAt,
      'total_messages': totalMessages,
      'total_media': totalMedia,
      'total_words': totalWords,
      'participant_count': participantCount,
      'first_message_time': firstMessageTime,
      'last_message_time': lastMessageTime,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      fileName: map['file_name'] as String,
      createdAt: map['created_at'] as int,
      totalMessages: map['total_messages'] as int,
      totalMedia: map['total_media'] as int,
      totalWords: map['total_words'] as int,
      participantCount: map['participant_count'] as int,
      firstMessageTime: map['first_message_time'] as int?,
      lastMessageTime: map['last_message_time'] as int?,
    );
  }
}
