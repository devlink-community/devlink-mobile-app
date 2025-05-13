import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../presentation/screens/edit_intro_root.dart';

part 'edit_intro_route.g.dart';

/// EditIntro 모듈의 라우트 정의
final editIntroRoutes = [
  GoRoute(
    path: '/edit-intro',
    builder: (context, state) => const EditIntroRoot(),
  ),
];

@riverpod
GoRouter editIntroRouter(EditIntroRouterRef ref) {
  return GoRouter(initialLocation: '/edit-intro', routes: editIntroRoutes);
}
