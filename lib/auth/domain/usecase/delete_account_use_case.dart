// lib/auth/domain/usecase/delete_account_use_case.dart
import 'package:devlink_mobile_app/auth/domain/repository/auth_repository.dart';
import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<AsyncValue<void>> execute(String email) async {
    final result = await _repository.deleteAccount(email);

    switch (result) {
      case Success():
        return const AsyncData(null);
      case Error(failure: final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}