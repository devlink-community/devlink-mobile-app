import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_action.freezed.dart';

@freezed
sealed class SettingsAction with _$SettingsAction {
  // 프로필 수정 화면으로 이동
  const factory SettingsAction.onTapEditProfile() = OnTapEditProfile;

  // 비밀번호 변경 화면으로 이동
  const factory SettingsAction.onTapChangePassword() = OnTapChangePassword;

  // 개인정보 처리방침 화면으로 이동
  const factory SettingsAction.onTapPrivacyPolicy() = OnTapPrivacyPolicy;

  // 앱 정보 화면으로 이동
  const factory SettingsAction.onTapAppInfo() = OnTapAppInfo;

  // 로그아웃 요청
  const factory SettingsAction.onTapLogout() = OnTapLogout;

  // 회원탈퇴 요청
  const factory SettingsAction.onTapDeleteAccount() = OnTapDeleteAccount;

  // URL 연결 액션 추가
  const factory SettingsAction.openUrlPrivacyPolicy() = OpenUrlPrivacyPolicy;

  const factory SettingsAction.openUrlAppInfo() = OpenUrlAppInfo;
}
