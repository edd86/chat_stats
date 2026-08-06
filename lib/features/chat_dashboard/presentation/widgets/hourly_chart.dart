import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HourlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;

  const HourlyChart({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const SizedBox();
    }

    final Map<int, int> hourMap = {for (int i = 0; i < 24; i++) i: 0};
    for (final row in hourlyData) {
      final hourStr = row['hour'] as String?;
      final count = row['count'] as int? ?? 0;
      if (hourStr != null) {
        final hourInt = int.tryParse(hourStr);
        if (hourInt != null && hourInt >= 0 && hourInt < 24) {
          hourMap[hourInt] = count;
        }
      }
    }

    double maxCount = 0;
    hourMap.forEach((_, count) {
      if (count > maxCount) maxCount = count.toDouble();
    });
    if (maxCount == 0) maxCount = 1;

    final barGroups = <BarChartGroupData>[];
    for (int hour = 0; hour < 24; hour++) {
      final count = hourMap[hour]!.toDouble();
      barGroups.add(
        BarChartGroupData(
          x: hour,
          barRods: [
            BarChartRodData(
              toY: count,
              color: count == maxCount ? AppColors.tertiary : AppColors.primary,
              width: 8,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 12),
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
                'DISTRIBUCIÓN POR HORA DEL DÍA (00:00 - 23:00)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const Icon(
                Icons.access_time,
                color: AppColors.tertiary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        int h = value.toInt();
                        if (h >= 0 && h < 24) {
                          return Text(
                            '${h.toString().padLeft(2, '0')}h',
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
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
