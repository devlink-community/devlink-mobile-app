// lib/auth/presentation/signup/signup_state.dart
import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'signup_state.freezed.dart';

@freezed
class SignupState with _$SignupState {
  const SignupState({
    // 입력 필드 값
    this.nickname = '',
    this.email = '',
    this.password = '',
    this.passwordConfirm = '',
    this.agreeToTerms = false,

    // 유효성 검증 에러 메시지
    this.nicknameError,
    this.emailError,
    this.passwordError,
    this.passwordConfirmError,
    this.termsError,

    // 중복 검사 결과
    this.nicknameAvailability,
    this.emailAvailability,

    // 회원가입 진행 상태
    this.signupResult,

    // 약관 동의 ID 추가
    this.agreedTermsId,
    this.isTermsAgreed = false,
  });

  final String nickname;
  final String email;
  final String password;
  final String passwordConfirm;
  final bool agreeToTerms;

  final String? nicknameError;
  final String? emailError;
  final String? passwordError;
  final String? passwordConfirmError;
  final String? termsError;

  final AsyncValue<bool>? nicknameAvailability;
  final AsyncValue<bool>? emailAvailability;

  final AsyncValue<Member>? signupResult;

  final String? agreedTermsId;
  final bool isTermsAgreed; // 약관 동의 여부
}