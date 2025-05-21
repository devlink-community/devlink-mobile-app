// lib/community/presentation/community_list/community_list_screen_root.dart
import 'package:devlink_mobile_app/community/module/util/community_tab_type_enum.dart';
import 'package:devlink_mobile_app/core/event/app_event.dart';
import 'package:devlink_mobile_app/core/event/app_event_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'community_list_action.dart';
import 'community_list_notifier.dart';
import 'community_list_screen.dart';

class CommunityListScreenRoot extends ConsumerWidget {
  const CommunityListScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityListNotifierProvider);
    final notifier = ref.watch(communityListNotifierProvider.notifier);

    // RefreshCommunity 이벤트 감지
    ref.listen<List<AppEvent>>(appEventNotifierProvider, (previous, current) {
      for (final event in current) {
        if (event is RefreshCommunity) {
          // 목록 새로고침
          notifier.onAction(const CommunityListAction.refresh());
        }
      }
    });

    return CommunityListScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case TapPost(:final postId):
            await context.push('/community/$postId');

          case TapSearch():
            await context.push('/community/search');

          case TapWrite():
            // 게시글 작성 화면으로 이동하고, 결과(생성된 게시글 ID)를 받아옴
            final result = await context.push('/community/write');
            print('Returned from write screen with result: $result');

            // 결과가 Map 형태로 전달되고 refresh 플래그가 true인 경우
            if (result is Map && result['refresh'] == true) {
              print('Post created. Triggering tab change to refresh list');

              // 현재 탭 상태 가져오기
              final currentTab = state.currentTab;

              // 최신순 탭 강제 선택 (또는 현재 선택된 탭을 다시 선택)
              await notifier.onAction(
                CommunityListAction.changeTab(CommunityTabType.newest),
              );

              // 만약 이미 최신순 탭이었다면, 다른 탭으로 갔다가 다시 최신순으로 변경
              if (currentTab == CommunityTabType.newest) {
                await notifier.onAction(
                  CommunityListAction.changeTab(CommunityTabType.popular),
                );
                await Future.delayed(const Duration(milliseconds: 100));
                await notifier.onAction(
                  CommunityListAction.changeTab(CommunityTabType.newest),
                );
              }
            } else {
              print('Result did not match expected format: $result');
            }

          default:
            await notifier.onAction(action);
        }
      },
    );
  }
}
