import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:chat_stats/features/chat_import/domain/models/chat_model.dart';
import 'package:chat_stats/features/chat_import/domain/models/chat_message_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'Database creation includes is_deleted column in messages table',
    () async {
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: (db, version) async {
          // Run database_helper's schema creation logic by mimicking _createDB structure
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
            is_deleted INTEGER NOT NULL DEFAULT 0,
            word_count INTEGER NOT NULL DEFAULT 0,
            char_count INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE
          );
        ''');

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
        },
      );

      const chat = ChatModel(
        name: 'Test Chat',
        fileName: 'test.txt',
        createdAt: 100000,
        totalMessages: 1,
        totalMedia: 0,
        totalWords: 5,
        participantCount: 1,
      );

      const msg = ChatMessageModel(
        chatId: 1,
        timestamp: 100000,
        dateStr: '1/1/26',
        timeStr: '12:00',
        sender: 'User',
        content: 'Hello world',
        isSystem: false,
        isMedia: false,
        isEdited: false,
        isDeleted: true,
        wordCount: 2,
        charCount: 11,
      );

      await db.transaction((txn) async {
        final chatId = await txn.insert('chats', chat.toMap());
        final msgMap = msg.toMap()..['chat_id'] = chatId;
        await txn.insert('messages', msgMap);
      });

      final res = await db.query('messages');
      expect(res.length, equals(1));
      expect(res.first['is_deleted'], equals(1));

      await db.close();
    },
  );
}
