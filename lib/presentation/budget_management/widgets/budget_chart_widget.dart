import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BudgetChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> budgetData;
  final String chartType;

  const BudgetChartWidget({
    Key? key,
    required this.budgetData,
    this.chartType = 'pie',
  }) : super(key: key);

  @override
  State<BudgetChartWidget> createState() => _BudgetChartWidgetState();
}

class _BudgetChartWidgetState extends State<BudgetChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        height: 35.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distribuição do Orçamento',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.chartType == 'pie' ? 'Pizza' : 'Barras',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: widget.chartType == 'pie'
                  ? _buildPieChart()
                  : _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 8.w,
              sections: _getPieSections(),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildLegend(),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: widget.budgetData
                .map((e) => (e['allocated'] as num).toDouble())
                .reduce((a, b) => a > b ? a : b) *
            1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < widget.budgetData.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      widget.budgetData[value.toInt()]['category']
                          .toString()
                          .substring(0, 3),
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 10.w,
              getTitlesWidget: (value, meta) {
                return Text(
                  'R\$${(value / 1000).toStringAsFixed(0)}k',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _getBarGroups(),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections() {
    final total = widget.budgetData.fold<double>(
        0, (sum, item) => sum + (item['allocated'] as num).toDouble());

    return widget.budgetData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final value = (data['allocated'] as num).toDouble();
      final percentage = (value / total) * 100;
      final isTouched = index == touchedIndex;

      return PieChartSectionData(
        color: _getColorForIndex(index),
        value: value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 12.w : 10.w,
        titleStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _getBarGroups() {
    return widget.budgetData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final allocated = (data['allocated'] as num).toDouble();
      final spent = (data['spent'] as num).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: allocated,
            color: _getColorForIndex(index).withValues(alpha: 0.3),
            width: 4.w,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: spent,
            color: _getColorForIndex(index),
            width: 4.w,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    return widget.budgetData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
        child: Row(
          children: [
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: _getColorForIndex(index),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                data['category'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.lightTheme.colorScheme.primary,
      AppTheme.lightTheme.colorScheme.secondary,
      AppTheme.getAccentColor(true),
      AppTheme.getSuccessColor(true),
      AppTheme.getWarningColor(true),
      AppTheme.lightTheme.colorScheme.error,
    ];
    return colors[index % colors.length];
  }
}
