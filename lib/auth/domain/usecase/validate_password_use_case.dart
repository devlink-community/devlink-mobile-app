// lib/auth/domain/usecase/validate_password_use_case.dart
class ValidatePasswordUseCase {
  Future<String?> execute(String password) async {
    if (password.isEmpty) {
      return '비밀번호를 입력해주세요';
    }

    if (password.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }

    // 복잡성 요구사항 검증
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!(hasUppercase && hasLowercase && hasDigit && hasSpecialChar)) {
      return '비밀번호는 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다';
    }

    return null; // 유효한 경우
  }
}