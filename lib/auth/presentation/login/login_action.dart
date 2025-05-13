import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_action.freezed.dart';

@freezed
sealed class LoginAction with _$LoginAction {
  const factory LoginAction.loginPressed({
    required String email,
    required String password,
  }) = LoginPressed;

  const factory LoginAction.navigateToForgetPassword() =
      NavigateToForgetPassword;

  const factory LoginAction.navigateToSignUp() = NavigateToSignUp;
}
