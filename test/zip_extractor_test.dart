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

    test(
      'throws FormatException if non-zip file does not have .txt extension',
      () async {
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        expect(
          () async => await ZipExtractor.extractChatContent(
            bytes: bytes,
            rawFileName: 'presentation.pdf',
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('throws FormatException if .zip file is corrupted', () async {
      // Magic PK header but corrupted data
      final corruptedZipBytes = Uint8List.fromList([
        0x50,
        0x4B,
        0x03,
        0x04,
        0x00,
        0x00,
      ]);

      expect(
        () async => await ZipExtractor.extractChatContent(
          bytes: corruptedZipBytes,
          rawFileName: 'broken.zip',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
