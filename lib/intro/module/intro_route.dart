import 'package:devlink_mobile_app/setting/presentation/settings_screen_root.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/forgot_password/forgot_password_screen_root.dart';
import '../../edit_intro/presentation/screens/edit_intro_root.dart';
import '../presentation/intro_screen_root.dart';

part 'intro_route.g.dart';

/// Intro 모듈의 라우트 정의
final List<GoRoute> introRoutes = [
  GoRoute(
    path: '/intro',
    name: 'intro', // 라우트 이름을 지정하면 타입 세이프하게 네비게이션 가능
    builder: (context, state) => const IntroScreenRoot(),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreenRoot(),
  ),
  // 프로필 수정 화면으로 연결 (이미 존재하는 EditIntroRoot 사용)
  GoRoute(
    path: '/edit-profile',
    builder: (context, state) => const EditIntroRoot(),
  ),

  // 다른 설정 관련 화면들도 필요에 따라 추가
  GoRoute(
    path: '/forget-password',
    builder: (context, state) => const ForgotPasswordScreenRoot(),
  ),
];

@riverpod
GoRouter introRouter(Ref ref) {
  return GoRouter(initialLocation: '/intro', routes: [...introRoutes]);
}
