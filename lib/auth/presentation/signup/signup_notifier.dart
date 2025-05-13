// lib/auth/presentation/signup/signup_notifier.dart
import 'package:devlink_mobile_app/auth/domain/usecase/check_email_availability_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/check_nickname_availability_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/signup_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/validate_email_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/validate_nickname_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/validate_password_confirm_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/validate_password_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/validate_terms_agreement_use_case.dart';
import 'package:devlink_mobile_app/auth/module/auth_di.dart';
import 'package:devlink_mobile_app/auth/presentation/signup/signup_action.dart';
import 'package:devlink_mobile_app/auth/presentation/signup/signup_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_notifier.g.dart';

@riverpod
class SignupNotifier extends _$SignupNotifier {
  late final SignupUseCase _signupUseCase;
  late final CheckNicknameAvailabilityUseCase _checkNicknameAvailabilityUseCase;
  late final CheckEmailAvailabilityUseCase _checkEmailAvailabilityUseCase;
  late final ValidateNicknameUseCase _validateNicknameUseCase;
  late final ValidateEmailUseCase _validateEmailUseCase;
  late final ValidatePasswordUseCase _validatePasswordUseCase;
  late final ValidatePasswordConfirmUseCase _validatePasswordConfirmUseCase;
  late final ValidateTermsAgreementUseCase _validateTermsAgreementUseCase;

  @override
  SignupState build() {
    _signupUseCase = ref.watch(signupUseCaseProvider);
    _checkNicknameAvailabilityUseCase = ref.watch(
      checkNicknameAvailabilityUseCaseProvider,
    );
    _checkEmailAvailabilityUseCase = ref.watch(
      checkEmailAvailabilityUseCaseProvider,
    );
    _validateNicknameUseCase = ref.watch(validateNicknameUseCaseProvider);
    _validateEmailUseCase = ref.watch(validateEmailUseCaseProvider);
    _validatePasswordUseCase = ref.watch(validatePasswordUseCaseProvider);
    _validatePasswordConfirmUseCase = ref.watch(
      validatePasswordConfirmUseCaseProvider,
    );
    _validateTermsAgreementUseCase = ref.watch(
      validateTermsAgreementUseCaseProvider,
    );

    return const SignupState();
  }

  Future<void> onAction(SignupAction action) async {
    switch (action) {
    // 폼 입력값 변경 액션 처리
      case NicknameChanged(:final nickname):
        state = state.copyWith(
          nickname: nickname,
          nicknameError: null, // 사용자가 입력 중이면 에러 메시지 제거
        );

      case EmailChanged(:final email):
      // 사용자 편의성을 위해 입력 중에는 원래 입력값 유지
        state = state.copyWith(
          email: email,
          emailError: null, // 사용자가 입력 중이면 에러 메시지 제거
        );

      case PasswordChanged(:final password):
        state = state.copyWith(
          password: password,
          passwordError: null, // 사용자가 입력 중이면 에러 메시지 제거
          // 비밀번호가 변경되면 비밀번호 확인 유효성도 다시 검증
          passwordConfirmError:
          state.passwordConfirm.isEmpty
              ? null
              : await _validatePasswordConfirmUseCase.execute(
            password,
            state.passwordConfirm,
          ),
        );

      case PasswordConfirmChanged(:final passwordConfirm):
        state = state.copyWith(
          passwordConfirm: passwordConfirm,
          passwordConfirmError: null, // 사용자가 입력 중이면 에러 메시지 제거
        );

      case AgreeToTermsChanged(:final agree):
        state = state.copyWith(
          agreeToTerms: agree,
          termsError: null, // 사용자가 체크하면 에러 메시지 제거
        );

    // 포커스 변경 액션 처리 (필드 유효성 검증)
      case NicknameFocusChanged(:final hasFocus):
        if (!hasFocus && state.nickname.isNotEmpty) {
          // 포커스를 잃을 때만 유효성 검증
          final error = await _validateNicknameUseCase.execute(state.nickname);
          state = state.copyWith(nicknameError: error);

          // 닉네임이 유효하면 중복 확인
          if (error == null) {
            await _performNicknameAvailabilityCheck();
          }
        }

      case EmailFocusChanged(:final hasFocus):
        if (!hasFocus && state.email.isNotEmpty) {
          // 포커스를 잃을 때만 유효성 검증
          // 이메일 주소는 데이터 저장/조회 시 소문자로 변환되지만
          // 화면 표시는 사용자 입력 그대로 유지
          final error = await _validateEmailUseCase.execute(state.email);
          state = state.copyWith(emailError: error);

          // 이메일이 유효하면 중복 확인
          if (error == null) {
            await _performEmailAvailabilityCheck();
          }
        }

      case PasswordFocusChanged(:final hasFocus):
        if (!hasFocus && state.password.isNotEmpty) {
          // 포커스를 잃을 때만 유효성 검증
          final error = await _validatePasswordUseCase.execute(state.password);
          state = state.copyWith(passwordError: error);
        }

      case PasswordConfirmFocusChanged(:final hasFocus):
        if (!hasFocus && state.passwordConfirm.isNotEmpty) {
          // 포커스를 잃을 때만 유효성 검증
          final error = await _validatePasswordConfirmUseCase.execute(
            state.password,
            state.passwordConfirm,
          );
          state = state.copyWith(passwordConfirmError: error);
        }

    // 중복 확인 액션 처리
      case CheckNicknameAvailability():
        await _performNicknameAvailabilityCheck();

      case CheckEmailAvailability():
        await _performEmailAvailabilityCheck();

    // 회원가입 제출 액션 처리
      case Submit():
        await _performSignup();

    // 화면 이동 액션은 Root에서 처리됨
      case NavigateToLogin():
      case NavigateToTerms():
      // Root에서 처리됨
        break;
    }
  }

