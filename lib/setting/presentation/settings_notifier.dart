import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/domain/usecase/delete_account_use_case.dart';
import '../domain/service/app_version_service.dart';
import '../domain/usecase/logout_usecase.dart';
import '../module/settings_di.dart';
import 'settings_action.dart';
import 'settings_state.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final LogoutUseCase _logoutUseCase;
  late final DeleteAccountUseCase _deleteAccountUseCase;
  late final AppVersionService _appVersionService;

  @override
  SettingsState build() {
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _deleteAccountUseCase = ref.watch(deleteAccountUseCaseProvider);
    _appVersionService = ref.watch(appVersionServiceProvider);

    // 컴포넌트가 처음 로드될 때 앱 버전 정보를 자동으로 로드
    _loadAppVersion();

    return const SettingsState();
  }

  Future<void> onAction(SettingsAction action) async {
    switch (action) {
      case OnTapLogout():
        await _handleLogout();
      case OnTapDeleteAccount():
        await _handleDeleteAccount();
      case LoadAppVersion():
        await _loadAppVersion();
      // 화면 이동 액션들은 Root에서 처리됨
      case OnTapEditProfile():
      case OnTapChangePassword():
      case OnTapPrivacyPolicy():
      case OnTapOpenSourceLicenses():
      // URL 열기 액션들도 Root에서 처리됨
      case OpenUrlPrivacyPolicy():
      case OpenUrlAppInfo():
      case OpenAppStore():
      case OpenPlayStore():
        break;
    }
  }

  Future<void> _handleLogout() async {
    state = state.copyWith(logoutResult: const AsyncLoading());
    final asyncResult = await _logoutUseCase.execute();
    state = state.copyWith(logoutResult: asyncResult);
  }

  Future<void> _handleDeleteAccount() async {
    state = state.copyWith(deleteAccountResult: const AsyncLoading());
    // 현재 로그인된 사용자의 이메일을 가져오는 로직이 필요합니다.
    // 임시로 'current@example.com'을 사용합니다.
    // 실제 구현에서는 getCurrentUser() 등을 통해 가져와야 합니다.
    final email = 'current@example.com'; // 실제 구현 필요
    final asyncResult = await _deleteAccountUseCase.execute(email);
    state = state.copyWith(deleteAccountResult: asyncResult);
  }

  Future<void> _loadAppVersion() async {
    state = state.copyWith(appVersionResult: const AsyncLoading());
    try {
      final appVersion = await _appVersionService.getAppVersion();
      state = state.copyWith(appVersionResult: AsyncData(appVersion));
    } catch (e, stackTrace) {
      state = state.copyWith(appVersionResult: AsyncError(e, stackTrace));
    }
  }
}
