import 'package:json_annotation/json_annotation.dart';
part 'focus_time_stats_dto.g.dart';

@JsonSerializable()
class FocusTimeStatsDto {
  final int? totalMinutes;
  final Map<String, int>? weeklyMinutes;
  // ... 기타 통계 필드

  FocusTimeStatsDto({this.totalMinutes, this.weeklyMinutes});

  factory FocusTimeStatsDto.fromJson(Map<String, dynamic> json) =>
      _$FocusTimeStatsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FocusTimeStatsDtoToJson(this);
}
