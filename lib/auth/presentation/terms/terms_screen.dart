import 'package:devlink_mobile_app/auth/presentation/component/custom_button.dart';
import 'package:devlink_mobile_app/auth/presentation/terms/terms_action.dart';
import 'package:devlink_mobile_app/auth/presentation/terms/terms_state.dart';
import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  final TermsState state;
  final void Function(TermsAction action) onAction;

  const TermsScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 영역 - 이미지 및 설명
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 이미지 표시
                    Image.asset(
                      'assets/images/gaesubang_mascot1.png', // 실제 앱에 맞는 이미지 경로
                      width: 258,
                      height: 258,
                    ),

                    // 타이틀 텍스트
                    Text(
                      '개수방 멤버쉽에',
                      style: AppTextStyles.subtitle1Bold.copyWith(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '오신 것을 환영합니다.',
                      style: AppTextStyles.subtitle1Bold.copyWith(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 체크박스 영역
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // 전체 동의 체크박스
                    _buildCheckbox(
                      title: '모든 약관에 동의합니다.',
                      isChecked: state.isAllAgreed,
                      onChanged: (value) => onAction(TermsAction.allAgreedChanged(value ?? false)),
                      bold: true,
                    ),
                    const SizedBox(height: 24),

                    // 서비스 이용약관 동의 (필수)
                    _buildCheckboxWithButton(
                      title: '서비스 이용 약관',
                      subtitle: '(필수)',
                      isChecked: state.isServiceTermsAgreed,
                      onChanged: (value) => onAction(
                        TermsAction.serviceTermsAgreedChanged(value ?? false),
                      ),
                      onButtonPressed: () => onAction(
                        const TermsAction.viewTermsDetail('service'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 개인정보 처리방침 동의 (필수)
                    _buildCheckboxWithButton(
                      title: '개인정보 수집 및 이용 동의',
                      subtitle: '(필수)',
                      isChecked: state.isPrivacyPolicyAgreed,
                      onChanged: (value) => onAction(
                        TermsAction.privacyPolicyAgreedChanged(value ?? false),
                      ),
                      onButtonPressed: () => onAction(
                        const TermsAction.viewTermsDetail('privacy'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 마케팅 정보 수신 동의 (선택)
                    _buildCheckboxWithButton(
                      title: '마케팅 정보 수신 동의',
                      subtitle: '(선택)',
                      isChecked: state.isMarketingAgreed,
                      onChanged: (value) => onAction(
                        TermsAction.marketingAgreedChanged(value ?? false),
                      ),
                      onButtonPressed: () => onAction(
                        const TermsAction.viewTermsDetail('marketing'),
                      ),
                    ),

                    // 에러 메시지 표시
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          state.errorMessage!,
                          style: AppTextStyles.captionRegular.copyWith(
                            color: AppColorStyles.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 버튼 영역
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: CustomButton(
                  text: '동의하고 계속하기',
                  onPressed: () => onAction(const TermsAction.submit()),
                  isLoading: state.isSubmitting,
                  backgroundColor: AppColorStyles.primary100,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 기본 체크박스 위젯
  Widget _buildCheckbox({
    required String title,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    bool bold = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: AppColorStyles.primary100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: bold
                ? AppTextStyles.subtitle1Bold.copyWith(fontSize: 16)
                : AppTextStyles.body1Regular,
          ),
        ),
      ],
    );
  }

  // 체크박스 + 버튼 위젯
  Widget _buildCheckboxWithButton({
    required String title,
    required String subtitle,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onButtonPressed,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: AppColorStyles.primary100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.body1Regular.copyWith(
                color: Colors.black,
              ),
              children: [
                TextSpan(text: title),
                TextSpan(
                  text: ' $subtitle',
                  style: TextStyle(
                    color: subtitle.contains('필수')
                        ? AppColorStyles.primary100
                        : AppColorStyles.gray80,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: onButtonPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(40, 20),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '보기',
            style: AppTextStyles.body2Regular.copyWith(
              color: AppColorStyles.gray80,
            ),
          ),
        ),
      ],
    );
  }
}