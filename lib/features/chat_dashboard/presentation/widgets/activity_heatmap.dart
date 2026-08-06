import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ActivityHeatmap extends StatelessWidget {
  final List<Map<String, dynamic>> heatmapData;

  const ActivityHeatmap({super.key, required this.heatmapData});

  static const _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    if (heatmapData.isEmpty) return const SizedBox();

    final grid = _buildGrid();
    final maxCount = _getMaxCount(grid);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MAPA DE ACTIVIDAD (DÍA × HORA)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const Icon(Icons.grid_view, color: AppColors.tertiary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          _HeatmapGrid(grid: grid, maxCount: maxCount),
          const SizedBox(height: 8),
          _HeatmapLegend(maxCount: maxCount),
        ],
      ),
    );
  }

  List<List<int>> _buildGrid() {
    final grid = List.generate(7, (_) => List.filled(24, 0));
    for (final row in heatmapData) {
      final day = row['day_of_week'] as int? ?? 0;
      final hour = row['hour'] as int? ?? 0;
      final count = row['count'] as int? ?? 0;
      if (day >= 0 && day < 7 && hour >= 0 && hour < 24) {
        grid[day][hour] = count;
      }
    }
    return grid;
  }

  int _getMaxCount(List<List<int>> grid) {
    int max = 0;
    for (final row in grid) {
      for (final val in row) {
        if (val > max) max = val;
      }
    }
    return max;
  }
}

class _HeatmapGrid extends StatelessWidget {
  final List<List<int>> grid;
  final int maxCount;

  const _HeatmapGrid({required this.grid, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final leftLabelWidth = 24.0;
        final availableWidth = constraints.maxWidth - leftLabelWidth;
        final cellSpacing = 2.0;
        final totalSpacing = cellSpacing * 23;
        final cellSize = (availableWidth - totalSpacing) / 26;

        return Column(
          children: [
            // Hour labels
            Padding(
              padding: EdgeInsets.only(left: leftLabelWidth),
              child: Row(
                children: List.generate(24, (hour) {
                  final showLabel = hour % 4 == 0;
                  return SizedBox(
                    width: cellSize + cellSpacing,
                    child: showLabel
                        ? Text(
                            hour.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox.shrink(),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),
            // Grid rows
            ...List.generate(7, (day) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: leftLabelWidth,
                      child: Text(
                        ActivityHeatmap._dayLabels[day],
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ...List.generate(24, (hour) {
                      final count = grid[day][hour];
                      return Container(
                        width: cellSize,
                        height: cellSize,
                        margin: EdgeInsets.only(right: cellSpacing),
                        decoration: BoxDecoration(
                          color: _getCellColor(count, maxCount),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Color _getCellColor(int count, int max) {
    if (count == 0 || max == 0) return AppColors.surfaceContainerLow;
    final ratio = count / max;
    if (ratio < 0.25) return AppColors.primary.withValues(alpha: 0.2);
    if (ratio < 0.50) return AppColors.primary.withValues(alpha: 0.4);
    if (ratio < 0.75) return AppColors.primary.withValues(alpha: 0.65);
    return AppColors.primary;
  }
}

class _HeatmapLegend extends StatelessWidget {
  final int maxCount;

  const _HeatmapLegend({required this.maxCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '0',
          style: TextStyle(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 9,
          ),
        ),
        const SizedBox(width: 4),
        _legendBox(AppColors.surfaceContainerLow),
        const SizedBox(width: 2),
        _legendBox(AppColors.primary.withValues(alpha: 0.2)),
        const SizedBox(width: 2),
        _legendBox(AppColors.primary.withValues(alpha: 0.4)),
        const SizedBox(width: 2),
        _legendBox(AppColors.primary.withValues(alpha: 0.65)),
        const SizedBox(width: 2),
        _legendBox(AppColors.primary),
        const SizedBox(width: 4),
        Text(
          '$maxCount',
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
