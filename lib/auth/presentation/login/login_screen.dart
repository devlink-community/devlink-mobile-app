// lib/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:devlink_mobile_app/auth/presentation/login/login_action.dart';
import 'package:devlink_mobile_app/auth/presentation/login/login_state.dart';
import 'package:devlink_mobile_app/auth/presentation/component/custom_text_field.dart';
import 'package:devlink_mobile_app/auth/presentation/component/custom_button.dart';
import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  final LoginState state;
  final void Function(LoginAction action) onAction;

  const LoginScreen({super.key, required this.state, required this.onAction});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중이면 로딩 인디케이터 표시
    final loading = widget.state.loginUserResult?.isLoading ?? false;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // 로그인 타이틀
              Text(
                '로그인',
                style: AppTextStyles.heading2Bold,
              ),
              const SizedBox(height: 8),
              // 회원가입 안내 텍스트
              Row(
                children: [
                  Text(
                    '계정이 없으신가요?',
                    style: AppTextStyles.body1Regular,
                  ),
                  TextButton(
                    onPressed: () => widget.onAction(
                      const LoginAction.navigateToSignUp(),
                    ),
                    child: Text(
                      '회원가입',
                      style: AppTextStyles.body1Regular.copyWith(
                        color: AppColorStyles.primary100,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // 이메일 입력
              CustomTextField(
                label: '',
                hintText: 'Email address',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => {},
              ),
              const SizedBox(height: 10),
              // 비밀번호 입력
              CustomTextField(
                label: '',
                hintText: 'Password',
                controller: passwordController,
                obscureText: true,
                onChanged: (value) => {},
              ),
              // 비밀번호 찾기 링크
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => widget.onAction(
                    const LoginAction.navigateToForgetPassword(),
                  ),
                  child: Text(
                    '비밀번호를 잊어버리셨나요?',
                    style: AppTextStyles.body2Regular.copyWith(
                      color: AppColorStyles.gray80,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // 로그인 버튼 (CustomButton 사용)
              CustomButton(
                text: '로그인',
                onPressed: () => widget.onAction(
                  LoginAction.loginPressed(
                    email: emailController.text,
                    password: passwordController.text,
                  ),
                ),
                isLoading: loading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}