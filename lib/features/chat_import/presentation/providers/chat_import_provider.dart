import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local/database_helper.dart';
import '../../domain/models/chat_model.dart';
import '../../utils/whatsapp_parser.dart';
import '../../utils/zip_extractor.dart';

enum ImportStatus { idle, loading, success, error }

class ChatImportState {
  final ImportStatus status;
  final String? errorMessage;
  final int? importedChatId;

  const ChatImportState({
    this.status = ImportStatus.idle,
    this.errorMessage,
    this.importedChatId,
  });

  ChatImportState copyWith({
    ImportStatus? status,
    String? errorMessage,
    int? importedChatId,
  }) {
    return ChatImportState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      importedChatId: importedChatId ?? this.importedChatId,
    );
  }
}

class ChatImportNotifier extends Notifier<ChatImportState> {
  @override
  ChatImportState build() {
    return const ChatImportState();
  }

  Future<void> pickAndImportChatFile() async {
    try {
      state = state.copyWith(status: ImportStatus.loading, errorMessage: null);

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'zip'],
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(status: ImportStatus.idle);
        return;
      }

      final file = result.files.first;
      final bytes = await file.readAsBytes();

      await _processBytes(bytes: bytes, rawFileName: file.name);
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: 'Error al importar archivo: ${e.toString()}',
      );
    }
  }

  Future<void> importFromPath(String filePath) async {
    try {
      state = state.copyWith(status: ImportStatus.loading, errorMessage: null);

      final extracted = await ZipExtractor.extractFromFilePath(filePath);
      await _processExtracted(extracted);
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: 'Error al procesar archivo compartido: ${e.toString()}',
      );
    }
  }

  Future<void> _processBytes({
    required Uint8List bytes,
    required String rawFileName,
  }) async {
    final extracted = await ZipExtractor.extractChatContent(
      bytes: bytes,
      rawFileName: rawFileName,
    );
    await _processExtracted(extracted);
  }

  Future<void> _processExtracted(ExtractedChatContent extracted) async {
    final parsed = await WhatsAppParser.parseChatContent(
      rawFileName: extracted.fileName,
      fileContent: extracted.fileContent,
    );

    if (parsed.messages.isEmpty) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage:
            'No se encontraron mensajes válidos de WhatsApp en el archivo.',
      );
      return;
    }

    final chatId = await DatabaseHelper.instance.insertFullChat(
      chat: parsed.chat,
      messages: parsed.messages,
      participants: parsed.participants,
    );

    state = state.copyWith(
      status: ImportStatus.success,
      importedChatId: chatId,
    );
  }

  void reset() {
    state = const ChatImportState();
  }
}

final chatImportProvider =
    NotifierProvider<ChatImportNotifier, ChatImportState>(
      ChatImportNotifier.new,
    );

class ChatListNotifier extends AsyncNotifier<List<ChatModel>> {
  @override
  Future<List<ChatModel>> build() async {
    return await DatabaseHelper.instance.getAllChats();
  }

  Future<void> deleteChat(int chatId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await DatabaseHelper.instance.deleteChat(chatId);
      return await DatabaseHelper.instance.getAllChats();
    });
  }

  Future<void> refreshChats() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await DatabaseHelper.instance.getAllChats();
    });
  }
}

final chatListProvider =
    AsyncNotifierProvider.autoDispose<ChatListNotifier, List<ChatModel>>(
      ChatListNotifier.new,
    );
