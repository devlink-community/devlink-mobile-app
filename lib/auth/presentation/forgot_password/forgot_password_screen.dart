// lib/auth/presentation/forgot_password/forgot_password_screen.dart
import 'package:devlink_mobile_app/auth/presentation/component/custom_button.dart';
import 'package:devlink_mobile_app/auth/presentation/component/custom_text_field.dart';
import 'package:devlink_mobile_app/auth/presentation/forgot_password/forgot_password_action.dart';
import 'package:devlink_mobile_app/auth/presentation/forgot_password/forgot_password_state.dart';
import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final ForgotPasswordState state;
  final void Function(ForgotPasswordAction action) onAction;

  const ForgotPasswordScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  late final FocusNode _emailFocusNode;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.state.email);
    _emailFocusNode = FocusNode()..addListener(_onEmailFocusChanged);
  }

  void _onEmailFocusChanged() {
    widget.onAction(ForgotPasswordAction.emailFocusChanged(_emailFocusNode.hasFocus));
  }

  @override
  void didUpdateWidget(covariant ForgotPasswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.email != _emailController.text) {
      _emailController.text = widget.state.email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChanged);
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 상태 확인
    final isLoading = widget.state.resetPasswordResult?.isLoading ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 제목
              Text(
                '비밀번호 재설정',
                style: AppTextStyles.heading2Bold.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 안내 텍스트
              Text(
                '입력하신 이메일로 비밀번호를 재설정할 수 있는\n링크를 전송합니다. 이메일을 작성해주세요.',
                style: AppTextStyles.body1Regular.copyWith(
                  color: AppColorStyles.gray100,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 이메일 입력 필드 - CustomTextField 활용
              CustomTextField(
                label: '',
                hintText: 'Email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: widget.state.emailError,
                onChanged: (value) => widget.onAction(ForgotPasswordAction.emailChanged(value)),
              ),

              const Spacer(),

              // 이메일 발송하기 버튼 - CustomButton 활용
              CustomButton(
                text: '이메일 발송하기',
                onPressed: () => widget.onAction(ForgotPasswordAction.sendResetEmail()),
                isLoading: isLoading,
                backgroundColor: AppColorStyles.primary100,
                foregroundColor: Colors.white,
                height: 50,
                width: double.infinity,
              ),

              const SizedBox(height: 16),

              // 로그인으로 돌아가기 텍스트 버튼
              TextButton(
                onPressed: () => widget.onAction(ForgotPasswordAction.navigateToLogin()),
                child: Text(
                  '로그인으로 돌아가기',
                  style: AppTextStyles.body2Regular.copyWith(
                    color: AppColorStyles.gray100,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}