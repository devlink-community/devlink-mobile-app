// lib/auth/domain/usecase/profile/update_profile_use_case.dart
import 'package:devlink_mobile_app/auth/domain/model/user.dart';
import 'package:devlink_mobile_app/auth/domain/repository/auth_profile_repository.dart';
import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdateProfileUseCase {
  final AuthProfileRepository _repository;

  UpdateProfileUseCase({required AuthProfileRepository repository})
    : _repository = repository;

  Future<AsyncValue<User>> execute({
    required String nickname,
    String? description,
    String? position,
    String? skills,
  }) async {
    final result = await _repository.updateProfile(
      nickname: nickname,
      description: description,
      position: position,
      skills: skills,
    );

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
