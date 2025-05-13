import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const SettingsState({
    // 로그아웃 처리 상태
    this.logoutResult = const AsyncData(null),

    // 회원탈퇴 처리 상태
    this.deleteAccountResult = const AsyncData(null),
  });

  final AsyncValue<void> logoutResult;
  final AsyncValue<void> deleteAccountResult;
}
