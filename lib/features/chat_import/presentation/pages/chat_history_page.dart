import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../providers/chat_import_provider.dart';
import '../widgets/chat_card.dart';
import '../widgets/upload_dropzone.dart';

class ChatHistoryPage extends ConsumerStatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  ConsumerState<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends ConsumerState<ChatHistoryPage> {
  late StreamSubscription _intentDataStreamSubscription;
  static const _appIntentChannel = MethodChannel(
    'dev.codedd.chat_stats/app_intent',
  );

  @override
  void initState() {
    super.initState();
    _initShareIntent();
    _initAppIntent();
  }

  void _initAppIntent() {
    _appIntentChannel.setMethodCallHandler((call) async {
      if (call.method == 'onViewFile') {
        final path = call.arguments as String?;
        if (path != null && path.isNotEmpty) {
          ref.read(chatImportProvider.notifier).importFromPath(path);
        }
      }
    });

    _appIntentChannel
        .invokeMethod<String>('getInitialFile')
        .then((path) {
          if (path != null && path.isNotEmpty) {
            ref.read(chatImportProvider.notifier).importFromPath(path);
          }
        })
        .catchError((err) {
          debugPrint("Error al recibir archivo inicial vía app_intent: $err");
        });
  }

  void _initShareIntent() {
    // Listen to media sharing stream while app is in memory / background
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedMediaFile> value) {
            _processSharedFiles(value);
          },
          onError: (err) {
            debugPrint("Error al recibir intent de compartir: $err");
          },
        );

    // Get media sharing when app is opened via share intent (cold start)
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
          _processSharedFiles(value);
          ReceiveSharingIntent.instance.reset();
        })
        .catchError((err) {
          debugPrint("Error al recibir intent inicial de compartir: $err");
        });
  }

  void _processSharedFiles(List<SharedMediaFile> value) {
    if (value.isNotEmpty) {
      final path = value.first.path;
      if (path.isNotEmpty) {
        ref.read(chatImportProvider.notifier).importFromPath(path);
      }
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _appIntentChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(chatImportProvider);
    final chatsAsync = ref.watch(chatListProvider);

    ref.listen<ChatImportState>(chatImportProvider, (previous, next) {
      if (next.status == ImportStatus.success && next.importedChatId != null) {
        final importedId = next.importedChatId!;
        ref.read(chatListProvider.notifier).refreshChats();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Chat importado con éxito!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ref.read(chatImportProvider.notifier).reset();

        // Display interstitial ad before transitioning to dashboard
        AdService.instance.showInterstitialAd(
          onAdDismissed: () {
            if (context.mounted) {
              context.push('/dashboard/$importedId');
            }
          },
        );
      } else if (next.status == ImportStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    next.errorMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        ref.read(chatImportProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.analytics_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              'Estadísticas de WhatsApp',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: UploadDropzone(
                isLoading: importState.status == ImportStatus.loading,
                onTap: () {
                  ref.read(chatImportProvider.notifier).pickAndImportChatFile();
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'CHATS IMPORTADOS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 16),
            switch (chatsAsync) {
              AsyncData(:final value) when value.isEmpty => Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Text(
                  'Aún no has guardado ninguna sala de chat.\nImporta un archivo .zip o .txt arriba para comenzar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              AsyncData(:final value) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final chat = value[index];
                  return ChatCard(
                    chat: chat,
                    onTap: () {
                      context.push('/dashboard/${chat.id}');
                    },
                    onDelete: () async {
                      if (chat.id != null) {
                        await ref
                            .read(chatListProvider.notifier)
                            .deleteChat(chat.id!);
                      }
                    },
                  );
                },
              ),
              AsyncError(:final error) => Text(
                'Error al cargar chats: $error',
                style: const TextStyle(color: AppColors.error),
              ),
              _ => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            },
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
