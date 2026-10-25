import 'package:chat_stats/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_snackbar.dart';

class ChatStatsApp extends ConsumerWidget {
  const ChatStatsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Chats Stats',
      scaffoldMessengerKey: AppSnackBar.messengerKey,
      debugShowCheckedModeBanner: false,
      locale: userLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.15,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}


