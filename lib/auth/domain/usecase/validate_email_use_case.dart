// lib/auth/domain/usecase/validate_email_use_case.dart
class ValidateEmailUseCase {
  Future<String?> execute(String email) async {
    if (email.isEmpty) {
      return '이메일을 입력해주세요';
    }

    // 이메일 형식 유효성 검사는 대소문자 구분 없이 수행
    // 실제 이메일은 대소문자를 구분하지 않으므로 형식 검증만 수행하고
    // 실제 DB 저장/조회 시 소문자 변환은 DataSource에서 처리
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return '유효한 이메일 형식이 아닙니다';
    }

    return null; // 유효한 경우
  }
}