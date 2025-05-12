import 'package:devlink_mobile_app/group/data/data_source/group_data_source.dart';
import 'package:devlink_mobile_app/group/data/data_source/mock_group_data_source_impl.dart';
import 'package:devlink_mobile_app/group/data/data_source/mock_timer_data_source_impl.dart';
import 'package:devlink_mobile_app/group/data/data_source/timer_data_source.dart';
import 'package:devlink_mobile_app/group/data/repository_impl/group_repository_impl.dart';
import 'package:devlink_mobile_app/group/data/repository_impl/timer_repository_impl.dart';
import 'package:devlink_mobile_app/group/domain/repository/group_repository.dart';
import 'package:devlink_mobile_app/group/domain/repository/timer_repository.dart';
import 'package:devlink_mobile_app/group/domain/usecase/create_group_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/get_group_detail_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/get_group_list_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/get_member_timers_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/get_timer_sessions_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/join_group_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/leave_group_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/resume_timer_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/search_groups_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/start_timer_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/stop_timer_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/update_group_use_case.dart';
import 'package:devlink_mobile_app/group/presentation/group_create/group_create_screen_root.dart';
import 'package:devlink_mobile_app/group/presentation/group_search/group_search_screen_root.dart';
import 'package:devlink_mobile_app/group/presentation/group_setting/group_settings_screen_root.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/group_timer_screen_root.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/mock_screen/mock_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_di.g.dart';

// DataSource 프로바이더
@riverpod
GroupDataSource groupDataSource(Ref ref) => MockGroupDataSourceImpl();

// Repository 프로바이더
@riverpod
GroupRepository groupRepository(Ref ref) =>
    GroupRepositoryImpl(dataSource: ref.watch(groupDataSourceProvider));

// UseCase 프로바이더들
@riverpod
GetGroupListUseCase getGroupListUseCase(Ref ref) =>
    GetGroupListUseCase(repository: ref.watch(groupRepositoryProvider));

@riverpod
GetGroupDetailUseCase getGroupDetailUseCase(Ref ref) =>
    GetGroupDetailUseCase(repository: ref.watch(groupRepositoryProvider));

@riverpod
JoinGroupUseCase joinGroupUseCase(Ref ref) =>
    JoinGroupUseCase(repository: ref.watch(groupRepositoryProvider));

@riverpod
CreateGroupUseCase createGroupUseCase(Ref ref) =>
    CreateGroupUseCase(repository: ref.watch(groupRepositoryProvider));

@riverpod
UpdateGroupUseCase updateGroupUseCase(Ref ref) =>
    UpdateGroupUseCase(repository: ref.watch(groupRepositoryProvider));

@riverpod
LeaveGroupUseCase leaveGroupUseCase(Ref ref) =>
    LeaveGroupUseCase(repository: ref.watch(groupRepositoryProvider));

@riverpod
SearchGroupsUseCase searchGroupsUseCase(Ref ref) =>
    SearchGroupsUseCase(repository: ref.watch(groupRepositoryProvider));

// ==================== 그룹 타이머 관련 DI ====================

// TimerDataSource 프로바이더
@riverpod
TimerDataSource timerDataSource(Ref ref) => MockTimerDataSourceImpl();

// TimerRepository 프로바이더
@riverpod
TimerRepository timerRepository(Ref ref) =>
    TimerRepositoryImpl(dataSource: ref.watch(timerDataSourceProvider));

// Timer UseCase 프로바이더들
@riverpod
StartTimerUseCase startTimerUseCase(Ref ref) =>
    StartTimerUseCase(repository: ref.watch(timerRepositoryProvider));

@riverpod
StopTimerUseCase stopTimerUseCase(Ref ref) =>
    StopTimerUseCase(repository: ref.watch(timerRepositoryProvider));

@riverpod
ResumeTimerUseCase resumeTimerUseCase(Ref ref) =>
    ResumeTimerUseCase(repository: ref.watch(timerRepositoryProvider));

@riverpod
GetTimerSessionsUseCase getTimerSessionsUseCase(Ref ref) =>
    GetTimerSessionsUseCase(repository: ref.watch(timerRepositoryProvider));

// 새로 추가된 UseCase 프로바이더
@riverpod
GetMemberTimersUseCase getMemberTimersUseCase(Ref ref) =>
    GetMemberTimersUseCase(repository: ref.watch(timerRepositoryProvider));

final List<GoRoute> groupRoutes = [
  // GoRoute(
  //   path: '/group',
  //   builder: (context, state) => const GroupListScreenRoot(),
  // ),
  GoRoute(
    path: '/group/create',
    builder: (context, state) => const GroupCreateScreenRoot(),
  ),
  GoRoute(
    path: '/group/search',
    builder: (context, state) => const GroupSearchScreenRoot(),
  ),
  GoRoute(
    path: '/group/:id',
    builder:
        (context, state) =>
            GroupTimerScreenRoot(groupId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/group/:id/attendance',
    builder:
        (context, state) =>
            MockGroupAttendanceScreen(groupId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/group/:id/settings',
    builder:
        (context, state) =>
            GroupSettingsScreenRoot(groupId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/user/:id/profile',
    builder:
        (context, state) =>
            MockUserProfileScreen(userId: state.pathParameters['id']!),
  ),
];

@riverpod
GoRouter groupRouter(Ref ref) {
  return GoRouter(initialLocation: '/group', routes: [...groupRoutes]);
}
