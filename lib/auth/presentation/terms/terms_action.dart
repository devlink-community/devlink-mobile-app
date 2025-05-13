// lib/auth/presentation/terms/terms_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'terms_action.freezed.dart';

@freezed
sealed class TermsAction with _$TermsAction {
  const factory TermsAction.allAgreedChanged(bool value) = AllAgreedChanged;
  const factory TermsAction.serviceTermsAgreedChanged(bool value) = ServiceTermsAgreedChanged;
  const factory TermsAction.privacyPolicyAgreedChanged(bool value) = PrivacyPolicyAgreedChanged;
  const factory TermsAction.marketingAgreedChanged(bool value) = MarketingAgreedChanged;
  const factory TermsAction.viewTermsDetail(String termType) = ViewTermsDetail;
  const factory TermsAction.submit() = Submit;
  const factory TermsAction.navigateToSignup() = NavigateToSignup;
  const factory TermsAction.navigateBack() = NavigateBack;
}