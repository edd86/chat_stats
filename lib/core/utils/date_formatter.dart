import 'package:chat_stats/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateFormatter {
  const AppDateFormatter._();

  static String getLocaleTag(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  /// Formats date and time: e.g. "21/10/2026 14:30" or localized format
  static String formatDateTime(DateTime dateTime, {String? locale}) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm', locale).format(dateTime);
    } catch (_) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  /// Formats date with medium month: e.g. "21 oct 2026" / "Oct 21, 2026"
  static String formatDateMedium(DateTime dateTime, {String? locale}) {
    try {
      return DateFormat.yMMMd(locale).format(dateTime);
    } catch (_) {
      return DateFormat('d MMM yyyy').format(dateTime);
    }
  }

  /// Formats short date: e.g. "21/10/2026" or "10/21/2026"
  static String formatDateShort(DateTime dateTime, {String? locale}) {
    try {
      return DateFormat.yMd(locale).format(dateTime);
    } catch (_) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Formats short day and month: e.g. "21 oct" or "Oct 21"
  static String formatDayMonth(DateTime dateTime, {String? locale}) {
    try {
      return DateFormat.MMMd(locale).format(dateTime);
    } catch (_) {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  /// Formats time in 24h format: e.g. "14:30"
  static String formatTime24(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Formats date range: e.g. "21 oct - 25 oct"
  static String formatDateRange(
    DateTime start,
    DateTime end, {
    String? locale,
  }) {
    final startStr = formatDayMonth(start, locale: locale);
    final endStr = formatDayMonth(end, locale: locale);
    return '$startStr - $endStr';
  }

  /// Formats silence / time interval with translated units
  static String formatSilence(Duration d, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      if (d.inDays >= 1) return '${d.inDays}d';
      if (d.inHours >= 1) return '${d.inHours}h';
      return '${d.inMinutes}m';
    }

    if (d.inDays >= 1) {
      final hours = d.inHours % 24;
      if (hours > 0) {
        return '${d.inDays}d ${hours}h';
      }
      return l10n.daysCount(d.inDays);
    } else if (d.inHours >= 1) {
      final mins = d.inMinutes % 60;
      if (mins > 0) {
        return '${d.inHours}h ${mins}m';
      }
      return l10n.hoursCount(d.inHours);
    } else {
      return l10n.minutesCount(d.inMinutes);
    }
  }

  /// Returns weekday letters for Monday -> Sunday in the target language
  static List<String> getHeatmapDayLabels(String localeCode) {
    switch (localeCode.toLowerCase()) {
      case 'en':
        return const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      case 'pt':
        return const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
      case 'es':
      default:
        return const ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    }
  }
}
