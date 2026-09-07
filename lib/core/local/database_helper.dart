import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../features/chat_import/domain/models/chat_model.dart';
import '../../features/chat_import/domain/models/chat_message_model.dart';
import '../../features/chat_import/domain/models/participant_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat_stats.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError('Web SQLite is not supported in this version.');
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onOpen(Database db) async {
    // Clean up any previously orphaned records if chats were deleted before foreign keys were active
    await db.execute(
      'DELETE FROM messages WHERE chat_id NOT IN (SELECT id FROM chats)',
    );
    await db.execute(
      'DELETE FROM participants WHERE chat_id NOT IN (SELECT id FROM chats)',
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Chats Table
    await db.execute('''
      CREATE TABLE chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        file_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        total_messages INTEGER NOT NULL,
        total_media INTEGER NOT NULL,
        total_words INTEGER NOT NULL,
        participant_count INTEGER NOT NULL,
        first_message_time INTEGER,
        last_message_time INTEGER
      );
    ''');

    // 2. Messages Table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        date_str TEXT NOT NULL,
        time_str TEXT NOT NULL,
        sender TEXT NOT NULL,
        content TEXT NOT NULL,
        is_system INTEGER NOT NULL DEFAULT 0,
        is_media INTEGER NOT NULL DEFAULT 0,
        is_edited INTEGER NOT NULL DEFAULT 0,
        word_count INTEGER NOT NULL DEFAULT 0,
        char_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE
      );
    ''');

    // 3. Participants Table
    await db.execute('''
      CREATE TABLE participants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        message_count INTEGER NOT NULL,
        media_count INTEGER NOT NULL,
        word_count INTEGER NOT NULL,
        FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE
      );
    ''');

    // 4. Create SQLite Performance Indices
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(chat_id, timestamp);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(chat_id, sender);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_messages_system_media ON messages(chat_id, is_system, is_media);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_participants_chat ON participants(chat_id);',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE messages ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  // --- Database Operations ---

  // Save a new chat with all its messages & participants in a single fast transaction
  Future<int> insertFullChat({
    required ChatModel chat,
    required List<ChatMessageModel> messages,
    required List<ParticipantModel> participants,
  }) async {
    final db = await instance.database;

    return await db.transaction((txn) async {
      final chatId = await txn.insert('chats', chat.toMap());

      final messageBatch = txn.batch();
      for (final msg in messages) {
        final msgMap = msg.toMap()..['chat_id'] = chatId;
        messageBatch.insert('messages', msgMap);
      }
      await messageBatch.commit(noResult: true);

      final participantBatch = txn.batch();
      for (final p in participants) {
        final pMap = p.toMap()..['chat_id'] = chatId;
        participantBatch.insert('participants', pMap);
      }
      await participantBatch.commit(noResult: true);

      return chatId;
    });
  }

  Future<List<ChatModel>> getAllChats() async {
    final db = await instance.database;
    final result = await db.query('chats', orderBy: 'created_at DESC');
    return result.map((json) => ChatModel.fromMap(json)).toList();
  }

  Future<ChatModel?> getChatById(int id) async {
    final db = await instance.database;
    final result = await db.query('chats', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return ChatModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<ParticipantModel>> getParticipantsByChatId(int chatId) async {
    final db = await instance.database;
    final result = await db.query(
      'participants',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'message_count DESC',
    );
    return result.map((json) => ParticipantModel.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getDailyActivity(int chatId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT date_str, COUNT(*) as count 
      FROM messages 
      WHERE chat_id = ? AND is_system = 0
      GROUP BY date_str 
      ORDER BY timestamp ASC
    ''',
      [chatId],
    );
  }

  Future<Map<String, dynamic>?> getActiveDayRecord(int chatId) async {
    final db = await instance.database;
    final res = await db.rawQuery(
      '''
      SELECT date_str, COUNT(*) as count 
      FROM messages 
      WHERE chat_id = ? AND is_system = 0
      GROUP BY date_str 
      ORDER BY count DESC 
      LIMIT 1
    ''',
      [chatId],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getHourlyDistribution(int chatId) async {
    final db = await instance.database;
    // Extract hour from time_str (HH:mm format)
    return await db.rawQuery(
      '''
      SELECT SUBSTR(time_str, 1, 2) as hour, COUNT(*) as count
      FROM messages
      WHERE chat_id = ? AND is_system = 0
      GROUP BY hour
      ORDER BY hour ASC
    ''',
      [chatId],
    );
  }

  Future<List<Map<String, dynamic>>> getActivityHeatmap(int chatId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT 
        CAST(strftime('%w', timestamp / 1000, 'unixepoch', 'localtime') AS INTEGER) as day_of_week,
        CAST(strftime('%H', timestamp / 1000, 'unixepoch', 'localtime') AS INTEGER) as hour,
        COUNT(*) as count
      FROM messages
      WHERE chat_id = ? AND is_system = 0
      GROUP BY day_of_week, hour
    ''',
      [chatId],
    );
  }

  Future<List<ChatMessageModel>> searchMessages(
    int chatId,
    String query,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'messages',
      where: 'chat_id = ? AND content LIKE ?',
      whereArgs: [chatId, '%$query%'],
      orderBy: 'timestamp DESC',
      limit: 100,
    );
    return result.map((json) => ChatMessageModel.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getConversationStream(int chatId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT timestamp, sender, content
      FROM messages
      WHERE chat_id = ? AND is_system = 0
      ORDER BY timestamp ASC
    ''',
      [chatId],
    );
  }

  Future<List<Map<String, dynamic>>> getMessagesForAnalysis(int chatId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT sender, content, char_count, is_media, is_edited, is_deleted
      FROM messages
      WHERE chat_id = ? AND is_system = 0
      ORDER BY timestamp ASC
    ''',
      [chatId],
    );
  }

  Future<List<Map<String, dynamic>>> getEditedStats(int chatId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT sender, COUNT(*) as count
      FROM messages
      WHERE chat_id = ? AND is_system = 0 AND is_edited = 1
      GROUP BY sender
      ORDER BY count DESC
    ''',
      [chatId],
    );
  }

  Future<List<Map<String, dynamic>>> getContentStats(int chatId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT sender,
        SUM(CASE WHEN is_media = 1 THEN 1 ELSE 0 END) as media_count,
        SUM(CASE WHEN is_media = 0 THEN 1 ELSE 0 END) as text_count,
        COUNT(*) as total
      FROM messages
      WHERE chat_id = ? AND is_system = 0
      GROUP BY sender
      ORDER BY total DESC
    ''',
      [chatId],
    );
  }

  Future<int> deleteChat(int chatId) async {
    final db = await instance.database;
    int deleted = 0;
    await db.transaction((txn) async {
      await txn.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
      await txn.delete('participants', where: 'chat_id = ?', whereArgs: [chatId]);
      deleted = await txn.delete('chats', where: 'id = ?', whereArgs: [chatId]);
    });
    try {
      await db.execute('VACUUM');
    } catch (_) {
      // Ignored if concurrent operations prevent VACUUM
    }
    return deleted;
  }
}
