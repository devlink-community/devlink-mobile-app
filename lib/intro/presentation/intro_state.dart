import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/model/focus_time_stats.dart';

part 'intro_state.freezed.dart';

@freezed
class IntroState with _$IntroState {
  const IntroState({
    /// 프로필 정보 로딩/성공/실패 상태
    this.userProfile = const AsyncLoading(),

    /// 통계 정보 로딩/성공/실패 상태
    this.focusStats = const AsyncLoading(),
  });

  final AsyncValue<Member> userProfile;
  final AsyncValue<FocusTimeStats> focusStats;
}
