import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
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

  String _formatSilence(Duration d) {
    if (d.inDays >= 1) {
      final hours = d.inHours % 24;
      return hours > 0 ? '${d.inDays}d ${hours}h' : '${d.inDays} días';
    } else if (d.inHours >= 1) {
      final mins = d.inMinutes % 60;
      return mins > 0 ? '${d.inHours}h ${mins}m' : '${d.inHours} horas';
    } else {
      return '${d.inMinutes} minutos';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordCount = (recordDay?['count'] as int?) ?? 0;
    final recordDateStr = (recordDay?['date_str'] as String?) ?? 'Sin datos';
    final pctOfTotal = totalMessages > 0
        ? (recordCount / totalMessages * 100).toStringAsFixed(1)
        : '0';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        final dayRecordWidget = _RecordTile(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.tertiary,
          title: 'DÍA MÁS ACTIVO DE LA HISTORIA',
          primaryText: '$recordCount msgs',
          secondaryText: recordDateStr,
          badgeText: '$pctOfTotal% del total',
          gradientColors: [
            AppColors.tertiary.withValues(alpha: 0.12),
            AppColors.surfaceContainer,
          ],
        );

        final silenceWidget = longestSilence != null
            ? _RecordTile(
                icon: Icons.hourglass_top_rounded,
                iconColor: AppColors.secondary,
                title: 'EL SILENCIO MÁS LARGO',
                primaryText: _formatSilence(longestSilence!.duration),
                secondaryText:
                    '${DateFormat('d MMM yyyy').format(longestSilence!.start)} → ${DateFormat('d MMM yyyy').format(longestSilence!.end)}',
                badgeText:
                    'Rompió silencio: ${longestSilence!.firstSenderAfter}',
                gradientColors: [
                  AppColors.secondary.withValues(alpha: 0.12),
                  AppColors.surfaceContainer,
                ],
              )
            : _RecordTile(
                icon: Icons.hourglass_empty_rounded,
                iconColor: AppColors.secondary,
                title: 'EL SILENCIO MÁS LARGO',
                primaryText: 'Sin pausas',
                secondaryText: 'Conversación ininterrumpida',
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
