// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/games/service/game_service.dart';

class AnalysChart extends StatefulWidget {
  final MaterialColor chartColor;
  final String gameId;

  const AnalysChart({
    super.key,
    this.chartColor = Colors.green,
    required this.gameId,
  });

  @override
  State<AnalysChart> createState() => _AnalysChartState();
}

class _AnalysChartState extends State<AnalysChart> {
  final _gameService = GameService();
  Map<String, double> _weeklyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _gameService.getWeeklyGameData(widget.gameId);
    if (mounted) {
      setState(() {
        _weeklyData = data;
        _isLoading = false;
      });
    }
  }

  List<FlSpot> _getChartData() {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final value = _weeklyData[dateKey] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    if (_isLoading) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: ThemeConstants.darkGreyColor,
        ),
        child: Center(
          child: CircularProgressIndicator(color: widget.chartColor),
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: ThemeConstants.darkGreyColor,
      ),
      child: Container(
        padding: const EdgeInsets.only(
          left: 12,
          right: 22,
          top: 20,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: ThemeConstants.darkGreyColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: LineChart(
          LineChartData(
            maxY: 10.0,
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: _getChartData(),
                gradient: LinearGradient(
                  colors: [
                    widget.chartColor.shade400,
                    widget.chartColor.shade600,
                    widget.chartColor.shade500,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                curveSmoothness: 0.35,
                isCurved: true,
                preventCurveOverShooting: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      widget.chartColor.shade400.withOpacity(0.3),
                      widget.chartColor.shade600.withOpacity(0.1),
                      widget.chartColor.shade500.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < weekDays.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          weekDays[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    return Container(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1,
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: widget.chartColor.shade700.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              },
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: widget.chartColor.shade700.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
