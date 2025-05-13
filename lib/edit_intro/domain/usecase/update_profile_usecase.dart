import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result/result.dart';
import '../repository/edit_intro_repository.dart';

class UpdateProfileUseCase {
  final EditIntroRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<AsyncValue<Member>> execute({
    required String nickname,
    String? intro,
  }) async {
    final result = await _repository.updateProfile(
      nickname: nickname,
      intro: intro,
    );

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
