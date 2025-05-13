import '../dto/focus_time_stats_dto.dart';

abstract interface class FocusTimeDataSource {
  /// 집중 시간 통계 정보를 조회
  Future<FocusTimeStatsDto> fetchFocusTimeStats();
}
