import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:devlink_mobile_app/group/data/data_source/timer_data_source.dart';
import 'package:devlink_mobile_app/group/data/mapper/timer_mapper.dart';
import 'package:devlink_mobile_app/group/domain/model/member_timer.dart';
import 'package:devlink_mobile_app/group/domain/model/timer_session.dart';
import 'package:devlink_mobile_app/group/domain/repository/timer_repository.dart';

class TimerRepositoryImpl implements TimerRepository {
  final TimerDataSource _dataSource;

  TimerRepositoryImpl({required TimerDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<TimerSession>> startTimer({
    required String groupId,
    required String userId,
  }) async {
    try {
      final dto = await _dataSource.startTimer(
        groupId: groupId,
        userId: userId,
      );
      return Result.success(dto.toModel());
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '타이머 세션을 시작하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<TimerSession>> stopTimer({
    required String sessionId,
    required int duration,
  }) async {
    try {
      final dto = await _dataSource.stopTimer(
        sessionId: sessionId,
        duration: duration,
      );
      return Result.success(dto.toModel());
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '타이머 세션을 종료하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<TimerSession>>> getTimerSessions(String groupId) async {
    try {
      final dtoList = await _dataSource.fetchTimerSessions(groupId);
      return Result.success(dtoList.toModelList());
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '타이머 세션 목록을 불러오는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<TimerSession>> getTimerSession(String sessionId) async {
    try {
      final dto = await _dataSource.fetchTimerSession(sessionId);
      return Result.success(dto.toModel());
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '타이머 세션을 불러오는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<TimerSession?>> getActiveTimerSession(String userId) async {
    try {
      final dto = await _dataSource.fetchActiveTimerSession(userId);
      return dto != null
          ? Result.success(dto.toModel())
          : const Result.success(null);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '진행 중인 타이머 세션을 조회하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<MemberTimer>>> getMemberTimers(String groupId) async {
    try {
      final memberTimers = await _dataSource.fetchMemberTimers(groupId);
      return Result.success(memberTimers);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '멤버 타이머 정보를 조회하는데 실패했습니다.', cause: e),
      );
    }
  }
}
