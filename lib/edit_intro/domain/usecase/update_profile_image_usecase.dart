import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/result/result.dart';
import '../repository/edit_intro_repository.dart';

class UpdateProfileImageUseCase {
  final EditIntroRepository _repository;

  UpdateProfileImageUseCase(this._repository);

  Future<AsyncValue<Member>> execute(XFile image) async {
    final result = await _repository.updateProfileImage(image);

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
