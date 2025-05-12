// lib/auth/data/data_source/mock_auth_data_source.dart
import 'dart:async';

import '../dto/profile_dto.dart';
import '../dto/user_dto.dart';
import 'auth_data_source.dart';
import 'user_storage.dart';

class MockAuthDataSource implements AuthDataSource {
  final _storage = UserStorage.instance;

  @override
  Future<Map<String, dynamic>> fetchLogin({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = _storage.getUserByEmail(email);

    // 사용자 존재 확인 및 비밀번호 검증
    if (user != null && _validatePassword(email, password)) {
      _storage.login(user.id!);
      return user.toJson();
    } else {
      throw Exception('이메일 또는 비밀번호가 일치하지 않습니다');
    }
  }

  @override
  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String nickname,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 중복 체크
    if (!_storage.isEmailAvailable(email)) {
      throw Exception('이미 사용 중인 이메일입니다');
    }

    if (!_storage.isNicknameAvailable(nickname)) {
      throw Exception('이미 사용 중인 닉네임입니다');
    }

    // 새 사용자 생성
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final userDto = UserDto(
      id: userId,
      email: email,
      nickname: nickname,
      uid: 'uid_$userId',
    );

    final profileDto = ProfileDto(
      userId: userId,
      image: '',
      onAir: false,
    );

    // 비밀번호는 별도 저장 (여기서는 간단히 구현)
    _storage.addUser(userDto, profileDto, password);

    return userDto.toJson();
  }

  @override
  Future<Map<String, dynamic>?> fetchCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final currentUser = _storage.currentUser;
    return currentUser?.toJson();
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _storage.logout();
  }

  @override
  Future<bool> checkNicknameAvailability(String nickname) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.isNicknameAvailable(nickname);
  }

  @override
  Future<bool> checkEmailAvailability(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.isEmailAvailable(email);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 이메일 형식 확인
    if (!email.contains('@')) {
      throw Exception('유효하지 않은 이메일 형식입니다');
    }

    // 가입된 이메일인지 확인
    final user = _storage.getUserByEmail(email);
    if (user == null) {
      throw Exception('가입되지 않은 이메일입니다');
    }

    // 성공 시 void 반환 (실제로는 이메일 전송)
  }

  @override
  Future<void> deleteAccount(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = _storage.getUserByEmail(email);
    if (user == null) {
      throw Exception('사용자를 찾을 수 없습니다');
    }

    // 현재 로그인된 사용자인지 확인
    if (_storage.currentUserId != user.id) {
      throw Exception('로그인된 사용자만 계정을 삭제할 수 있습니다');
    }

    _storage.deleteUser(email);
  }

  // 비밀번호 검증 메서드
  bool _validatePassword(String email, String password) {
    // UserStorage에서 실제 비밀번호 검증
    return _storage.validatePassword(email, password);
  }
}