import 'dart:ui';
import 'package:chat_stats/core/utils/date_formatter.dart';
import 'package:chat_stats/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await Future.wait([
      initializeDateFormatting('es', null),
      initializeDateFormatting('en', null),
      initializeDateFormatting('pt', null),
    ]);
  });

  group('AppDateFormatter Unit Tests', () {
    test('returns correct heatmap day abbreviations for each language', () {
      expect(
        AppDateFormatter.getHeatmapDayLabels('es'),
        equals(['L', 'M', 'X', 'J', 'V', 'S', 'D']),
      );
      expect(
        AppDateFormatter.getHeatmapDayLabels('en'),
        equals(['M', 'T', 'W', 'T', 'F', 'S', 'S']),
      );
      expect(
        AppDateFormatter.getHeatmapDayLabels('pt'),
        equals(['S', 'T', 'Q', 'Q', 'S', 'S', 'D']),
      );
    });

    test('formats dates correctly across locales', () {
      final date = DateTime(2026, 10, 21, 14, 30);
      expect(
        AppDateFormatter.formatDateTime(date, locale: 'es'),
        equals('21/10/2026 14:30'),
      );
      expect(
        AppDateFormatter.formatDayMonth(date, locale: 'es'),
        contains('21'),
      );
    });

    test('formats date ranges correctly', () {
      final start = DateTime(2026, 10, 1);
      final end = DateTime(2026, 10, 15);
      final range = AppDateFormatter.formatDateRange(start, end, locale: 'es');
      expect(range, contains('-'));
    });
  });

  group('AppLocalizations Translations Tests', () {
    test('loads Spanish (Latin America) strings', () {
      final es = lookupAppLocalizations(const Locale('es'));
      expect(es.appTitle, equals('Estadísticas de WhatsApp'));
      expect(es.chatsImported, equals('CHATS IMPORTADOS'));
      expect(es.timeSlotDawn, equals('Madrugada'));
      expect(es.timeSlotMorning, equals('Mañana'));
      expect(es.timeSlotAfternoon, equals('Tarde'));
      expect(es.timeSlotNight, equals('Noche'));
      expect(es.messagesCount(5), equals('5 msgs'));
    });

    test('loads English strings', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(en.appTitle, equals('WhatsApp Statistics'));
      expect(en.chatsImported, equals('IMPORTED CHATS'));
      expect(en.timeSlotDawn, equals('Night/Dawn'));
      expect(en.timeSlotMorning, equals('Morning'));
      expect(en.timeSlotAfternoon, equals('Afternoon'));
      expect(en.timeSlotNight, equals('Evening'));
      expect(en.messagesCount(5), equals('5 msgs'));
    });

    test('loads Portuguese strings', () {
      final pt = lookupAppLocalizations(const Locale('pt'));
      expect(pt.appTitle, equals('Estatísticas do WhatsApp'));
      expect(pt.chatsImported, equals('CHATS IMPORTADOS'));
      expect(pt.timeSlotDawn, equals('Madrugada'));
      expect(pt.timeSlotMorning, equals('Manhã'));
      expect(pt.timeSlotAfternoon, equals('Tarde'));
      expect(pt.timeSlotNight, equals('Noite'));
      expect(pt.messagesCount(5), equals('5 msgs'));
    });
  });
}
