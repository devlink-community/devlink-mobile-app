// lib/auth/presentation/forgot_password/forgot_password_state.dart (수정)
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'forgot_password_state.freezed.dart';

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.resetPasswordResult,
    this.successMessage, // 성공 메시지 필드 추가
  });

  final String email;
  final String? emailError;
  final AsyncValue<void>? resetPasswordResult;
  final String? successMessage; // 성공 메시지 저장 필드
}