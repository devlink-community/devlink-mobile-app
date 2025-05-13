// lib/auth/domain/usecase/check_nickname_availability_use_case.dart
import 'package:devlink_mobile_app/auth/domain/repository/auth_repository.dart';
import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CheckNicknameAvailabilityUseCase {
  final AuthRepository _repository;

  CheckNicknameAvailabilityUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<AsyncValue<bool>> execute(String nickname) async {
    final result = await _repository.checkNicknameAvailability(nickname);

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}