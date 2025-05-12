import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:devlink_mobile_app/group/domain/model/member_timer.dart';
import 'package:devlink_mobile_app/group/domain/model/timer_session.dart';

abstract interface class TimerRepository {
  /// 새 타이머 세션 시작
  Future<Result<TimerSession>> startTimer({
    required String groupId,
    required String userId,
  });

  /// 진행 중인 타이머 세션 종료
  Future<Result<TimerSession>> stopTimer({
    required String sessionId,
    required int duration,
  });

  /// 타이머 세션 목록 조회 (그룹별)
  Future<Result<List<TimerSession>>> getTimerSessions(String groupId);

  /// 타이머 세션 상세 조회
  Future<Result<TimerSession>> getTimerSession(String sessionId);

  /// 유저의 진행 중인 타이머 조회
  Future<Result<TimerSession?>> getActiveTimerSession(String userId);

  /// 그룹의 멤버 타이머 상태 목록 조회
  Future<Result<List<MemberTimer>>> getMemberTimers(String groupId);
}
