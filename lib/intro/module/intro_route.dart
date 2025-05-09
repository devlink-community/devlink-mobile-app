import 'package:devlink_mobile_app/setting/presentation/settings_screen_root.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../edit_intro/presentation/screens/edit_intro_root.dart';
import '../presentation/intro_screen_root.dart';

part 'intro_route.g.dart';

/// Intro 모듈의 라우트 정의
final introRoutes = [
  GoRoute(path: '/intro', builder: (context, state) => const IntroScreenRoot()),
  // 설정 화면으로 이동하는 경로 추가
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
    path: '/change-password',
    builder: (context, state) => const Placeholder(), // 임시 화면
  ),

  GoRoute(
    path: '/privacy-policy',
    builder: (context, state) => const Placeholder(), // 임시 화면
  ),

  GoRoute(
    path: '/app-info',
    builder: (context, state) => const Placeholder(), // 임시 화면
  ),
];

@riverpod
GoRouter introRouter(IntroRouterRef ref) {
  return GoRouter(initialLocation: '/intro', routes: introRoutes);
}
