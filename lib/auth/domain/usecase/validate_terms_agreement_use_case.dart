// lib/auth/domain/usecase/validate_terms_agreement_use_case.dart
class ValidateTermsAgreementUseCase {
  Future<String?> execute(bool agreed) async {
    if (!agreed) {
      return '이용약관에 동의해주세요';
    }

    return null; // 유효한 경우
  }
}