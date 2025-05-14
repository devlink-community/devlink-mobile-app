import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:devlink_mobile_app/group/domain/model/member_timer.dart';
import 'package:devlink_mobile_app/group/domain/repository/timer_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GetMemberTimersUseCase {
  final TimerRepository _repository;

  GetMemberTimersUseCase({required TimerRepository repository})
    : _repository = repository;

  Future<AsyncValue<List<MemberTimer>>> execute(String groupId) async {
    final result = await _repository.getMemberTimers(groupId);

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(failure: final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
