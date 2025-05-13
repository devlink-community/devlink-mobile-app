// lib/auth/presentation/signup/signup_screen.dart
import 'package:devlink_mobile_app/auth/presentation/component/custom_button.dart';
import 'package:devlink_mobile_app/auth/presentation/component/custom_text_field.dart';
import 'package:devlink_mobile_app/auth/presentation/signup/signup_action.dart';
import 'package:devlink_mobile_app/auth/presentation/signup/signup_state.dart';
import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  final SignupState state;
  final void Function(SignupAction action) onAction;

  const SignupScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  final _nicknameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 컨트롤러 초기값 설정
    _nicknameController.text = widget.state.nickname;
    _emailController.text = widget.state.email;
    _passwordController.text = widget.state.password;
    _passwordConfirmController.text = widget.state.passwordConfirm;

    // 포커스 리스너 설정
    _nicknameFocusNode.addListener(_onNicknameFocusChanged);
    _emailFocusNode.addListener(_onEmailFocusChanged);
    _passwordFocusNode.addListener(_onPasswordFocusChanged);
    _passwordConfirmFocusNode.addListener(_onPasswordConfirmFocusChanged);
  }

  @override
  void didUpdateWidget(covariant SignupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 컨트롤러 값 동기화 - 필요한 경우에만 업데이트
    if (widget.state.nickname != _nicknameController.text) {
      _nicknameController.text = widget.state.nickname;
    }
    if (widget.state.email != _emailController.text) {
      _emailController.text = widget.state.email;
    }
    if (widget.state.password != _passwordController.text) {
      _passwordController.text = widget.state.password;
    }
    if (widget.state.passwordConfirm != _passwordConfirmController.text) {
      _passwordConfirmController.text = widget.state.passwordConfirm;
    }
  }

  @override
  void dispose() {
    // 컨트롤러 정리
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();

    // 포커스 리스너 정리
    _nicknameFocusNode.removeListener(_onNicknameFocusChanged);
    _emailFocusNode.removeListener(_onEmailFocusChanged);
    _passwordFocusNode.removeListener(_onPasswordFocusChanged);
    _passwordConfirmFocusNode.removeListener(_onPasswordConfirmFocusChanged);

    // 포커스 노드 정리
    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();

    super.dispose();
  }

  // 포커스 변경 리스너
  void _onNicknameFocusChanged() {
    // 포커스를 잃을 때만 유효성 검사 (중복 확인은 제외)
    if (!_nicknameFocusNode.hasFocus) {
      widget.onAction(SignupAction.nicknameFocusChanged(false));
    }
  }

  void _onEmailFocusChanged() {
    // 포커스를 잃을 때만 유효성 검사 (중복 확인은 제외)
    if (!_emailFocusNode.hasFocus) {
      widget.onAction(SignupAction.emailFocusChanged(false));
    }
  }

  void _onPasswordFocusChanged() {
    if (!_passwordFocusNode.hasFocus) {
      widget.onAction(SignupAction.passwordFocusChanged(false));
    }
  }

  void _onPasswordConfirmFocusChanged() {
    if (!_passwordConfirmFocusNode.hasFocus) {
      widget.onAction(SignupAction.passwordConfirmFocusChanged(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 상태 확인
    final isLoading = widget.state.signupResult?.isLoading ?? false;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // 배경 터치 시 키보드 내리기
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // 회원가입 타이틀
                  Text(
                    '회원가입',
                    style: AppTextStyles.heading2Bold,
                  ),

                  // 로그인 링크
                  Row(
                    children: [
                      Text(
                        '계정이 있으신가요?',
                        style: AppTextStyles.body1Regular,
                      ),
                      TextButton(
                        onPressed: () => widget.onAction(const SignupAction.navigateToLogin()),
                        child: Text(
                          '로그인',
                          style: AppTextStyles.body1Regular.copyWith(
                            color: AppColorStyles.primary100,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 입력 필드 섹션 - 간격 일정하게 유지
                  _buildInputFields(),

                  // 이용약관 동의 섹션
                  _buildTermsAgreement(),

                  const SizedBox(height: 32),

                  // 회원가입 버튼
                  CustomButton(
                    text: '회원가입',
                    onPressed: () => widget.onAction(const SignupAction.submit()),
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 입력 필드 섹션 - 모듈화하여 가독성 향상
  Widget _buildInputFields() {
    return Column(
      children: [
        // 닉네임 입력
        CustomTextField(
          label: '',
          hintText: 'nick name',
          controller: _nicknameController,
          focusNode: _nicknameFocusNode,
          errorText: widget.state.nicknameError,
          onChanged: (value) => widget.onAction(SignupAction.nicknameChanged(value)),
        ),

        const SizedBox(height: 10),

        // 이메일 입력
        CustomTextField(
          label: '',
          hintText: 'Email address',
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          errorText: widget.state.emailError,
          onChanged: (value) => widget.onAction(SignupAction.emailChanged(value)),
        ),

        const SizedBox(height: 10),

        // 비밀번호 입력
        CustomTextField(
          label: '',
          hintText: 'Password',
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: true,
          errorText: widget.state.passwordError,
          onChanged: (value) => widget.onAction(SignupAction.passwordChanged(value)),
        ),

        const SizedBox(height: 10),

        // 비밀번호 확인 입력
        CustomTextField(
          label: '',
          hintText: 'Password confirm',
          controller: _passwordConfirmController,
          focusNode: _passwordConfirmFocusNode,
          obscureText: true,
          errorText: widget.state.passwordConfirmError,
          onChanged: (value) => widget.onAction(SignupAction.passwordConfirmChanged(value)),
        ),
      ],
    );
  }

  // 이용약관 동의 섹션 - 모듈화하여 가독성 향상
  Widget _buildTermsAgreement() {
    return Column(
      children: [
        // 이용약관 동의 (우측 정렬)
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // 우측 정렬
          children: [
            Checkbox(
              value: widget.state.agreeToTerms,
              onChanged: widget.state.isTermsAgreed
                  ? null // 약관에 이미 동의했으면 비활성화
                  : (value) => widget.onAction(SignupAction.agreeToTermsChanged(value ?? false)),
              activeColor: AppColorStyles.primary100,
              // 비활성화 상태에서도 색상 유지
              fillColor: widget.state.isTermsAgreed
                  ? MaterialStateProperty.all(AppColorStyles.gray60)
                  : null,
            ),
            GestureDetector(
              onTap: () => widget.onAction(const SignupAction.navigateToTerms()),
              child: Text(
                '회원가입 약관 보시겠어요?',
                style: AppTextStyles.body2Regular.copyWith(
                  color: AppColorStyles.gray80,
                ),
              ),
            ),
          ],
        ),

        // 약관 동의 에러 메시지 - 고정 높이로 일관성 유지
        Container(
          height: 24, // 에러 메시지 영역 고정 높이
          padding: const EdgeInsets.only(right: 16.0),
          alignment: Alignment.centerRight, // 에러 메시지도 우측 정렬
          child: widget.state.termsError != null
              ? Text(
            widget.state.termsError!,
            style: AppTextStyles.captionRegular.copyWith(
              color: AppColorStyles.error,
            ),
          )
              : null,
        ),
      ],
    );
  }
}