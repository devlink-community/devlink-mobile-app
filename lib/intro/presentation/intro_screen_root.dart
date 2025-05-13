import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/component/navigation_bar.dart';
import 'intro_action.dart';
import 'intro_notifier.dart';
import 'intro_screen.dart';

class IntroScreenRoot extends ConsumerStatefulWidget {
  const IntroScreenRoot({super.key});

  @override
  ConsumerState<IntroScreenRoot> createState() => _IntroScreenRootState();
}

class _IntroScreenRootState extends ConsumerState<IntroScreenRoot> {
  int _selectedIndex = 4; // 프로필 탭이 미리 선택되도록 설정

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(introNotifierProvider.notifier);
    final state = ref.watch(introNotifierProvider);

    return state.when(
      data: (data) {
        // 멤버 프로필 이미지 URL 가져오기
        final profileImageUrl = data.userProfile.value?.image;

        return Scaffold(
          body: IntroScreen(
            state: data,
            onAction: (action) async {
              switch (action) {
                case OpenSettings():
                  print('설정 버튼 클릭됨 - 설정 화면으로 이동 시도');
                  context.go('/settings');
                  break;
                case RefreshIntro():
                  print('새로고침 버튼 클릭됨');
                  await notifier.onAction(action);
                  break;
              }
            },
          ),
          bottomNavigationBar: AppBottomNavigationBar(
            currentIndex: _selectedIndex,
            profileImageUrl: profileImageUrl, // 멤버 이미지 URL 전달
            onTap: (index) {
              setState(() {
                _selectedIndex = index;

                // 실제 앱에서는 각 인덱스에 맞는 화면으로 이동
                switch (index) {
                  case 0: // 홈
                    context.go('/intro');
                    break;
                  case 1: // 채팅
                    // context.go('/chat');
                    break;
                  case 2: // 커뮤니티
                    // context.go('/community');
                    break;
                  case 3: // 알림
                    // context.go('/notifications');
                    break;
                  case 4: // 프로필 (이미 프로필 화면이므로 아무 동작 없음)
                    // 이미 프로필 화면이므로 여기서는 아무 동작 없음
                    break;
                }
              });
            },
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stackTrace) =>
              Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
