import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/result/result.dart';
import '../model/focus_time_stats.dart';
import '../repository/intro_repository.dart';

class FetchIntroStatsUseCase {
  final IntroRepository _repo;

  FetchIntroStatsUseCase(this._repo);

  Future<AsyncValue<FocusTimeStats>> execute() async {
    final result = await _repo.fetchFocusTimeStats();
    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, StackTrace.current);
    }
  }
}
