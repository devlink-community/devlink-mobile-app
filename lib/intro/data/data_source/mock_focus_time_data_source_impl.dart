import '../dto/focus_time_stats_dto.dart';
import 'focus_time_data_source.dart';

class MockFocusTimeDataSourceImpl implements FocusTimeDataSource {
  @override
  Future<FocusTimeStatsDto> fetchFocusTimeStats() async {
    // 네트워크 지연 효과를 주고 싶다면 Future.delayed 추가 가능
    return Future.value(
      FocusTimeStatsDto(
        totalMinutes: 1234,
        weeklyMinutes: {
          'Mon': 120,
          'Tue': 150,
          'Wed': 90,
          'Thu': 200,
          'Fri': 180,
          'Sat': 300,
          'Sun': 294,
        },
      ),
    );
  }
}
