// lib/auth/presentation/terms/terms_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'terms_state.freezed.dart';

@freezed
class TermsState with _$TermsState {
  const TermsState({
    this.isAllAgreed = false,
    this.isServiceTermsAgreed = false,
    this.isPrivacyPolicyAgreed = false,
    this.isMarketingAgreed = false,
    this.errorMessage,
    this.savedTermsId,
    this.isSubmitting = false, // 추가
  });

  final bool isAllAgreed;
  final bool isServiceTermsAgreed;
  final bool isPrivacyPolicyAgreed;
  final bool isMarketingAgreed;
  final String? errorMessage;
  final String? savedTermsId;
  final bool isSubmitting; // 추가
}