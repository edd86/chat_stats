import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

enum _HourlyViewMode { slots, curve }

class HourlyChart extends StatefulWidget {
  final List<Map<String, dynamic>> hourlyData;

  const HourlyChart({super.key, required this.hourlyData});

  @override
  State<HourlyChart> createState() => _HourlyChartState();
}

class _HourlyChartState extends State<HourlyChart> {
  _HourlyViewMode _viewMode = _HourlyViewMode.slots;
  int? _expandedSlotIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.hourlyData.isEmpty) {
      return const SizedBox();
    }

    final Map<int, int> hourMap = {for (int i = 0; i < 24; i++) i: 0};
    for (final row in widget.hourlyData) {
      final hourRaw = row['hour'];
      final count = row['count'] as int? ?? 0;
      if (hourRaw != null) {
        final hourInt =
            hourRaw is int ? hourRaw : int.tryParse(hourRaw.toString());
        if (hourInt != null && hourInt >= 0 && hourInt < 24) {
          hourMap[hourInt] = count;
        }
      }
    }

    int totalMessages = 0;
    int peakHour = 0;
    int peakHourCount = 0;
    for (int h = 0; h < 24; h++) {
      final count = hourMap[h] ?? 0;
      totalMessages += count;
      if (count > peakHourCount) {
        peakHourCount = count;
        peakHour = h;
      }
    }

    final slots = [
      const _TimeSlot(
        title: 'Madrugada',
        rangeLabel: '00:00 - 06:00',
        startHour: 0,
        endHour: 5,
        icon: Icons.nightlight_round,
        color: Color(0xFF818CF8),
        gradientColors: [Color(0xFF6366F1), Color(0xFF818CF8)],
      ),
      const _TimeSlot(
        title: 'Mañana',
        rangeLabel: '06:00 - 12:00',
        startHour: 6,
        endHour: 11,
        icon: Icons.wb_twilight_rounded,
        color: AppColors.tertiary,
        gradientColors: [Color(0xFFF59E0B), AppColors.tertiary],
      ),
      const _TimeSlot(
        title: 'Tarde',
        rangeLabel: '12:00 - 18:00',
        startHour: 12,
        endHour: 17,
        icon: Icons.wb_sunny_rounded,
        color: AppColors.primary,
        gradientColors: [Color(0xFF10B981), AppColors.primary],
      ),
      const _TimeSlot(
        title: 'Noche',
        rangeLabel: '18:00 - 24:00',
        startHour: 18,
        endHour: 23,
        icon: Icons.nights_stay_rounded,
        color: AppColors.secondary,
        gradientColors: [Color(0xFF0284C7), AppColors.secondary],
      ),
    ];

    // Compute stats per slot
    final slotCounts = <int>[];
    int maxSlotCount = 0;
    int peakSlotIndex = 0;
    for (int i = 0; i < slots.length; i++) {
      final slot = slots[i];
      int sum = 0;
      for (int h = slot.startHour; h <= slot.endHour; h++) {
        sum += hourMap[h] ?? 0;
      }
      slotCounts.add(sum);
      if (sum > maxSlotCount) {
        maxSlotCount = sum;
        peakSlotIndex = i;
      }
    }

    final numberFormat = NumberFormat.decimalPattern();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Mode Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISTRIBUCIÓN POR FRANJAS DEL DÍA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (totalMessages > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: AppColors.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Pico: ${peakHour.toString().padLeft(2, '0')}:00h (${numberFormat.format(peakHourCount)} msgs)',
                            style: const TextStyle(
                              color: AppColors.tertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // View Switcher Pill
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.6,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewToggleButton(
                      icon: Icons.view_agenda_rounded,
                      tooltip: 'Por Franjas (Vertical)',
                      isSelected: _viewMode == _HourlyViewMode.slots,
                      onTap: () =>
                          setState(() => _viewMode = _HourlyViewMode.slots),
                    ),
                    _ViewToggleButton(
                      icon: Icons.show_chart_rounded,
                      tooltip: 'Curva 24 Horas',
                      isSelected: _viewMode == _HourlyViewMode.curve,
                      onTap: () =>
                          setState(() => _viewMode = _HourlyViewMode.curve),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content according to mode
          if (_viewMode == _HourlyViewMode.slots)
            _buildSlotsView(
              slots: slots,
              slotCounts: slotCounts,
              maxSlotCount: maxSlotCount,
              peakSlotIndex: peakSlotIndex,
              totalMessages: totalMessages,
              hourMap: hourMap,
              numberFormat: numberFormat,
            )
          else
            _buildCurveView(
              hourMap: hourMap,
              peakHourCount: peakHourCount,
            ),
        ],
      ),
    );
  }

  Widget _buildSlotsView({
    required List<_TimeSlot> slots,
    required List<int> slotCounts,
    required int maxSlotCount,
    required int peakSlotIndex,
    required int totalMessages,
    required Map<int, int> hourMap,
    required NumberFormat numberFormat,
  }) {
    return Column(
      children: [
        for (int i = 0; i < slots.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _FranjaCard(
            slot: slots[i],
            count: slotCounts[i],
            totalMessages: totalMessages,
            maxSlotCount: maxSlotCount,
            isPeakSlot: i == peakSlotIndex && slotCounts[i] > 0,
            isExpanded: _expandedSlotIndex == i,
            hourMap: hourMap,
            numberFormat: numberFormat,
            onTap: () {
              setState(() {
                _expandedSlotIndex = _expandedSlotIndex == i ? null : i;
              });
            },
          ),
        ],
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 13,
              color: AppColors.outline,
            ),
            SizedBox(width: 4),
            Text(
              'Toca una franja para ver el desglose por horas',
              style: TextStyle(
                color: AppColors.outline,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurveView({
    required Map<int, int> hourMap,
    required int peakHourCount,
  }) {
    final spots = <FlSpot>[];
    for (int h = 0; h < 24; h++) {
      spots.add(FlSpot(h.toDouble(), (hourMap[h] ?? 0).toDouble()));
    }

    final maxY = (peakHourCount * 1.25).clamp(5.0, double.infinity);

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 23,
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 4,
                getTitlesWidget: (value, meta) {
                  final h = value.toInt();
                  if (h >= 0 && h < 24 && (h % 4 == 0 || h == 23)) {
                    return Text(
                      '${h.toString().padLeft(2, '0')}h',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceContainerHighest,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final h = spot.x.toInt().toString().padLeft(2, '0');
                  final count = spot.y.toInt();
                  return LineTooltipItem(
                    '$h:00h\n$count msgs',
                    const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.35),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlot {
  final String title;
  final String rangeLabel;
  final int startHour;
  final int endHour;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const _TimeSlot({
    required this.title,
    required this.rangeLabel,
    required this.startHour,
    required this.endHour,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });
}

class _FranjaCard extends StatelessWidget {
  final _TimeSlot slot;
  final int count;
  final int totalMessages;
  final int maxSlotCount;
  final bool isPeakSlot;
  final bool isExpanded;
  final Map<int, int> hourMap;
  final NumberFormat numberFormat;
  final VoidCallback onTap;

  const _FranjaCard({
    required this.slot,
    required this.count,
    required this.totalMessages,
    required this.maxSlotCount,
    required this.isPeakSlot,
    required this.isExpanded,
    required this.hourMap,
    required this.numberFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalMessages > 0 ? (count / totalMessages) : 0.0;
    final barFactor = maxSlotCount > 0 ? (count / maxSlotCount) : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isExpanded
                ? AppColors.surfaceContainerHigh
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded
                  ? slot.color.withValues(alpha: 0.5)
                  : isPeakSlot
                      ? slot.color.withValues(alpha: 0.3)
                      : AppColors.outlineVariant.withValues(alpha: 0.4),
              width: isExpanded || isPeakSlot ? 1.0 : 0.6,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: slot.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: slot.color.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(slot.icon, color: slot.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              slot.title,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (isPeakSlot) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.tertiary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.tertiary
                                        .withValues(alpha: 0.4),
                                    width: 0.6,
                                  ),
                                ),
                                child: const Text(
                                  'PICO',
                                  style: TextStyle(
                                    color: AppColors.tertiary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          slot.rangeLabel,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${numberFormat.format(count)} msgs',
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(pct * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isPeakSlot
                              ? slot.color
                              : AppColors.onSurfaceVariant,
                          fontWeight:
                              isPeakSlot ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.outline,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: AppColors.surfaceContainerHighest,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: barFactor.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: slot.gradientColors,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Expanded breakdown (6 hours)
              if (isExpanded) ...[
                const SizedBox(height: 14),
                _SlotHourBreakdown(
                  slot: slot,
                  hourMap: hourMap,
                  numberFormat: numberFormat,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotHourBreakdown extends StatelessWidget {
  final _TimeSlot slot;
  final Map<int, int> hourMap;
  final NumberFormat numberFormat;

  const _SlotHourBreakdown({
    required this.slot,
    required this.hourMap,
    required this.numberFormat,
  });

  @override
  Widget build(BuildContext context) {
    int maxInSlot = 1;
    for (int h = slot.startHour; h <= slot.endHour; h++) {
      final c = hourMap[h] ?? 0;
      if (c > maxInSlot) maxInSlot = c;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Desglose por horas (${slot.rangeLabel}):',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int h = slot.startHour; h <= slot.endHour; h++) ...[
                Expanded(
                  child: _HourColumn(
                    hour: h,
                    count: hourMap[h] ?? 0,
                    maxInSlot: maxInSlot,
                    slot: slot,
                    numberFormat: numberFormat,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HourColumn extends StatelessWidget {
  final int hour;
  final int count;
  final int maxInSlot;
  final _TimeSlot slot;
  final NumberFormat numberFormat;

  const _HourColumn({
    required this.hour,
    required this.count,
    required this.maxInSlot,
    required this.slot,
    required this.numberFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isSlotMax = count == maxInSlot && count > 0;
    final heightFactor =
        maxInSlot > 0 ? (count / maxInSlot).clamp(0.08, 1.0) : 0.08;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              numberFormat.format(count),
              style: TextStyle(
                color: isSlotMax ? slot.color : AppColors.onSurfaceVariant,
                fontSize: 10,
                fontWeight: isSlotMax ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 46,
            width: 14,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isSlotMax
                        ? slot.gradientColors
                        : [
                            slot.color.withValues(alpha: 0.4),
                            slot.color.withValues(alpha: 0.7),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${hour.toString().padLeft(2, '0')}h',
            style: TextStyle(
              color: isSlotMax ? slot.color : AppColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: isSlotMax ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color:
            isSelected ? AppColors.surfaceContainerHighest : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
          ),
        ),
      ),
    );
  }
}
