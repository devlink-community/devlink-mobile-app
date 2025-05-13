import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/domain/usecase/delete_account_use_case.dart';
import '../../auth/module/auth_di.dart';
import '../domain/usecase/logout_usecase.dart';

part 'settings_di.g.dart';

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(DeleteAccountUseCaseRef ref) {
  return DeleteAccountUseCase(repository: ref.watch(authRepositoryProvider));
}
