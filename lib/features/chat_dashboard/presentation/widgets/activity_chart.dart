import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_dashboard_provider.dart';

class ActivityChart extends ConsumerWidget {
  final List<Map<String, dynamic>> dailyData;

  const ActivityChart({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeframe = ref.watch(activityChartFilterProvider);

    final displayData = switch (timeframe) {
      ActivityChartTimeframe.last30Days =>
        dailyData.length > 30
            ? dailyData.sublist(dailyData.length - 30)
            : dailyData,
      ActivityChartTimeframe.all => dailyData,
    };

    if (displayData.isEmpty) {
      return Container(
        height: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Column(
          children: [
            _buildHeader(context, ref, timeframe),
            const Expanded(
              child: Center(
                child: Text(
                  'Sin datos suficientes de actividad',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final spots = <FlSpot>[];
    double maxMsgs = 0;

    for (int i = 0; i < displayData.length; i++) {
      final count = (displayData[i]['count'] as num).toDouble();
      if (count > maxMsgs) maxMsgs = count;
      spots.add(FlSpot(i.toDouble(), count));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, timeframe),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: (displayData.length / 4)
                          .clamp(1, 100)
                          .toDouble(),
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < displayData.length) {
                          final dateStr =
                              displayData[index]['date_str'] as String;
                          return Text(
                            dateStr,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 9,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (displayData.length - 1).toDouble(),
                minY: 0,
                maxY: maxMsgs * 1.15,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.35),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ActivityChartTimeframe timeframe,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.show_chart, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'ACTIVIDAD DIARIA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FilterOption(
                label: 'Todo',
                isSelected: timeframe == ActivityChartTimeframe.all,
                onTap: () => ref
                    .read(activityChartFilterProvider.notifier)
                    .setTimeframe(ActivityChartTimeframe.all),
              ),
              _FilterOption(
                label: '30 días',
                isSelected: timeframe == ActivityChartTimeframe.last30Days,
                onTap: () => ref
                    .read(activityChartFilterProvider.notifier)
                    .setTimeframe(ActivityChartTimeframe.last30Days),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.background
                : AppColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
