import '../model/app_version_model.dart';
// import 'package:package_info_plus/package_info_plus.dart';

abstract class AppVersionService {
  Future<AppVersionModel> getAppVersion();
}

class AppVersionServiceImpl implements AppVersionService {
  @override
  Future<AppVersionModel> getAppVersion() async {
    // 실제 구현에서는 package_info_plus 패키지를 사용해 정보를 얻어올 수 있습니다.
    // pubspec.yaml에 다음과 같이 추가해야 합니다:
    // dependencies:
    //   package_info_plus: ^4.0.0
    //
    // 그리고 다음과 같이 사용합니다:
    // final packageInfo = await PackageInfo.fromPlatform();
    // final version = packageInfo.version;
    // final buildNumber = packageInfo.buildNumber;

    // 지금은 테스트를 위해 하드코딩된 값을 반환합니다.
    await Future.delayed(const Duration(milliseconds: 300)); // 비동기 작업 시뮬레이션

    return const AppVersionModel(
      version: '1.0.0',
      buildNumber: '1',
      appStoreUrl: 'https://apps.apple.com/app/devlink/id123456789',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.example.devlink',
    );
  }
}
