import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/domain/repository/auth_repository.dart';
import '../../../core/result/result.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<AsyncValue<void>> execute() async {
    final result = await _repository.signOut();

    switch (result) {
      case Success():
        return const AsyncData(null);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
