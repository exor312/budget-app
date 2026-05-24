import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';

/// Time range options for the spending chart.
enum ChartTimeRange {
  week,
  month,
  threeMonths,
  sixMonths,
  year,
}

/// Simple date range holder.
class _DateRange {
  final DateTime start;
  final DateTime end;
  _DateRange(this.start, this.end);
}

/// A spending chart widget that shows expenses over time using fl_chart.
/// Supports multiple time ranges: Week, Month, 3M, 6M, Year.
class SpendingChartCard extends StatefulWidget {
  const SpendingChartCard({
    super.key,
    required this.getDailySpending,
    required this.getMonthlySpending,
  });

  /// Callback that returns daily spending for a given date range.
  final List<MapEntry<DateTime, double>> Function({
    required DateTime start,
    required DateTime end,
  }) getDailySpending;

  /// Callback that returns monthly spending for a given date range.
  final List<MapEntry<DateTime, double>> Function({
    required DateTime start,
    required DateTime end,
  }) getMonthlySpending;

  @override
  State<SpendingChartCard> createState() => _SpendingChartCardState();
}

class _SpendingChartCardState extends State<SpendingChartCard> {
  ChartTimeRange _selectedRange = ChartTimeRange.month;

  _DateRange _getDateRange() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case ChartTimeRange.week:
        return _DateRange(
          now.subtract(const Duration(days: 6)),
          now,
        );
      case ChartTimeRange.month:
        return _DateRange(
          DateTime(now.year, now.month, 1),
          now,
        );
      case ChartTimeRange.threeMonths:
        return _DateRange(
          DateTime(now.year, now.month - 2, 1),
          now,
        );
      case ChartTimeRange.sixMonths:
        return _DateRange(
          DateTime(now.year, now.month - 5, 1),
          now,
        );
      case ChartTimeRange.year:
        return _DateRange(
          DateTime(now.year - 1, now.month, 1),
          now,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = _getDateRange();
    final useDaily = _selectedRange == ChartTimeRange.week ||
        _selectedRange == ChartTimeRange.month;

    final data = useDaily
        ? widget.getDailySpending(start: range.start, end: range.end)
        : widget.getMonthlySpending(start: range.start, end: range.end);

    final totalSpent = data.fold(0.0, (sum, e) => sum + e.value);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: FortunaColors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: FortunaColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Overview',
                style: FortunaTextStyles.titleMd.copyWith(
                  color: FortunaColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _formatCurrency(totalSpent),
                style: FortunaTextStyles.titleMd.copyWith(
                  color: FortunaColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _rangeLabel(_selectedRange),
            style: TextStyle(
              fontSize: 12,
              color: FortunaColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildRangeSelector(),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: data.isEmpty
                ? _buildEmptyChart()
                : _buildChart(data, useDaily, range),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSelector() {
    return Row(
      children: ChartTimeRange.values.map((range) {
        final isSelected = _selectedRange == range;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRange = range),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? FortunaColors.secondaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? FortunaColors.primary.withValues(alpha: 0.3)
                      : FortunaColors.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  _rangeShortLabel(range),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? FortunaColors.primary
                        : FortunaColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.3),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'No spending data for this period',
            style: TextStyle(
              color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    List<MapEntry<DateTime, double>> data,
    bool useDaily,
    _DateRange range,
  ) {
    final spots = <FlSpot>[];
    final labels = <String>[];
    final borders = <DateTime>[];

    if (useDaily) {
      final totalDays = range.end.difference(range.start).inDays + 1;
      final dataMap = <String, double>{};
      for (final e in data) {
        final key = _dayKey(e.key);
        dataMap[key] = (dataMap[key] ?? 0) + e.value;
      }

      for (int i = 0; i < totalDays; i++) {
        final date = range.start.add(Duration(days: i));
        final key = _dayKey(date);
        final value = dataMap[key] ?? 0;
        spots.add(FlSpot(i.toDouble(), value));

        if (i == 0 ||
            i == totalDays - 1 ||
            i % ((totalDays / 5).ceil().clamp(1, totalDays)) == 0) {
          labels.add('${date.month}/${date.day}');
          borders.add(date);
        } else {
          labels.add('');
          borders.add(date);
        }
      }
    } else {
      var current = DateTime(range.start.year, range.start.month);
      final end = DateTime(range.end.year, range.end.month);
      final dataMap = <String, double>{};
      for (final e in data) {
        final key = _monthKey(e.key);
        dataMap[key] = (dataMap[key] ?? 0) + e.value;
      }

      int index = 0;
      while (!current.isAfter(end)) {
        final key = _monthKey(current);
        final value = dataMap[key] ?? 0;
        spots.add(FlSpot(index.toDouble(), value));

        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        labels.add(months[current.month - 1]);
        borders.add(current);

        current = DateTime(current.year, current.month + 1);
        index++;
      }
    }

    final maxY = spots.isEmpty
        ? 100.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;
    final chartMaxY = maxY < 10 ? 10.0 : maxY;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: chartMaxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: FortunaColors.outlineVariant.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length || labels[i].isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: FortunaColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: chartMaxY / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCompact(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: FortunaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
        minY: 0,
        maxY: chartMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: FortunaColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: spot.y > 0 ? 4 : 0,
                  color: FortunaColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  FortunaColors.primary.withValues(alpha: 0.15),
                  FortunaColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => FortunaColors.surfaceContainerHigh
                .withValues(alpha: 0.95),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final i = touchedSpot.x.toInt();
                if (i < 0 || i >= borders.length) return null;
                final date = borders[i];
                final dateStr = useDaily
                    ? '${date.month}/${date.day}/${date.year}'
                    : '${_monthName(date.month)} ${date.year}';
                return LineTooltipItem(
                  '$dateStr\n\$${_formatCurrency(touchedSpot.y)}',
                  const TextStyle(
                    color: FortunaColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  String _monthKey(DateTime d) => '${d.year}-${d.month}';

  String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m - 1];
  }

  String _rangeLabel(ChartTimeRange range) {
    switch (range) {
      case ChartTimeRange.week:
        return 'Last 7 days';
      case ChartTimeRange.month:
        return 'Current month';
      case ChartTimeRange.threeMonths:
        return 'Last 3 months';
      case ChartTimeRange.sixMonths:
        return 'Last 6 months';
      case ChartTimeRange.year:
        return 'Last 12 months';
    }
  }

  String _rangeShortLabel(ChartTimeRange range) {
    switch (range) {
      case ChartTimeRange.week:
        return '7D';
      case ChartTimeRange.month:
        return '1M';
      case ChartTimeRange.threeMonths:
        return '3M';
      case ChartTimeRange.sixMonths:
        return '6M';
      case ChartTimeRange.year:
        return '1Y';
    }
  }

  String _formatCurrency(double value) {
    if (value == 0) return '\$0.00';
    final isNeg = value < 0;
    final abs = value.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    String formatted = '';
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) formatted += ',';
      formatted += intPart[i];
    }
    return '${isNeg ? '-' : ''}\$$formatted.$decPart';
  }

  String _formatCompact(double value) {
    if (value == 0) return '\$0';
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}k';
    }
    return '\$${value.toInt()}';
  }
}
