import 'package:freezed_annotation/freezed_annotation.dart';

part 'terms_agreement.freezed.dart';

@freezed
class TermsAgreement with _$TermsAgreement {
  const TermsAgreement({
    required this.id,                    // 약관 ID (하나만 존재)
    this.isAllAgreed = false,            // 전체 동의 여부
    this.isServiceTermsAgreed = false,   // 서비스 이용약관 동의 여부
    this.isPrivacyPolicyAgreed = false,  // 개인정보수집 및 이용 동의 여부
    this.isMarketingAgreed = false,      // 마케팅 정보 수신 동의 여부
    this.agreedAt,                       // 약관 동의 시간
  });

  final String id;
  final bool isAllAgreed;
  final bool isServiceTermsAgreed;
  final bool isPrivacyPolicyAgreed;
  final bool isMarketingAgreed;
  final DateTime? agreedAt;

  // 필수 약관 동의 여부 확인 (서비스 + 개인정보)
  bool get isRequiredTermsAgreed =>
      isServiceTermsAgreed && isPrivacyPolicyAgreed;
}