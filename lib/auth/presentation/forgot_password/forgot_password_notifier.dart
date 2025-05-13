// lib/auth/presentation/forgot_password/forgot_password_notifier.dart
import 'package:devlink_mobile_app/auth/domain/usecase/reset_password_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/validate_email_use_case.dart';
import 'package:devlink_mobile_app/auth/module/auth_di.dart';
import 'package:devlink_mobile_app/auth/presentation/forgot_password/forgot_password_action.dart';
import 'package:devlink_mobile_app/auth/presentation/forgot_password/forgot_password_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forgot_password_notifier.g.dart';

@riverpod
class ForgotPasswordNotifier extends _$ForgotPasswordNotifier {
  late final ResetPasswordUseCase _resetPasswordUseCase;
  late final ValidateEmailUseCase _validateEmailUseCase;

  @override
  ForgotPasswordState build() {
    _resetPasswordUseCase = ref.watch(resetPasswordUseCaseProvider);
    _validateEmailUseCase = ref.watch(validateEmailUseCaseProvider);
    return const ForgotPasswordState();
  }

  Future<void> onAction(ForgotPasswordAction action) async {
    switch (action) {
      case EmailChangedAction(:final email):
        state = state.copyWith(
          email: email,
          emailError: null,
        );

      case EmailFocusChangedAction(:final hasFocus):
        if (!hasFocus && state.email.isNotEmpty) {
          final error = await _validateEmailUseCase.execute(state.email);
          state = state.copyWith(emailError: error);
        }

      case SendResetEmailAction():
        await _performResetPassword();

      case NavigateToLoginAction():
      // Root에서 처리됨
        break;
    }
  }

  Future<void> _performResetPassword() async {
    // 이메일 유효성 검증
    final emailError = await _validateEmailUseCase.execute(state.email);
    state = state.copyWith(emailError: emailError);

    // 이메일이 유효하지 않으면 중단
    if (emailError != null) {
      return;
    }

    // 비밀번호 재설정 이메일 전송
    state = state.copyWith(
      resetPasswordResult: const AsyncLoading(),
      successMessage: null, // 전송 시작할 때 성공 메시지 초기화
    );

    // 이메일 주소는 그대로 전달하고 소문자 변환은 DataSource에서 처리
    final result = await _resetPasswordUseCase.execute(state.email);

    // 성공 시 메시지 설정
    if (result is AsyncData) {
      state = state.copyWith(
        resetPasswordResult: result,
        successMessage: '비밀번호 재설정 이메일이 발송되었습니다. 이메일을 확인해주세요.',
      );
    } else {
      state = state.copyWith(resetPasswordResult: result);
    }
  }

  void resetForm() {
    state = const ForgotPasswordState();
  }
}