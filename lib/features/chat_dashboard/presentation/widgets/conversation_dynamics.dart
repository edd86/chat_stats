import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/conversation_dynamics.dart';

class ConversationDynamicsSection extends StatelessWidget {
  final ConversationDynamics dynamics;

  const ConversationDynamicsSection({super.key, required this.dynamics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Summary Cards
        _KpiSummary(dynamics: dynamics),
        const SizedBox(height: 20),

        // Who initiates
        _SectionTitle(title: 'QUIÉN INICIA LAS CONVERSACIONES'),
        const SizedBox(height: 12),
        _InitiatorsList(
          initiators: dynamics.initiators,
          totalDays: dynamics.totalDays,
        ),
        const SizedBox(height: 24),

        // Response rate
        if (dynamics.responseRates.isNotEmpty) ...[
          _SectionTitle(title: 'QUIÉN RESPONDE A QUIÉN'),
          const SizedBox(height: 12),
          _ResponseRateList(responseRates: dynamics.responseRates),
          const SizedBox(height: 24),
        ],

        // Longest thread
        if (dynamics.longestThread != null) ...[
          _SectionTitle(title: 'CONVERSACIÓN MÁS LARGA'),
          const SizedBox(height: 12),
          _LongestThreadCard(thread: dynamics.longestThread!),
          const SizedBox(height: 24),
        ],

        // Consecutive messages
        if (dynamics.consecutiveMax.isNotEmpty) ...[
          _SectionTitle(title: 'RÉCORD DE MENSAJES CONSECUTIVOS'),
          const SizedBox(height: 12),
          _ConsecutiveList(consecutiveMax: dynamics.consecutiveMax),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _KpiSummary extends StatelessWidget {
  final ConversationDynamics dynamics;

  const _KpiSummary({required this.dynamics});

  @override
  Widget build(BuildContext context) {
    final topInitiator = dynamics.initiators.isNotEmpty
        ? (dynamics.initiators.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key
        : '-';
    final topResponder = dynamics.consecutiveMax.isNotEmpty
        ? (dynamics.consecutiveMax.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key
        : '-';

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 3;
        final aspectRatio = constraints.maxWidth > 600 ? 1.8 : 1.25;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: aspectRatio,
          children: [
            _MiniKpi(
              label: 'Iniciador estrella',
              value: topInitiator,
              icon: Icons.wb_twilight,
              color: AppColors.tertiary,
            ),
            _MiniKpi(
              label: 'Más conversaciones',
              value: '${dynamics.totalDays} días',
              icon: Icons.calendar_today,
              color: AppColors.secondary,
            ),
            _MiniKpi(
              label: 'Récord seguidos',
              value: topResponder,
              icon: Icons.flash_on,
              color: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InitiatorsList extends StatelessWidget {
  final Map<String, int> initiators;
  final int totalDays;

  const _InitiatorsList({required this.initiators, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    final sorted = initiators.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.isNotEmpty ? sorted.first.value : 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: sorted.take(5).map((entry) {
          final pct = totalDays > 0
              ? (entry.value / totalDays * 100).toStringAsFixed(0)
              : '0';
          final barPct = maxCount > 0 ? entry.value / maxCount : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.tertiary.withValues(alpha: 0.2),
                  child: Text(
                    entry.key.isNotEmpty ? entry.key[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${entry.value} días ($pct%)',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: barPct,
                        backgroundColor: AppColors.surfaceContainerLow,
                        color: AppColors.tertiary,
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ResponseRateList extends StatelessWidget {
  final List<ResponsePair> responseRates;

  const _ResponseRateList({required this.responseRates});

  @override
  Widget build(BuildContext context) {
    final top = responseRates.take(6).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: top.map((pair) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          pair.from,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          pair.to,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${pair.count} veces',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LongestThreadCard extends StatelessWidget {
  final ConversationThread thread;

  const _LongestThreadCard({required this.thread});

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat;
    try {
      dateFormat = DateFormat('dd MMM yyyy', 'es');
    } catch (_) {
      dateFormat = DateFormat('dd MMM yyyy');
    }
    final timeFormat = DateFormat('HH:mm');
    final durationH = thread.duration.inHours;
    final durationM = thread.duration.inMinutes % 60;
    final durationStr = durationH > 0
        ? '${durationH}h ${durationM}min'
        : '${durationM}min';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                '${thread.messageCount} mensajes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  durationStr,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(thread.start),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${timeFormat.format(thread.start)} → ${timeFormat.format(thread.end)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  thread.participants.join(', '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsecutiveList extends StatelessWidget {
  final Map<String, int> consecutiveMax;

  const _ConsecutiveList({required this.consecutiveMax});

  @override
  Widget build(BuildContext context) {
    final sorted = consecutiveMax.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: sorted.take(5).map((entry) {
          final barPct = maxVal > 0 ? entry.value / maxVal : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    entry.key.isNotEmpty ? entry.key[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${entry.value} seguidos',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: barPct,
                        backgroundColor: AppColors.surfaceContainerLow,
                        color: AppColors.primary,
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
