// lib/auth/domain/usecase/validate_nickname_use_case.dart
class ValidateNicknameUseCase {
  Future<String?> execute(String nickname) async {
    if (nickname.isEmpty) {
      return '닉네임을 입력해주세요';
    }

    if (nickname.length < 2) {
      return '닉네임은 2자 이상이어야 합니다';
    }

    if (nickname.length > 10) {
      return '닉네임은 10자 이하여야 합니다';
    }

    // 특수문자 제한
    if (!RegExp(r'^[a-zA-Z0-9가-힣]+$').hasMatch(nickname)) {
      return '닉네임은 한글, 영문, 숫자만 사용 가능합니다';
    }

    return null; // 유효한 경우
  }
}