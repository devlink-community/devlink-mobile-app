import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:upgrader/upgrader.dart';

import '../../auth/domain/usecase/delete_account_use_case.dart';
import '../domain/usecase/logout_usecase.dart';
import '../module/settings_di.dart';
import 'settings_action.dart';
import 'settings_state.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final LogoutUseCase _logoutUseCase;
  late final DeleteAccountUseCase _deleteAccountUseCase;

  @override
  SettingsState build() {
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _deleteAccountUseCase = ref.watch(deleteAccountUseCaseProvider);

    // 앱 버전 정보 로드 (결과를 기다리지 않음)
    _loadAppVersion();

    return const SettingsState();
  }

  Future<void> onAction(SettingsAction action) async {
    switch (action) {
      case OnTapLogout():
        await _handleLogout();
      case OnTapDeleteAccount():
        await _handleDeleteAccount();
      // 화면 이동 액션들은 Root에서 처리됨
      case OnTapEditProfile():
      case OnTapChangePassword():
      case OnTapPrivacyPolicy():
      case OnTapOpenSourceLicenses():
      // URL 열기 액션들도 Root에서 처리됨
      case OpenUrlPrivacyPolicy():
      case OpenUrlAppInfo():
      case CheckAppVersion():
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
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      // Upgrader를 사용하여 최신 버전 확인
      final upgrader = Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
        debugLogging: true, // 디버그 로깅 활성화
        messages: UpgraderMessages(code: 'ko'), // 한국어 메시지 설정
      );

      // 앱스토어 버전과 현재 버전 비교 (clearSavedSettings 호출 제거)
      await upgrader.initialize();
      final isUpdateAvailable = upgrader.isUpdateAvailable();

      state = state.copyWith(
        appVersion: appVersion,
        isUpdateAvailable: isUpdateAvailable,
      );
    } catch (e) {
      // 실패 시 기본 버전 정보만 표시
      state = state.copyWith(appVersion: '알 수 없음', isUpdateAvailable: false);
    }
  }
}
