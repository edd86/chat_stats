import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/conversation_dynamics.dart';
import '../../domain/models/message_analysis.dart';

class SocialRolesSection extends StatelessWidget {
  final ConversationDynamics dynamics;
  final MessageAnalysis analysis;

  const SocialRolesSection({
    super.key,
    required this.dynamics,
    required this.analysis,
  });

  String _formatDuration(Duration d) {
    if (d.inDays >= 1) {
      final h = d.inHours % 24;
      return h > 0 ? '${d.inDays}d ${h}h' : '${d.inDays}d';
    } else if (d.inHours >= 1) {
      final m = d.inMinutes % 60;
      return m > 0 ? '${d.inHours}h ${m}m' : '${d.inHours}h';
    } else if (d.inMinutes >= 1) {
      final s = d.inSeconds % 60;
      return s > 0 ? '${d.inMinutes}m ${s}s' : '${d.inMinutes}m';
    } else {
      return '${d.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Writer
    ParticipantAnalysis? topWriterPerson;

    if (analysis.participants.isNotEmpty) {
      final sortedByWords = List<ParticipantAnalysis>.from(
        analysis.participants,
      )..sort((a, b) => b.wordsCount.compareTo(a.wordsCount));

      if (sortedByWords.isNotEmpty && sortedByWords.first.wordsCount > 0) {
        topWriterPerson = sortedByWords.first;
      }
    }

    // 2. Questions
    final sortedByQuestions = List<ParticipantAnalysis>.from(
      analysis.participants,
    )..sort((a, b) => b.questionCount.compareTo(a.questionCount));
    final topQuestioner =
        sortedByQuestions.isNotEmpty &&
            sortedByQuestions.first.questionCount > 0
        ? sortedByQuestions.first
        : null;

    // 3. Mentions
    final mentionsMap = analysis.mentionsReceived;
    final sortedMentions = mentionsMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMentioned = sortedMentions.isNotEmpty
        ? sortedMentions.first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Writer Card
        if (topWriterPerson != null) ...[
          Text(
            'EL ESCRITOR DEL CHAT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _WriterCard(
            writerPerson: topWriterPerson,
          ),
          const SizedBox(height: 24),
        ],

        // Response Speed
        if (dynamics.responseTimes.isNotEmpty) ...[
          Text(
            'VELOCIDAD DE RESPUESTA POR PARTICIPANTE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _ResponseSpeedList(
            responseTimes: dynamics.responseTimes,
            formatDuration: _formatDuration,
          ),
          const SizedBox(height: 24),
        ],

        // Curiosities Row: Questions & Mentions
        if (topQuestioner != null || topMentioned != null) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              final questionWidget = topQuestioner != null
                  ? _MiniInsightTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: AppColors.secondary,
                      title: 'EL MÁS CURIOSO',
                      name: topQuestioner.name,
                      stat: '${topQuestioner.questionCount} preguntas',
                      subtitle:
                          '${topQuestioner.textCount > 0 ? (topQuestioner.questionCount / topQuestioner.textCount * 100).toStringAsFixed(0) : 0}% de sus mensajes',
                    )
                  : const SizedBox();

              final mentionWidget = topMentioned != null
                  ? _MiniInsightTile(
                      icon: Icons.alternate_email_rounded,
                      iconColor: AppColors.primary,
                      title: 'EL MÁS POPULAR / MENCIONADO',
                      name: topMentioned.key,
                      stat: '${topMentioned.value} menciones',
                      subtitle: 'La persona más arrobada del chat',
                    )
                  : const SizedBox();

              if (isWide && topQuestioner != null && topMentioned != null) {
                return Row(
                  children: [
                    Expanded(child: questionWidget),
                    const SizedBox(width: 12),
                    Expanded(child: mentionWidget),
                  ],
                );
              } else {
                return Column(
                  children: [
                    if (topQuestioner != null) questionWidget,
                    if (topQuestioner != null && topMentioned != null)
                      const SizedBox(height: 12),
                    if (topMentioned != null) mentionWidget,
                  ],
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class _WriterCard extends StatelessWidget {
  final ParticipantAnalysis? writerPerson;

  const _WriterCard({
    required this.writerPerson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.12),
            AppColors.surfaceContainer,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              size: 24,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EL GRAN ESCRITOR',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  writerPerson?.name ?? 'Nadie',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${writerPerson?.wordsCount ?? 0} palabras redactadas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseSpeedList extends StatelessWidget {
  final List<ParticipantResponseTime> responseTimes;
  final String Function(Duration) formatDuration;

  const _ResponseSpeedList({
    required this.responseTimes,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final topList = responseTimes.take(6).toList();

    return Column(
      children: topList.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        Color badgeColor;
        String badgeLabel;
        IconData badgeIcon;

        if (item.avgResponseTime.inMinutes <= 2) {
          badgeColor = AppColors.primary;
          badgeLabel = 'Rayo ⚡';
          badgeIcon = Icons.flash_on_rounded;
        } else if (item.avgResponseTime.inMinutes <= 15) {
          badgeColor = AppColors.secondary;
          badgeLabel = 'Rápido';
          badgeIcon = Icons.timer_outlined;
        } else if (item.avgResponseTime.inHours <= 2) {
          badgeColor = AppColors.tertiary;
          badgeLabel = 'Promedio';
          badgeIcon = Icons.schedule_rounded;
        } else {
          badgeColor = AppColors.outline;
          badgeLabel = 'Fantasma 👻';
          badgeIcon = Icons.nightlight_round;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant, width: 0.6),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: index == 0
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceContainerHigh,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: index == 0 ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 12, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatDuration(item.avgResponseTime),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MiniInsightTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String name;
  final String stat;
  final String subtitle;

  const _MiniInsightTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.name,
    required this.stat,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$stat • $subtitle',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
