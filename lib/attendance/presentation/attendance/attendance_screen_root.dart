// lib/attendance/presentation/attendance/attendance_screen_root.dart
import 'package:devlink_mobile_app/attendance/presentation/attendance/attendance_action.dart';
import 'package:devlink_mobile_app/attendance/presentation/attendance/attendance_notifier.dart';
import 'package:devlink_mobile_app/attendance/presentation/attendance/attendance_screen.dart';
import 'package:devlink_mobile_app/group/domain/model/group.dart';
import 'package:devlink_mobile_app/group/module/group_di.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 그룹 상세 정보 조회 프로바이더
@riverpod
Future<Group> groupDetailForAttendance(
    GroupDetailForAttendanceRef ref, String groupId) async {
  final useCase = ref.watch(getGroupDetailUseCaseProvider);
  final result = await useCase.execute(groupId);

  if (result is AsyncData<Group>) {
    return result.value;
  } else if (result is AsyncError) {
    throw result.error;
  } else {
    throw Exception('Unknown error occurred');
  }
}

class AttendanceScreenRoot extends ConsumerWidget {
  final String groupId;

  // 생성자 - GroupId로 생성
  const AttendanceScreenRoot({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailForAttendanceProvider(groupId));

    return switch (groupAsync) {
      AsyncData(:final value) => _buildWithGroup(context, ref, value),
      AsyncLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AsyncError(:final error) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('그룹 정보를 불러오는데 실패했습니다: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      ),
    };
  }

  // 그룹 정보로 화면 빌드
  Widget _buildWithGroup(BuildContext context, WidgetRef ref, Group group) {
    final state = ref.watch(attendanceNotifierProvider);
    final notifier = ref.watch(attendanceNotifierProvider.notifier);

    // 초기 그룹 선택 처리
    // Root가 첫 번째로 빌드될 때 group 정보 설정
    ref.listenManual(attendanceNotifierProvider, (_, __) {
      Future.microtask(() {
        notifier.onAction(AttendanceAction.selectGroup(group));
      });
    }, fireImmediately: true);

    return AttendanceScreen(
      state: state,
      onAction: notifier.onAction,
    );
  }
}