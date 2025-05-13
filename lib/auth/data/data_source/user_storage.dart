// lib/auth/data/data_source/user_storage.dart
import 'package:devlink_mobile_app/auth/data/dto/profile_dto.dart';
import 'package:devlink_mobile_app/auth/data/dto/user_dto.dart';

/// 통합 사용자 데이터 저장소 (싱글톤)
class UserStorage {
  UserStorage._internal();
  static final UserStorage _instance = UserStorage._internal();
  static UserStorage get instance => _instance;

  // 전체 사용자 데이터
  final Map<String, UserDto> _users = {};
  final Map<String, ProfileDto> _profiles = {};
  final Map<String, String> _passwords = {}; // 비밀번호 저장 (실제로는 암호화해야 함)

  // 약관 동의 정보 저장소
  final Map<String, Map<String, dynamic>> _termsAgreements = {};

  // 현재 로그인된 사용자
  String? _currentUserId;

  /// 기본 사용자 7명 초기화
  void _initializeDefaultUsers() {
    if (_users.isEmpty) {
      final defaultUsers = [
        {
          'user': UserDto(id: 'user1', email: 'test1@example.com'.toLowerCase(), nickname: '사용자1', uid: 'uid1'),
          'profile': ProfileDto(userId: 'user1', image: '', onAir: false),
          'password': 'password123',
        },
        {
          'user': UserDto(id: 'user2', email: 'test2@example.com'.toLowerCase(), nickname: '사용자2', uid: 'uid2'),
          'profile': ProfileDto(userId: 'user2', image: '', onAir: true),
          'password': 'password123',
        },
        {
          'user': UserDto(id: 'user3', email: 'test3@example.com'.toLowerCase(), nickname: '사용자3', uid: 'uid3'),
          'profile': ProfileDto(userId: 'user3', image: '', onAir: false),
          'password': 'password123',
        },
        {
          'user': UserDto(id: 'user4', email: 'test4@example.com'.toLowerCase(), nickname: '사용자4', uid: 'uid4'),
          'profile': ProfileDto(userId: 'user4', image: '', onAir: true),
          'password': 'password123',
        },
        {
          'user': UserDto(id: 'user5', email: 'test5@example.com'.toLowerCase(), nickname: '사용자5', uid: 'uid5'),
          'profile': ProfileDto(userId: 'user5', image: '', onAir: false),
          'password': 'password123',
        },
        {
          'user': UserDto(id: 'user6', email: 'admin@example.com'.toLowerCase(), nickname: '관리자', uid: 'uid6'),
          'profile': ProfileDto(userId: 'user6', image: '', onAir: true),
          'password': 'admin123',
        },
        {
          'user': UserDto(id: 'user7', email: 'developer@example.com'.toLowerCase(), nickname: '개발자', uid: 'uid7'),
          'profile': ProfileDto(userId: 'user7', image: '', onAir: true),
          'password': 'dev123',
        },
      ];

      for (final userData in defaultUsers) {
        final user = userData['user'] as UserDto;
        final profile = userData['profile'] as ProfileDto;
        final password = userData['password'] as String;

        _users[user.email!] = user;
        _profiles[user.id!] = profile;
        _passwords[user.email!] = password;
      }
    }
  }

  /// 초기화 (앱 시작 시 호출)
  void initialize() {
    _initializeDefaultUsers();
  }

  /// 사용자 조회 (이메일로)
  UserDto? getUserByEmail(String email) {
    initialize();
    // 이메일을 소문자로 변환
    return _users[email.toLowerCase()];
  }

  /// 프로필 조회 (ID로)
  ProfileDto? getProfileById(String userId) {
    initialize();
    return _profiles[userId];
  }

  /// 비밀번호 확인
  bool validatePassword(String email, String password) {
    initialize();
    // 이메일을 소문자로 변환
    return _passwords[email.toLowerCase()] == password;
  }

  /// 사용자 추가 (회원가입)
  void addUser(UserDto user, ProfileDto profile, String password, {String? agreedTermsId}) {
    initialize();
    // 이메일을 소문자로 변환하여 저장
    final lowercaseEmail = user.email!.toLowerCase();

    // 이메일은 소문자로 저장하되, 다른 필드는 원래값 유지
    final updatedUser = UserDto(
      id: user.id,
      email: lowercaseEmail,
      nickname: user.nickname,
      uid: user.uid,
      agreedTermsId: agreedTermsId,
    );

    _users[lowercaseEmail] = updatedUser;
    _profiles[user.id!] = profile;
    _passwords[lowercaseEmail] = password;

    // 약관 동의 ID가 있으면 사용자에 연결
    if (agreedTermsId != null) {
      final updatedUserWithTerms = UserDto(
        id: user.id,
        email: lowercaseEmail,
        nickname: user.nickname,
        uid: user.uid,
        agreedTermsId: agreedTermsId, // 약관 동의 ID 추가
      );
      _users[lowercaseEmail] = updatedUserWithTerms;
    }
  }

  /// 사용자 삭제 (계정삭제)
  void deleteUser(String email) {
    initialize();
    // 이메일을 소문자로 변환
    final lowercaseEmail = email.toLowerCase();
    final user = _users[lowercaseEmail];

    if (user != null) {
      _profiles.remove(user.id);
      _users.remove(lowercaseEmail);
      _passwords.remove(lowercaseEmail);
      // 현재 로그인된 사용자가 삭제되면 로그아웃
      if (_currentUserId == user.id) {
        _currentUserId = null;
      }
    }
  }

  /// 로그인
  void login(String userId) {
    _currentUserId = userId;
  }

  /// 로그아웃
  void logout() {
    _currentUserId = null;
  }

  /// 현재 로그인된 사용자 ID 조회
  String? get currentUserId => _currentUserId;

  /// 현재 로그인된 사용자 조회
  UserDto? get currentUser {
    if (_currentUserId == null) return null;
    return _users.values.firstWhere(
          (user) => user.id == _currentUserId,
      orElse: () => throw Exception('현재 사용자를 찾을 수 없습니다'),
    );
  }

  /// 닉네임 중복 체크
  bool isNicknameAvailable(String nickname) {
    initialize();
    return !_users.values.any((user) => user.nickname?.toLowerCase() == nickname.toLowerCase());
  }

  /// 이메일 중복 체크
  bool isEmailAvailable(String email) {
    initialize();
    // 이메일을 소문자로 변환하여 확인
    return !_users.containsKey(email.toLowerCase());
  }

  /// 약관 동의 정보 저장
  Map<String, dynamic> saveTermsAgreement(Map<String, dynamic> termsData) {
    final termsId = termsData['id'] as String;
    _termsAgreements[termsId] = termsData;
    return termsData;
  }

  /// 약관 정보 조회
  Map<String, dynamic>? getTermsInfo(String termsId) {
    return _termsAgreements[termsId];
  }

  /// 약관 동의 정보와 사용자 연결
  void linkUserWithTerms(String userId, String termsId) {
    final user = _users.values.firstWhere(
          (user) => user.id == userId,
      orElse: () => throw Exception('사용자를 찾을 수 없습니다'),
    );

    // 이메일은 항상 소문자로 유지
    final lowercaseEmail = user.email!.toLowerCase();

    final updatedUser = UserDto(
      id: user.id,
      email: lowercaseEmail,
      nickname: user.nickname,
      uid: user.uid,
      agreedTermsId: termsId,
    );

    _users[lowercaseEmail] = updatedUser;
  }
}