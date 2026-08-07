import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:chat_stats/features/chat_import/utils/zip_extractor.dart';

void main() {
  group('ZipExtractor Unit Tests', () {
    test('extracts raw .txt file content correctly', () async {
      const sampleText = '3/7/24 14:32 - User: Hola mundo';
      final bytes = Uint8List.fromList(utf8.encode(sampleText));

      final extracted = await ZipExtractor.extractChatContent(
        bytes: bytes,
        rawFileName: 'chat.txt',
      );

      expect(extracted.fileName, equals('chat.txt'));
      expect(extracted.fileContent, equals(sampleText));
    });

    test('extracts .txt file from a .zip archive', () async {
      const chatContent = '3/7/24 14:32 - User: Mensaje en zip';
      final archive = Archive();
      final contentBytes = utf8.encode(chatContent);
      archive.addFile(
        ArchiveFile(
          'Chat de WhatsApp con En este grupo no se Admiten Ronalds.txt',
          contentBytes.length,
          contentBytes,
        ),
      );

      final zipBytes = ZipEncoder().encode(archive);
      expect(zipBytes, isNotNull);

      final extracted = await ZipExtractor.extractChatContent(
        bytes: Uint8List.fromList(zipBytes),
        rawFileName: 'ExportedChat.zip',
      );

      expect(
        extracted.fileName,
        equals('Chat de WhatsApp con En este grupo no se Admiten Ronalds.txt'),
      );
      expect(extracted.fileContent, equals(chatContent));
    });

    test('throws FormatException if .zip has no .txt file inside', () async {
      final archive = Archive();
      final contentBytes = utf8.encode('dummy image data');
      archive.addFile(
        ArchiveFile('image.png', contentBytes.length, contentBytes),
      );

      final zipBytes = ZipEncoder().encode(archive);
      expect(zipBytes, isNotNull);

      expect(
        () async => await ZipExtractor.extractChatContent(
          bytes: Uint8List.fromList(zipBytes),
          rawFileName: 'EmptyChat.zip',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
