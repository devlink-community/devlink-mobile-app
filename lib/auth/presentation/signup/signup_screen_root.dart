// lib/auth/presentation/signup/signup_screen_root.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:devlink_mobile_app/auth/presentation/signup/signup_action.dart';
import 'package:devlink_mobile_app/auth/presentation/signup/signup_notifier.dart';
import 'package:devlink_mobile_app/auth/presentation/signup/signup_screen.dart';

class SignupScreenRoot extends ConsumerStatefulWidget {
  final String? agreedTermsId;

  const SignupScreenRoot({
    super.key,
    this.agreedTermsId,
  });

  @override
  ConsumerState<SignupScreenRoot> createState() => _SignupScreenRootState();
}

class _SignupScreenRootState extends ConsumerState<SignupScreenRoot> {
  @override
  void initState() {
    super.initState();

    // 약관 동의 ID가 있으면 설정
    if (widget.agreedTermsId != null) {
      // 다음 프레임에서 notifier 접근 (initState에서 ref.read 사용)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(signupNotifierProvider.notifier).setAgreedTermsId(widget.agreedTermsId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupNotifierProvider);
    final notifier = ref.watch(signupNotifierProvider.notifier);

    // 회원가입 성공 감지 및 이동
    ref.listen(signupNotifierProvider.select((value) => value.signupResult), (previous, next) {
      if (previous?.isLoading == true && next?.hasValue == true) {
        // 회원가입 성공 후 폼 리셋
        notifier.resetForm();

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입에 성공했습니다. 로그인해주세요.')),
        );

        // 로그인 페이지로 이동
        context.go('/');
      } else if (next?.hasError == true) {
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: ${next!.error}')),
        );
      }
    });

    return SignupScreen(
      state: state,
      onAction: (action) {
        switch (action) {
          case NavigateToLogin():
            context.go('/');

          case NavigateToTerms():
          // 약관 페이지로 이동
            context.push('/terms');

          default:
          // 나머지 액션은 Notifier에서 처리
            notifier.onAction(action);
        }
      },
    );
  }
}