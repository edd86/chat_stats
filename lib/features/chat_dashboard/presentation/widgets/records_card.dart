import 'package:chat_stats/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/conversation_dynamics.dart';

class RecordsCard extends StatelessWidget {
  final Map<String, dynamic>? recordDay;
  final ChatSilence? longestSilence;
  final int totalMessages;

  const RecordsCard({
    super.key,
    required this.recordDay,
    required this.longestSilence,
    required this.totalMessages,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).languageCode;
    final recordCount = (recordDay?['count'] as int?) ?? 0;
    final recordDateStr = (recordDay?['date_str'] as String?) ?? 'N/A';
    final pctOfTotal = totalMessages > 0
        ? (recordCount / totalMessages * 100).toStringAsFixed(1)
        : '0';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        final dayRecordWidget = _RecordTile(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.tertiary,
          title: l10n?.mostActiveDayTitle ?? 'DÍA MÁS ACTIVO DE LA HISTORIA',
          primaryText: l10n?.messagesCount(recordCount) ?? '$recordCount msgs',
          secondaryText: recordDateStr,
          badgeText: l10n?.pctOfTotal(pctOfTotal) ?? '$pctOfTotal% del total',
          gradientColors: [
            AppColors.tertiary.withValues(alpha: 0.12),
            AppColors.surfaceContainer,
          ],
        );

        final String silenceDurationFormatted = longestSilence != null
            ? AppDateFormatter.formatSilence(longestSilence!.duration, context)
            : '';

        final String silenceDatesFormatted = longestSilence != null
            ? '${AppDateFormatter.formatDateMedium(longestSilence!.start, locale: localeTag)} → ${AppDateFormatter.formatDateMedium(longestSilence!.end, locale: localeTag)}'
            : '';

        final silenceWidget = longestSilence != null
            ? _RecordTile(
                icon: Icons.hourglass_top_rounded,
                iconColor: AppColors.secondary,
                title: l10n?.longestSilenceTitle ?? 'EL SILENCIO MÁS LARGO',
                primaryText: silenceDurationFormatted,
                secondaryText: silenceDatesFormatted,
                badgeText: l10n?.silenceBrokeBy(
                      longestSilence!.firstSenderAfter,
                    ) ??
                    'Rompió silencio: ${longestSilence!.firstSenderAfter}',
                gradientColors: [
                  AppColors.secondary.withValues(alpha: 0.12),
                  AppColors.surfaceContainer,
                ],
              )
            : _RecordTile(
                icon: Icons.hourglass_empty_rounded,
                iconColor: AppColors.secondary,
                title: l10n?.longestSilenceTitle ?? 'EL SILENCIO MÁS LARGO',
                primaryText: '-',
                secondaryText:
                    l10n?.uninterruptedChat ?? 'Conversación ininterrumpida',
                badgeText: null,
                gradientColors: [
                  AppColors.secondary.withValues(alpha: 0.08),
                  AppColors.surfaceContainer,
                ],
              );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: dayRecordWidget),
              const SizedBox(width: 12),
              Expanded(child: silenceWidget),
            ],
          );
        } else {
          return Column(
            children: [
              dayRecordWidget,
              const SizedBox(height: 12),
              silenceWidget,
            ],
          );
        }
      },
    );
  }
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String primaryText;
  final String secondaryText;
  final String? badgeText;
  final List<Color> gradientColors;

  const _RecordTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.primaryText,
    required this.secondaryText,
    required this.badgeText,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                primaryText,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  secondaryText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (badgeText != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                badgeText!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
