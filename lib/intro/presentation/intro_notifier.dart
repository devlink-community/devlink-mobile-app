import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/model/member.dart';
import '../domain/model/focus_time_stats.dart';
import '../domain/use_case/fetch_intro_data_use_case.dart';
import '../domain/use_case/fetch_intro_stats_use_case.dart';
import '../module/intro_di.dart';
import 'intro_action.dart';
import 'intro_state.dart';

// Assume Member, FocusTimeStats, use case providers are defined elsewhere.
/// 1) AsyncNotifierProvider 정의
final introNotifierProvider = AsyncNotifierProvider<IntroNotifier, IntroState>(
  IntroNotifier.new,
);

/// 2) AsyncNotifier 구현
class IntroNotifier extends AsyncNotifier<IntroState> {
  late final FetchIntroUserUseCase _fetchUserUseCase;
  late final FetchIntroStatsUseCase _fetchStatsUseCase;

  @override
  Future<IntroState> build() async {
    // 2-1) UseCase 인스턴스 가져오기
    _fetchUserUseCase = ref.watch(fetchIntroUserUseCaseProvider);
    _fetchStatsUseCase = ref.watch(fetchIntroStatsUseCaseProvider);

    // 2-2) AsyncValue 초기화
    late AsyncValue<Member> userProfileResult;
    late AsyncValue<FocusTimeStats> focusStatsResult;

    // 2-3) 프로필 로드
    try {
      // execute()가 Future<AsyncValue<Member>> 반환
      userProfileResult = await _fetchUserUseCase.execute();
    } catch (e, st) {
      userProfileResult = AsyncValue.error(e, st);
    }

    // 2-4) 통계 로드
    try {
      focusStatsResult = await _fetchStatsUseCase.execute();
    } catch (e, st) {
      focusStatsResult = AsyncValue.error(e, st);
    }

    // 2-5) 최종 상태 반환
    return IntroState(
      userProfile: userProfileResult,
      focusStats: focusStatsResult,
    );
  }

  /// 3) 화면 액션 처리
  Future<void> onAction(IntroAction action) async {
    switch (action) {
      case OpenSettings():
        // 네비게이션은 UI 쪽에서 처리
        break;
      case RefreshIntro():
        // 전체 다시 로드: build를 다시 트리거
        state = const AsyncLoading();
        final newState = await build();
        state = AsyncData(newState);
        break;
    }
  }
}
