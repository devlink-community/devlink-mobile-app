import 'dart:math';

import 'package:devlink_mobile_app/group/data/data_source/timer_data_source.dart';
import 'package:devlink_mobile_app/group/data/dto/timer_session_dto.dart';
import 'package:devlink_mobile_app/group/domain/model/member_timer.dart';
import 'package:devlink_mobile_app/group/domain/model/member_timer_status.dart';

class MockTimerDataSourceImpl implements TimerDataSource {
  // 메모리 내 스토리지 (이전 더미 세션 저장)
  final Map<String, TimerSessionDto> _sessions = {};
  final Map<String, TimerSessionDto> _activeSessionsByUser = {};
  final Random _random = Random();

  @override
  Future<TimerSessionDto> startTimer({
    required String groupId,
    required String userId,
  }) async {
    // 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 이미 진행 중인 세션이 있는지 확인
    final activeSession = _activeSessionsByUser[userId];
    if (activeSession != null) {
      return activeSession; // 이미 진행 중인 세션이 있으면 그대로 반환
    }

    // 새 세션 ID 생성
    final sessionId =
        'timer_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';

    // 새 세션 DTO 생성
    final newSession = TimerSessionDto(
      id: sessionId,
      groupId: groupId,
      userId: userId,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      // 임시 종료 시간 (2시간 후)
      duration: 0,
      // 시작 시 0초
      isCompleted: false, // 시작 상태
    );

    // 메모리에 저장
    _sessions[sessionId] = newSession;
    _activeSessionsByUser[userId] = newSession;

    return newSession;
  }

  @override
  Future<TimerSessionDto> stopTimer({
    required String sessionId,
    required int duration,
  }) async {
    // 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 세션 찾기
    final session = _sessions[sessionId];
    if (session == null) {
      throw Exception('타이머 세션을 찾을 수 없습니다.');
    }

    // 세션 업데이트
    final updatedSession = TimerSessionDto(
      id: session.id,
      groupId: session.groupId,
      userId: session.userId,
      startTime: session.startTime,
      endTime: DateTime.now(),
      // 현재 시간으로 종료
      duration: duration,
      // 전달받은 지속 시간
      isCompleted: true, // 완료 상태로 변경
    );

    // 메모리 업데이트
    _sessions[sessionId] = updatedSession;

    // 활성 세션에서 제거
    if (session.userId != null) {
      _activeSessionsByUser.remove(session.userId);
    }

    return updatedSession;
  }

  @override
  Future<List<TimerSessionDto>> fetchTimerSessions(String groupId) async {
    // 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 700));

    // 그룹 ID에 해당하는 세션 필터링
    return _sessions.values
        .where((session) => session.groupId == groupId)
        .toList();
  }

  @override
  Future<TimerSessionDto> fetchTimerSession(String sessionId) async {
    // 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 300));

    // 세션 ID로 세션 찾기
    final session = _sessions[sessionId];
    if (session == null) {
      throw Exception('타이머 세션을 찾을 수 없습니다.');
    }

    return session;
  }

  @override
  Future<TimerSessionDto?> fetchActiveTimerSession(String userId) async {
    // 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 300));

    // 유저 ID에 해당하는 활성 세션 반환
    return _activeSessionsByUser[userId];
  }

  @override
  Future<List<MemberTimer>> fetchMemberTimers(String groupId) async {
    // 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 무작위 이미지를 위한 URL 패턴 (랜덤 사용자 이미지 API)
    final baseImageUrl = "https://randomuser.me/api/portraits/";
    final categories = ["men", "women"];
    final random = Random();

    // 40명의 멤버 목업 데이터 생성
    final List<MemberTimer> mockMembers = [];

    for (int i = 0; i < 40; i++) {
      // 랜덤하게 활성/휴식 상태 결정 (70% 활성, 30% 휴식)
      final isActive = random.nextDouble() > 0.3;

      // 멤버 ID 및 이름
      final memberId = "user${i + 1}";
      final memberName = "이용자${i + 1}";

      // 랜덤 이미지 URL (몇몇은 의도적으로 빈 문자열로 설정하여 기본 이미지 표시)
      final String imageUrl =
          i % 10 == 0
              ? "" // 10명 중 1명은 이미지 없음
              : "$baseImageUrl${categories[i % 2]}/${(i % 70) + 1}.jpg";

      // 활성 상태일 경우 경과 시간 랜덤 생성
      final int elapsedSeconds =
          isActive
              ? (random.nextInt(48) + 1) * 3600 +
                  random.nextInt(3600) // 1~48시간 + 랜덤 분/초
              : 0; // 휴식 중인 경우 0

      mockMembers.add(
        MemberTimer(
          memberId: memberId,
          memberName: memberName,
          imageUrl: imageUrl,
          elapsedSeconds: elapsedSeconds,
          status:
              isActive ? MemberTimerStatus.active : MemberTimerStatus.sleeping,
        ),
      );
    }

    return mockMembers;
  }
}
