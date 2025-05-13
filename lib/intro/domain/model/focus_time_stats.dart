// lib/profile/domain/model/focus_time_stats.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_time_stats.freezed.dart';

@freezed
class FocusTimeStats with _$FocusTimeStats {
  const FocusTimeStats({
    required this.totalMinutes,
    required this.weeklyMinutes,
  });

  /// 총 집중 시간(분)
  final int totalMinutes;

  /// 요일별 집중 시간 통계
  final Map<String, int> weeklyMinutes;
}
