import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:devlink_mobile_app/intro/domain/model/focus_time_stats.dart';
import 'package:devlink_mobile_app/intro/domain/use_case/fetch_intro_data_use_case.dart';
import 'package:devlink_mobile_app/intro/domain/use_case/fetch_intro_stats_use_case.dart';
// UseCase Provider들을 사용하기 위해 intro_di.dart를 import 합니다.
import 'package:devlink_mobile_app/intro/module/intro_di.dart';
// IntroRouter Provider import
import 'package:devlink_mobile_app/intro/module/intro_route.dart';
// IntroNotifier와 UseCase 타입들을 알기 위해 import 합니다.
import 'package:devlink_mobile_app/intro/presentation/intro_notifier.dart';
import 'package:devlink_mobile_app/intro/presentation/intro_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// --- 목 데이터 정의 (기존 코드 유지) ---
final mockMember = Member(
  id: '0',
  email: 'mock@example.com',
  nickname: '닝닝',
  image:
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpND_VCJ23YdyqjVjCgG0meg6C_Gx5wCOc3A&s',
  description:
      '안녕하세요! 이 편지는 영국으로 부터 시작되어 일년에 한바퀴 돌면서 받는 사람에게 행운을 주었고, 지금은 당신에게로 옮겨진 이편지는 4일 만에 당신 곁을 떠나야 합니다.',
  uid: '',
  streakDays: 10,
);

final mockStats = FocusTimeStats(
  totalMinutes: 330,
  weeklyMinutes: {
    '월': 50,
    '화': 60,
    '수': 45,
    '목': 55,
    '금': 70,
    '토': 30,
    '일': 20,
  },
);
// --- 목 데이터 정의 끝 ---

void main() {
  final mockIntroState = IntroState(
    userProfile: AsyncData(mockMember),
    focusStats: AsyncData(mockStats),
  );

  runApp(
    ProviderScope(
      overrides: [
        introNotifierProvider.overrideWith(
          () => IntroNotifierMock(mockIntroState),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class IntroNotifierMock extends IntroNotifier {
  final IntroState mockState;

  @override
  late final FetchIntroUserUseCase _fetchUserUseCase;
  @override
  late final FetchIntroStatsUseCase _fetchStatsUseCase;

  IntroNotifierMock(this.mockState);

  @override
  Future<IntroState> build() async {
    // ref.watch를 사용하여 UseCase Provider들로부터 인스턴스를 가져와 필드에 할당합니다.
    // 이는 실제 IntroNotifier의 build 메서드에서 하는 역할과 동일합니다.
    _fetchUserUseCase = ref.watch(fetchIntroUserUseCaseProvider);
    _fetchStatsUseCase = ref.watch(fetchIntroStatsUseCaseProvider);
    return mockState;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(introRouterProvider);
    return MaterialApp.router(routerConfig: router);
  }
}
