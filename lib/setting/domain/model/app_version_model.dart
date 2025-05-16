class AppVersionModel {
  final String version;
  final String buildNumber;
  final String appStoreUrl;
  final String playStoreUrl;

  const AppVersionModel({
    required this.version,
    required this.buildNumber,
    required this.appStoreUrl,
    required this.playStoreUrl,
  });

  String get versionWithBuild => '$version ($buildNumber)';
}
