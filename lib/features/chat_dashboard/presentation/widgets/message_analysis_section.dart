import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/message_analysis.dart';

class MessageAnalysisSection extends StatelessWidget {
  final MessageAnalysis analysis;

  const MessageAnalysisSection({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Summary
        _KpiSummary(analysis: analysis),
        const SizedBox(height: 20),

        // Top Words
        if (analysis.topWords.isNotEmpty) ...[
          _SectionTitle(title: 'PALABRAS MÁS USADAS (TOP 10)'),
          const SizedBox(height: 12),
          _TopWordsGrid(words: analysis.topWords),
          const SizedBox(height: 24),
        ],

        // Top Emojis
        if (analysis.topEmojisGeneral.isNotEmpty) ...[
          _SectionTitle(title: 'EMOJIS MÁS USADOS'),
          const SizedBox(height: 12),
          _TopEmojisSection(
            generalEmojis: analysis.topEmojisGeneral,
            byPerson: analysis.topEmojisByPerson,
          ),
          const SizedBox(height: 24),
        ],

        // Per-participant analysis
        if (analysis.participants.isNotEmpty) ...[
          _SectionTitle(title: 'ANÁLISIS POR PARTICIPANTE'),
          const SizedBox(height: 12),
          _ParticipantAnalysisList(participants: analysis.participants),
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
  final MessageAnalysis analysis;

  const _KpiSummary({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final uniqueWords = analysis.topWords.length;

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
              label: 'Palabras únicas',
              value: '$uniqueWords',
              icon: Icons.text_fields,
              color: AppColors.primary,
            ),
            _MiniKpi(
              label: 'Editados',
              value: '${analysis.totalEdited}',
              icon: Icons.edit_outlined,
              color: AppColors.tertiary,
            ),
            _MiniKpi(
              label: 'Eliminados',
              value: '${analysis.totalDeleted}',
              icon: Icons.delete_outline,
              color: AppColors.error,
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

class _TopWordsGrid extends StatelessWidget {
  final List<MessageWord> words;

  const _TopWordsGrid({required this.words});

  @override
  Widget build(BuildContext context) {
    final filteredWords = words.where((w) {
      final lower = w.word.toLowerCase();
      return lower != 'multimedia' &&
          lower != 'omitido' &&
          lower != 'omitted' &&
          lower != 'media' &&
          lower != 'foto' &&
          lower != 'video' &&
          lower != 'audio';
    }).toList();

    final maxCount = filteredWords.isNotEmpty ? filteredWords.first.count : 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: filteredWords.asMap().entries.map((entry) {
          final idx = entry.key;
          final word = entry.value;
          final barPct = maxCount > 0 ? word.count / maxCount : 0.0;
          final fontSize = 11.0 + (barPct * 4);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${idx + 1}.',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  word.word,
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${word.count}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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

class _TopEmojisSection extends StatelessWidget {
  final List<MessageEmoji> generalEmojis;
  final Map<String, List<MessageEmoji>> byPerson;

  const _TopEmojisSection({
    required this.generalEmojis,
    required this.byPerson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General
          Text(
            'EN GENERAL',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: generalEmojis.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(
                    '${e.count}',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          if (byPerson.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'POR PERSONA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            ...byPerson.entries.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: entry.value.map((emoji) {
                          return Text(
                            '${emoji.emoji}${emoji.count}',
                            style: const TextStyle(fontSize: 13),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _ParticipantAnalysisList extends StatelessWidget {
  final List<ParticipantAnalysis> participants;

  const _ParticipantAnalysisList({required this.participants});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: participants.asMap().entries.map((entry) {
          final idx = entry.key;
          final p = entry.value;
          final isLast = idx == participants.length - 1;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: isLast
                ? null
                : BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Stats grid
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.straighten,
                      label: 'Promedio',
                      value: '${p.avgChars.toStringAsFixed(0)} chars',
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.short_text,
                      label: 'Más corto',
                      value: '${p.shortestMsg} chars',
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.notes,
                      label: 'Más largo',
                      value: '${p.longestMsg} chars',
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.edit_outlined,
                      label: 'Editados',
                      value: '${p.editedCount}',
                      color: AppColors.primary,
                    ),
                  ],
                ),
                if (p.deletedCount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.delete_outline,
                        label: 'Eliminados',
                        value: '${p.deletedCount}',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),

                // Content breakdown bar
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: p.textPct / 100,
                          backgroundColor: AppColors.tertiary,
                          color: AppColors.secondary,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Texto: ${p.textPct.toStringAsFixed(0)}%  Media: ${p.mediaPct.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                // Top emojis for this person
                if (p.topEmojis.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Emojis: ',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      ...p.topEmojis.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '${e.emoji}${e.count}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Longest message preview
                if (p.longestPreview.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Msg más largo: "${p.longestPreview}"',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
