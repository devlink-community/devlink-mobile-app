// lib/auth/domain/usecase/validate_password_confirm_use_case.dart
class ValidatePasswordConfirmUseCase {
  Future<String?> execute(String password, String passwordConfirm) async {
    if (passwordConfirm.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }

    if (password != passwordConfirm) {
      return '비밀번호가 일치하지 않습니다';
    }

    return null; // 유효한 경우
  }
}