  // 닉네임 중복 확인
  Future<void> _performNicknameAvailabilityCheck() async {
    state = state.copyWith(nicknameAvailability: const AsyncValue.loading());

    final result = await _checkNicknameAvailabilityUseCase.execute(
      state.nickname,
    );

    state = state.copyWith(
      nicknameAvailability: result,
      nicknameError:
      result.hasError
          ? '닉네임 중복 확인 중 오류가 발생했습니다'
          : result.value == false
          ? '이미 사용 중인 닉네임입니다'
          : null,
    );
  }

  // 이메일 중복 확인
  Future<void> _performEmailAvailabilityCheck() async {
    state = state.copyWith(emailAvailability: const AsyncValue.loading());

    // 데이터 비교를 위해 소문자로 변환하여 중복 체크
    final result = await _checkEmailAvailabilityUseCase.execute(state.email);

    state = state.copyWith(
      emailAvailability: result,
      emailError:
      result.hasError
          ? '이메일 중복 확인 중 오류가 발생했습니다'
          : result.value == false
          ? '이미 사용 중인 이메일입니다'
          : null,
    );
  }

  // 회원가입 실행
  Future<void> _performSignup() async {
    // 1. 모든 필드의 유효성 검증
    final nicknameError = await _validateNicknameUseCase.execute(
      state.nickname,
    );
    final emailError = await _validateEmailUseCase.execute(state.email);
    final passwordError = await _validatePasswordUseCase.execute(
      state.password,
    );
    final passwordConfirmError = await _validatePasswordConfirmUseCase.execute(
      state.password,
      state.passwordConfirm,
    );
    final termsError = await _validateTermsAgreementUseCase.execute(
      state.agreeToTerms,
    );

    // 검증 결과 업데이트
    state = state.copyWith(
      nicknameError: nicknameError,
      emailError: emailError,
      passwordError: passwordError,
      passwordConfirmError: passwordConfirmError,
      termsError: termsError,
    );

    // 유효성 검증 오류가 있으면 회원가입 진행 중단
    if (nicknameError != null ||
        emailError != null ||
        passwordError != null ||
        passwordConfirmError != null ||
        termsError != null) {
      return;
    }

    // 2. 닉네임, 이메일 중복 확인
    if (state.nicknameAvailability?.value != true) {
      await _performNicknameAvailabilityCheck();
    }

    if (state.emailAvailability?.value != true) {
      await _performEmailAvailabilityCheck();
    }

    // 중복 확인 결과가 유효하지 않으면 회원가입 진행 중단
    if (state.nicknameAvailability?.value != true ||
        state.emailAvailability?.value != true) {
      return;
    }

    // 3. 회원가입 실행
    state = state.copyWith(signupResult: const AsyncValue.loading());

    // 회원가입 시 이메일은 그대로 전달
    // 소문자 변환은 Repository/DataSource 레벨에서 처리
    final result = await _signupUseCase.execute(
      email: state.email,
      password: state.password,
      nickname: state.nickname,
      agreedTermsId: state.agreedTermsId, // 약관 동의 ID 전달
    );

    state = state.copyWith(signupResult: result);
  }

  // 폼 리셋 (회원가입 성공 후 호출)
  void resetForm() {
    state = const SignupState();
  }

  // 약관 동의 ID 설정
  void setAgreedTermsId(String termsId) {
    state = state.copyWith(agreedTermsId: termsId);
  }

  // 약관 동의 상태 업데이트
  void updateTermsAgreement({
    required String agreedTermsId,
    required bool isAgreed,
  }) {
    state = state.copyWith(
      agreedTermsId: agreedTermsId,
      isTermsAgreed: isAgreed,
      agreeToTerms: isAgreed, // 약관 동의 체크박스도 함께 업데이트
    );
  }
}