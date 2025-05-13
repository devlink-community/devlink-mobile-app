import 'package:devlink_mobile_app/auth/presentation/login/login_action.dart';
import 'package:devlink_mobile_app/auth/presentation/login/login_screen.dart';
import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'login_notifier.dart';

// lib/auth/presentation/login/login_screen_root.dart
class LoginScreenRoot extends ConsumerWidget {
  const LoginScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.watch(loginNotifierProvider.notifier);

    // 로그인 성공 감지 후 이동
    ref.listen(loginNotifierProvider, (previous, next) {
      final loginResult = next.loginUserResult;
      if (loginResult?.hasValue == true) {
        context.go('/home');
        ref.read(loginNotifierProvider.notifier).logout();
      }

      // 에러 발생 시 스낵바로 표시
      if (loginResult?.hasError == true) {
        final error = loginResult!.error;
        String errorMessage;

        if (error is Failure) {
          errorMessage = error.message;
        } else if (error is Exception) {
          errorMessage = error.toString().replaceFirst('Exception: ', '');
        } else {
          errorMessage = '로그인 중 오류가 발생했습니다';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return LoginScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case NavigateToForgetPassword():
            context.push('/forget-password');
          case NavigateToSignUp():
            context.push('/sign-up');
          case LoginPressed():
            await notifier.onAction(action);
        }
      },
    );
  }
}