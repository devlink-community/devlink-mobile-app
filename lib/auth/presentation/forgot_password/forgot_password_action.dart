// lib/auth/presentation/forgot_password/forgot_password_action.dart (수정)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_action.freezed.dart';

@freezed
class ForgotPasswordAction with _$ForgotPasswordAction {
  const factory ForgotPasswordAction.emailChanged(String email) = EmailChangedAction;
  const factory ForgotPasswordAction.emailFocusChanged(bool hasFocus) = EmailFocusChangedAction;
  const factory ForgotPasswordAction.sendResetEmail() = SendResetEmailAction;
  const factory ForgotPasswordAction.navigateToLogin() = NavigateToLoginAction;
}