// lib/auth/presentation/forgot_password/forgot_password_screen_root.dart (수정)
import 'package:devlink_mobile_app/auth/presentation/forgot_password/forgot_password_action.dart';
import 'package:devlink_mobile_app/auth/presentation/forgot_password/forgot_password_notifier.dart';
import 'package:devlink_mobile_app/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ForgotPasswordScreenRoot extends ConsumerWidget {
  const ForgotPasswordScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordNotifierProvider);  // forgOt으로 수정
    final notifier = ref.watch(forgotPasswordNotifierProvider.notifier);  // forgOt으로 수정

    // 비밀번호 재설정 이메일 전송 성공 감지
    ref.listen(
      forgotPasswordNotifierProvider.select((value) => value.resetPasswordResult),
          (previous, next) {
        if (previous?.isLoading == true && next?.hasValue == true) {
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage ?? '이메일이 발송되었습니다.')),
          );
        } else if (next?.hasError == true) {
          // 에러 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일 발송 실패: ${next!.error}')),
          );
        }
      },
    );

    return ForgotPasswordScreen(  // ForgotPasswordScreen이 정의되어 있어야 함
      state: state,
      onAction: (action) {
        switch (action) {
          case NavigateToLoginAction():  // NavigateToLoginAction으로 수정
            context.go('/');  // 로그인 화면으로 이동
          default:
            notifier.onAction(action);
        }
      },
    );
  }
}