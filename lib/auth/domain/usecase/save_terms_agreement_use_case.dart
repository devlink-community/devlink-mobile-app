// lib/auth/domain/usecase/save_terms_agreement_use_case.dart
import 'package:devlink_mobile_app/auth/domain/model/terms_agreement.dart';
import 'package:devlink_mobile_app/auth/domain/repository/auth_repository.dart';
import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SaveTermsAgreementUseCase {
  final AuthRepository _repository;

  SaveTermsAgreementUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<AsyncValue<TermsAgreement>> execute(TermsAgreement termsAgreement) async {
    // 현재 시간으로 동의 시간 설정
    final updatedTerms = TermsAgreement(
      id: termsAgreement.id,
      isAllAgreed: termsAgreement.isAllAgreed,
      isServiceTermsAgreed: termsAgreement.isServiceTermsAgreed,
      isPrivacyPolicyAgreed: termsAgreement.isPrivacyPolicyAgreed,
      isMarketingAgreed: termsAgreement.isMarketingAgreed,
      agreedAt: DateTime.now(), // 현재 시간으로 동의 시간 업데이트
    );

    // 필수 약관 동의 여부 확인
    if (!updatedTerms.isRequiredTermsAgreed) {
      return AsyncError(
        Failure(
          FailureType.validation,
          '필수 약관에 동의해야 합니다',
        ),
        StackTrace.current,
      );
    }

    final result = await _repository.saveTermsAgreement(updatedTerms);

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(failure: final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}