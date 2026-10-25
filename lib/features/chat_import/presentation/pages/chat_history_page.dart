import 'dart:async';
import 'package:chat_stats/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/services/privacy_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/language_selector_sheet.dart';
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

  bool _isLockEnabled = false;
  bool _isAuthenticated = false;
  bool _checkingLock = true;
  bool _isNavigatingToDashboard = false;

  @override
  void initState() {
    super.initState();
    _initShareIntent();
    _initAppIntent();
    _checkPrivacyLock();
  }

  Future<void> _checkPrivacyLock() async {
    final enabled = await PrivacyService.instance.isLockEnabled();
    if (mounted) {
      setState(() {
        _isLockEnabled = enabled;
        _checkingLock = false;
        _isAuthenticated = !enabled;
      });
      if (enabled) {
        _authenticateUser();
      }
    }
  }

  Future<void> _authenticateUser() async {
    final success = await PrivacyService.instance.authenticate();
    if (mounted && success) {
      setState(() => _isAuthenticated = true);
    }
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

  void _openChatDashboard(int chatId) {
    if (_isNavigatingToDashboard) return;
    _isNavigatingToDashboard = true;

    AdService.instance.showInterstitialAd(
      onAdDismissed: () {
        if (!mounted) {
          _isNavigatingToDashboard = false;
          return;
        }
        context.push('/dashboard/$chatId').whenComplete(() {
          if (mounted) {
            setState(() {
              _isNavigatingToDashboard = false;
            });
          } else {
            _isNavigatingToDashboard = false;
          }
        });
      },
    );
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
    final l10n = AppLocalizations.of(context);

    ref.listen<ChatImportState>(chatImportProvider, (previous, next) {
      if (next.status == ImportStatus.success && next.importedChatId != null) {
        final importedId = next.importedChatId!;
        ref.read(chatListProvider.notifier).refreshChats();
        AppSnackBar.showSuccess(
          l10n?.importChatSuccess ?? '¡Chat importado con éxito!',
          context: context,
        );
        ref.read(chatImportProvider.notifier).reset();

        // Display interstitial ad before transitioning to dashboard
        _openChatDashboard(importedId);
      } else if (next.status == ImportStatus.error &&
          next.errorMessage != null) {
        AppSnackBar.showError(next.errorMessage!, context: context);
        ref.read(chatImportProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.analytics_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n?.appTitle ?? 'Estadísticas de WhatsApp',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language_rounded,
              color: AppColors.onSurfaceVariant,
            ),
            tooltip: l10n?.language ?? 'Idioma',
            onPressed: () => showLanguageSelectorSheet(context, ref),
          ),
          IconButton(
            icon: Icon(
              _isLockEnabled ? Icons.lock_rounded : Icons.lock_outline_rounded,
              color: _isLockEnabled
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            tooltip: l10n?.securityAndPrivacy ?? 'Seguridad y Privacidad',
            onPressed: () => _showPrivacySettingsSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _checkingLock
          ? const Center(child: CircularProgressIndicator())
          : (_isLockEnabled && !_isAuthenticated)
          ? _buildLockScreen()
          : Builder(
              builder: (context) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final pagePadding = screenWidth < 380 ? 14.0 : 20.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: UploadDropzone(
                          isLoading: importState.status == ImportStatus.loading,
                          onTap: () {
                            ref
                                .read(chatImportProvider.notifier)
                                .pickAndImportChatFile();
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n?.chatsImported ?? 'CHATS IMPORTADOS',
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
                            l10n?.noChatsYet ??
                                'Aún no has guardado ninguna sala de chat.\nImporta un archivo .zip o .txt arriba para comenzar.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
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
                                if (chat.id != null) {
                                  _openChatDashboard(chat.id!);
                                }
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
                          l10n?.chatLoadError(error.toString()) ??
                              'Error al cargar chats: $error',
                          style: const TextStyle(color: AppColors.error),
                        ),
                        _ => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      },
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildLockScreen() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.securityLockActivated ?? 'Bloqueo de Seguridad Activado',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.securityLockPrompt ??
                  'Confirma tu identidad para acceder a tus chats y estadísticas.',
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF003915),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _authenticateUser,
              icon: const Icon(Icons.lock_open_rounded),
              label: Text(
                l10n?.unlock ?? 'Desbloquear',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettingsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider);
    final currentLangLabel = kSupportedLanguages
        .firstWhere(
          (element) =>
              (element.locale == null && currentLocale == null) ||
              (element.locale?.languageCode == currentLocale?.languageCode),
          orElse: () => kSupportedLanguages.first,
        )
        .label;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.settings_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n?.securityAndPrivacy ?? 'Seguridad y Privacidad',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.privacyExplanation ??
                          'Tus chats se procesan 100% en tu dispositivo y nunca se envían a ningún servidor externo.',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n?.biometricLockTitle ?? 'Bloqueo con Huella / PIN',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        l10n?.biometricLockSubtitle ??
                            'Solicitar autenticación al abrir la app',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: _isLockEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) async {
                        await PrivacyService.instance.setLockEnabled(val);
                        setState(() => _isLockEnabled = val);
                        setModalState(() {});
                      },
                    ),
                    const Divider(color: AppColors.outlineVariant, height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.language_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        l10n?.language ?? 'Idioma',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        currentLangLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showLanguageSelectorSheet(context, ref);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

