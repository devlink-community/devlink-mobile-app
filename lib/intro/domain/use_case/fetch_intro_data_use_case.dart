import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/result/result.dart';
import '../repository/intro_repository.dart';

class FetchIntroUserUseCase {
  final IntroRepository _repo;

  FetchIntroUserUseCase(this._repo);

  Future<AsyncValue<Member>> execute() async {
    final result = await _repo.fetchIntroUser();
    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, StackTrace.current);
    }
  }
}
