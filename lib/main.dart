import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter framework error: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled async platform error: $error\n$stack');
    return true;
  };

  try {
    await initializeDateFormatting('es', null);
  } catch (e) {
    debugPrint('Error intl initializeDateFormatting: $e');
  }

  // Start Flutter UI immediately to avoid any startup blocking / ANR
  runApp(
    const ProviderScope(
      child: ChatStatsApp(),
    ),
  );

  // Initialize AdService asynchronously without blocking UI startup
  unawaited(
    AdService.instance.initialize().catchError((e) {
      debugPrint('Error initializing AdService: $e');
    }),
  );
}

