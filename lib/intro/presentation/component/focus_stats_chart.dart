import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/model/focus_time_stats.dart';

class FocusStatsChart extends StatelessWidget {
  final FocusTimeStats stats;

  const FocusStatsChart({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1) 원본 데이터 정렬
    final entries =
        stats.weeklyMinutes.entries.toList()..sort(
          (a, b) => _weekdayIndex(a.key).compareTo(_weekdayIndex(b.key)),
        );

    // 2) 최대값 계산
    final maxVal = entries
        .map((e) => e.value.toDouble())
        .fold<double>(0, (prev, curr) => max(prev, curr));

    // 3) 색상 정의
    final fillColor = const Color(0xFF5D5FEF);
    final bgColor = fillColor.withOpacity(0.2);

    // 4) 한글 요일 배열 (0→월, 1→화, …)
    const korDays = ['월', '화', '수', '목', '금', '토', '일'];

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxVal,
          // 터치 툴팁 가독성 설정
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              tooltipRoundedRadius: 6,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final idx = group.x.toInt();
                final kor = korDays[idx];
                final minutes = rod.toY.toInt();
                return BarTooltipItem(
                  '$kor\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '$minutes분',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          // 축 레이블: 아래만 한글 요일 표시
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= korDays.length) return const SizedBox();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      korDays[idx],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Bar 그룹 생성
          barGroups:
              entries.asMap().entries.map((entry) {
                final idx = entry.key;
                final minutes = entry.value.value.toDouble();
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: minutes,
                      width: 16,
                      borderRadius: BorderRadius.circular(8),
                      color: fillColor,
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxVal,
                        color: bgColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  int _weekdayIndex(String day) {
    const order = ['월', '화', '수', '목', '금', '토', '일'];
    return order.indexOf(day);
  }
}
