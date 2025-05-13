// lib/auth/presentation/terms/terms_screen_root.dart

import 'package:devlink_mobile_app/auth/presentation/terms/terms_action.dart';
import 'package:devlink_mobile_app/auth/presentation/terms/terms_notifier.dart';
import 'package:devlink_mobile_app/auth/presentation/terms/terms_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// signupNotifierProvider import 추가
import 'package:devlink_mobile_app/auth/presentation/signup/signup_notifier.dart';

class TermsScreenRoot extends ConsumerWidget {
  const TermsScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(termsNotifierProvider);
    final notifier = ref.watch(termsNotifierProvider.notifier);

// 약관 동의 저장 완료 감지 - 수정된 부분
    ref.listen(
      termsNotifierProvider.select((value) => value.savedTermsId),
          (previous, next) {
        // savedTermsId가 null이 아니고 이전과 다른 경우 (새로 저장된 경우)
        if (next != null && previous != next) {
          // 약관 저장 성공 시 회원가입 화면으로 이동
          context.pop(); // 현재 화면을 닫고 이전 화면(회원가입)으로 돌아가기

          // 다음 프레임에서 signupNotifier 업데이트 (화면 전환 후)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(signupNotifierProvider.notifier).updateTermsAgreement(
              agreedTermsId: next,
              isAgreed: true,
            );
          });
        }
      },
    );

    return TermsScreen(
      state: state,
      onAction: (action) {
        switch (action) {
          case ViewTermsDetail(:final termType):
            _showTermsDetailDialog(context, termType);
          case NavigateToSignup():
            context.pop(); // 회원가입 화면으로 돌아가기
          case NavigateBack():
            context.pop();
          default:
            notifier.onAction(action);
        }
      },
    );
  }

  // 약관 상세보기 다이얼로그 메서드는 그대로 유지
  void _showTermsDetailDialog(BuildContext context, String termType) {
    // 기존 코드 유지
    String title;
    String content;

    // 약관 타입에 따라 제목과 내용 설정
    switch (termType) {
      case 'service':
        title = '서비스 이용약관';
        content = '''
서비스 이용약관 내용입니다.

제1조 (목적)
이 약관은 '개발수다방'가 제공하는 서비스의 이용조건 및 절차, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조 (정의)
이 약관에서 사용하는 용어의 정의는 다음과 같습니다.
1. '서비스'라 함은 모바일 기기를 통하여 이용할 수 있는 '개발수다방' 서비스를 의미합니다.
2. '이용자'라 함은 이 약관에 따라 서비스를 이용하는 회원 및 비회원을 말합니다.
3. '회원'이라 함은 서비스에 회원등록을 한 자로서, 계속적으로 서비스를 이용할 수 있는 자를 말합니다.
        ''';
        break;
      case 'privacy':
        title = '개인정보 수집 및 이용 동의';
        content = '''
개인정보 수집 및 이용 동의 내용입니다.

1. 수집하는 개인정보 항목
- 회원가입 시: 이메일 주소, 비밀번호, 닉네임
- 서비스 이용 과정에서 생성되는 정보: 프로필 정보, 활동 로그

2. 개인정보의 수집 및 이용 목적
- 서비스 제공에 관한 계약 이행 및 서비스 제공
- 회원 관리: 회원제 서비스 이용, 개인식별, 불량회원의 부정이용 방지
- 서비스 개선 및 신규 서비스 개발

3. 개인정보의 보유 및 이용기간
- 회원탈퇴 시까지(단, 관계 법령에 따라 보존할 필요가 있는 경우 해당 기간 동안 보존)
        ''';
        break;
      case 'marketing':
        title = '마케팅 정보 수신 동의';
        content = '''
마케팅 정보 수신 동의 내용입니다.

1. 마케팅 정보 수신 동의는 선택사항이며, 동의하지 않아도 서비스 이용이 가능합니다.

2. 수집 목적 및 이용 내용
- 새로운 서비스, 이벤트, 프로모션 등 광고성 정보 제공
- 맞춤형 서비스 및 혜택 제공
- 설문조사를 통한 서비스 품질 향상

3. 마케팅 정보 수신 방법
- 이메일, 앱 내 알림

4. 동의 철회 방법
- 언제든지 '설정 > 알림 설정'에서 수신 동의를 철회할 수 있습니다.
        ''';
        break;
      default:
        title = '약관 상세보기';
        content = '약관 내용이 제공되지 않았습니다.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}