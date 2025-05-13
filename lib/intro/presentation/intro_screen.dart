import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ← 임포트 추가
import 'component/focus_stats_chart.dart';
import 'component/total_focus.dart';
import 'component/user_intro.dart';
import 'intro_action.dart';
import 'intro_state.dart';

class IntroScreen extends StatelessWidget {
  final IntroState state;
  final Future<void> Function(IntroAction) onAction;

  const IntroScreen({super.key, required this.state, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('프로필', style: AppTextStyles.heading3Bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            iconSize: 30,
            onPressed: () => onAction(const OpenSettings()),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            // 프로필 영역
            state.userProfile.when(
              data: (member) => ProfileInfo(member: member),
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('프로필 정보를 불러올 수 없습니다')),
                  ),
            ),

            const Divider(height: 1),
            const SizedBox(height: 12),

            // 통계 + 차트 영역
            Expanded(
              child: state.focusStats.when(
                data: (stats) {
                  // ⚙️ 여기를 Column으로 감싸서 두 개의 위젯을 배치
                  return Column(
                    children: [
                      // ① 총시간 정보
                      Center(
                        child: TotalTimeInfo(totalMinutes: stats.totalMinutes),
                      ),
                      // ② 차트
                      Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 30),
                        child: FocusStatsChart(stats: stats),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (_, __) => const Center(child: Text('통계 정보를 불러올 수 없습니다')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
