import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat_import/presentation/pages/chat_history_page.dart';
import '../../features/chat_dashboard/presentation/pages/chat_dashboard_page.dart';
import '../../features/chat_dashboard/presentation/pages/chat_search_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final uri = state.uri;
    if (uri.scheme == 'content' ||
        uri.scheme == 'file' ||
        uri.path.startsWith('content:') ||
        uri.path.startsWith('file:')) {
      return '/';
    }
    return null;
  },
  errorBuilder: (context, state) => const ChatHistoryPage(),
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const ChatHistoryPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/dashboard/:chatId',
      name: 'dashboard',
      pageBuilder: (context, state) {
        final chatIdStr = state.pathParameters['chatId'];
        final chatId = int.tryParse(chatIdStr ?? '') ?? 0;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ChatDashboardPage(chatId: chatId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/search/:chatId',
      name: 'search',
      pageBuilder: (context, state) {
        final chatIdStr = state.pathParameters['chatId'];
        final chatId = int.tryParse(chatIdStr ?? '') ?? 0;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ChatSearchPage(chatId: chatId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],
);

