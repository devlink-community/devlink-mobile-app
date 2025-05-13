// lib/auth/presentation/signup/signup_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_action.freezed.dart';

@freezed
sealed class SignupAction with _$SignupAction {
  // 폼 입력값 변경
  const factory SignupAction.nicknameChanged(String nickname) = NicknameChanged;
  const factory SignupAction.emailChanged(String email) = EmailChanged;
  const factory SignupAction.passwordChanged(String password) = PasswordChanged;
  const factory SignupAction.passwordConfirmChanged(String passwordConfirm) = PasswordConfirmChanged;
  const factory SignupAction.agreeToTermsChanged(bool agree) = AgreeToTermsChanged;

  // 포커스 이동 (필드 유효성 검증 트리거)
  const factory SignupAction.nicknameFocusChanged(bool hasFocus) = NicknameFocusChanged;
  const factory SignupAction.emailFocusChanged(bool hasFocus) = EmailFocusChanged;
  const factory SignupAction.passwordFocusChanged(bool hasFocus) = PasswordFocusChanged;
  const factory SignupAction.passwordConfirmFocusChanged(bool hasFocus) = PasswordConfirmFocusChanged;

  // 중복 확인
  const factory SignupAction.checkNicknameAvailability() = CheckNicknameAvailability;
  const factory SignupAction.checkEmailAvailability() = CheckEmailAvailability;

  // 회원가입 제출
  const factory SignupAction.submit() = Submit;

  // 화면 이동
  const factory SignupAction.navigateToLogin() = NavigateToLogin;
  const factory SignupAction.navigateToTerms() = NavigateToTerms;
}