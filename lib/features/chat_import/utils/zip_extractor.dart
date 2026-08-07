import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';

class ExtractedChatContent {
  final String fileName;
  final String fileContent;

  const ExtractedChatContent({
    required this.fileName,
    required this.fileContent,
  });
}

class ZipExtractor {
  /// Extracts text content from a file (which may be a .zip archive or a direct .txt file).
  static Future<ExtractedChatContent> extractChatContent({
    required Uint8List bytes,
    required String rawFileName,
  }) async {
    final bool isZip = _isZipFile(bytes, rawFileName);

    if (!isZip) {
      final String content = _decodeUtf8(bytes);
      return ExtractedChatContent(
        fileName: rawFileName,
        fileContent: content,
      );
    }

    // Decode zip archive
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw FormatException('El archivo .zip está dañado o no es válido: $e');
    }

    ArchiveFile? chatTxtFile;

    // Search for the WhatsApp .txt file in the archive
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final nameLower = file.name.toLowerCase();
      if (nameLower.endsWith('.txt')) {
        // Prioritize "Chat de WhatsApp" or "_chat.txt" files if there are multiple text files
        if (chatTxtFile == null ||
            nameLower.contains('chat de whatsapp') ||
            nameLower.contains('_chat')) {
          chatTxtFile = file;
        }
      }
    }

    if (chatTxtFile == null) {
      throw const FormatException(
        'No se encontró ningún archivo de chat .txt dentro del archivo .zip.',
      );
    }

    final List<int> contentBytes = chatTxtFile.content as List<int>;
    final String content = _decodeUtf8(Uint8List.fromList(contentBytes));
    
    // Extract basename if the entry had directory prefix
    String entryName = chatTxtFile.name;
    if (entryName.contains('/')) {
      entryName = entryName.split('/').last;
    } else if (entryName.contains('\\')) {
      entryName = entryName.split('\\').last;
    }

    return ExtractedChatContent(
      fileName: entryName.isNotEmpty ? entryName : rawFileName,
      fileContent: content,
    );
  }

  /// Helper to extract chat content directly from a file path.
  static Future<ExtractedChatContent> extractFromFilePath(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('El archivo no existe: $filePath');
    }
    final bytes = await file.readAsBytes();
    final fileName = filePath.split(Platform.pathSeparator).last;
    return extractChatContent(bytes: bytes, rawFileName: fileName);
  }

  static bool _isZipFile(Uint8List bytes, String fileName) {
    if (fileName.toLowerCase().endsWith('.zip')) {
      return true;
    }
    // Check for PK magic bytes header: 0x50 0x4B 0x03 0x04
    if (bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        bytes[2] == 0x03 &&
        bytes[3] == 0x04) {
      return true;
    }
    return false;
  }

  static String _decodeUtf8(Uint8List bytes) {
    String content = utf8.decode(bytes, allowMalformed: true);
    // Strip UTF-8 BOM if present
    if (content.startsWith('\uFEFF')) {
      content = content.substring(1);
    }
    return content;
  }
}
