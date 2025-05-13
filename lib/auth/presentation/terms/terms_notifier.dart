// lib/auth/presentation/terms/terms_notifier.dart
import 'package:devlink_mobile_app/auth/domain/model/terms_agreement.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/get_terms_info_use_case.dart';
import 'package:devlink_mobile_app/auth/domain/usecase/save_terms_agreement_use_case.dart';
import 'package:devlink_mobile_app/auth/module/auth_di.dart';
import 'package:devlink_mobile_app/auth/presentation/terms/terms_action.dart';
import 'package:devlink_mobile_app/auth/presentation/terms/terms_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'terms_notifier.g.dart';

@riverpod
class TermsNotifier extends _$TermsNotifier {
  late final GetTermsInfoUseCase _getTermsInfoUseCase;
  late final SaveTermsAgreementUseCase _saveTermsAgreementUseCase;

  @override
  TermsState build() {
    _getTermsInfoUseCase = ref.watch(getTermsInfoUseCaseProvider);
    _saveTermsAgreementUseCase = ref.watch(saveTermsAgreementUseCaseProvider);

    // 앱 시작 시 약관 정보 로드
    _loadTermsInfo();

    return const TermsState();
  }

  Future<void> _loadTermsInfo() async {
    // termsId가 없는 경우 기본 약관 정보 로드
    final result = await _getTermsInfoUseCase.execute(null);

    if (result.hasValue && result.value != null) {
      // 약관 정보 로드 성공
      state = state.copyWith(
        errorMessage: null,
      );
    } else if (result.hasError) {
      // 약관 정보 로드 실패
      state = state.copyWith(
        errorMessage: '약관 정보를 불러오는데 실패했습니다.',
      );
    }
  }

  Future<void> onAction(TermsAction action) async {
    switch (action) {
      case AllAgreedChanged(:final value):
        _handleAllAgreedChanged(value);
        break;

      case ServiceTermsAgreedChanged(:final value):
        _handleServiceTermsAgreedChanged(value);
        break;

      case PrivacyPolicyAgreedChanged(:final value):
        _handlePrivacyPolicyAgreedChanged(value);
        break;

      case MarketingAgreedChanged(:final value):
        _handleMarketingAgreedChanged(value);
        break;

      case ViewTermsDetail(:final termType):
      // Root에서 처리할 예정이므로 여기서는 로직 미구현
        break;

      case Submit():
        await _handleSubmit();
        break;

      case NavigateToSignup():
      case NavigateBack():
      // Root에서 처리할 예정이므로 여기서는 로직 미구현
        break;
    }
  }

  void _handleAllAgreedChanged(bool value) {
    state = state.copyWith(
      isAllAgreed: value,
      isServiceTermsAgreed: value,
      isPrivacyPolicyAgreed: value,
      isMarketingAgreed: value,
    );
  }

  void _handleServiceTermsAgreedChanged(bool value) {
    state = state.copyWith(
      isServiceTermsAgreed: value,
      // 전체 동의 상태 업데이트
      isAllAgreed: value && state.isPrivacyPolicyAgreed && state.isMarketingAgreed,
    );
  }

  void _handlePrivacyPolicyAgreedChanged(bool value) {
    state = state.copyWith(
      isPrivacyPolicyAgreed: value,
      // 전체 동의 상태 업데이트
      isAllAgreed: state.isServiceTermsAgreed && value && state.isMarketingAgreed,
    );
  }

  void _handleMarketingAgreedChanged(bool value) {
    state = state.copyWith(
      isMarketingAgreed: value,
      // 전체 동의 상태 업데이트
      isAllAgreed: state.isServiceTermsAgreed && state.isPrivacyPolicyAgreed && value,
    );
  }

  Future<void> _handleSubmit() async {
    // 필수 약관 체크 확인
    if (!state.isServiceTermsAgreed || !state.isPrivacyPolicyAgreed) {
      state = state.copyWith(
        errorMessage: '필수 약관에 동의해주세요.',
      );
      return;
    }

    // 에러 메시지 초기화
    state = state.copyWith(
      errorMessage: null,
      isSubmitting: true,
    );

    // 약관 동의 정보 저장
    final termsAgreement = TermsAgreement(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 고유 ID 생성
      isAllAgreed: state.isAllAgreed,
      isServiceTermsAgreed: state.isServiceTermsAgreed,
      isPrivacyPolicyAgreed: state.isPrivacyPolicyAgreed,
      isMarketingAgreed: state.isMarketingAgreed,
      agreedAt: DateTime.now(),
    );

    final result = await _saveTermsAgreementUseCase.execute(termsAgreement);

    if (result.hasValue) {
      // 약관 동의 저장 성공
      final savedTermsId = result.value?.id;
      state = state.copyWith(
        isSubmitting: false,
        savedTermsId: savedTermsId,
        errorMessage: null,
      );

      // 여기서는 상태만 업데이트하고, 화면 이동은 Root에서 처리
    } else if (result.hasError) {
      // 약관 동의 저장 실패
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '약관 동의 저장에 실패했습니다.',
      );
    }
  }



  void resetState() {
    state = const TermsState();
  }
}