import 'package:devlink_mobile_app/edit_intro/presentation/screens/edit_intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../edit_intro_action.dart';
import '../edit_intro_notifier.dart';

class EditIntroRoot extends ConsumerStatefulWidget {
  const EditIntroRoot({super.key});

  @override
  ConsumerState<EditIntroRoot> createState() => _EditIntroRootState();
}

class _EditIntroRootState extends ConsumerState<EditIntroRoot> {
  @override
  void initState() {
    super.initState();
    // 미세한 지연을 두고 프로필 로드 시작
    Future.microtask(() {
      ref.read(editIntroNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editIntroNotifierProvider);
    final notifier = ref.watch(editIntroNotifierProvider.notifier);

    return EditIntroScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case OnSave():
            await notifier.onAction(action);
            if (!state.isError && state.isSuccess) {
              context.pop(); // 저장 성공 시 이전 화면으로 이동
            }
            break;
          default:
            await notifier.onAction(action);
        }
      },
    );
  }
}
