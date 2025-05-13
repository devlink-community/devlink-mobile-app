import 'package:devlink_mobile_app/auth/data/data_source/profile_data_source.dart';
import 'package:devlink_mobile_app/auth/data/data_source/user_storage.dart';

class MockProfileDataSource implements ProfileDataSource {
  final _storage = UserStorage.instance;

  @override
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final profile = _storage.getProfileById(userId);

    if (profile == null) {
      throw Exception('프로필을 찾을 수 없습니다');
    }

    return profile.toJson();
  }
}
