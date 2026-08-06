class ParticipantModel {
  final int? id;
  final int chatId;
  final String name;
  final int messageCount;
  final int mediaCount;
  final int wordCount;

  const ParticipantModel({
    this.id,
    required this.chatId,
    required this.name,
    required this.messageCount,
    required this.mediaCount,
    required this.wordCount,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'chat_id': chatId,
      'name': name,
      'message_count': messageCount,
      'media_count': mediaCount,
      'word_count': wordCount,
    };
  }

  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    return ParticipantModel(
      id: map['id'] as int?,
      chatId: map['chat_id'] as int,
      name: map['name'] as String,
      messageCount: map['message_count'] as int,
      mediaCount: map['media_count'] as int,
      wordCount: map['word_count'] as int,
    );
  }
}
