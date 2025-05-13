import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';
import 'package:devlink_mobile_app/setting/presentation/settings_action.dart';
import 'package:devlink_mobile_app/setting/presentation/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsState state;
  final void Function(SettingsAction action) onAction;

  const SettingsScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('환경설정', style: AppTextStyles.heading3Bold),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 명시적으로 '/intro' 경로로 이동 (뒤로가기)
            context.go('/intro');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: ListView(
                children: [
                  _buildSettingItem(
                    title: '프로필 수정',
                    onTap:
                        () => onAction(const SettingsAction.onTapEditProfile()),
                  ),
                  _buildSettingItem(
                    title: '비밀번호 수정',
                    onTap:
                        () => onAction(
                          const SettingsAction.onTapChangePassword(),
                        ),
                  ),
                  _buildSettingItem(
                    title: '개인정보 처리방침',
                    onTap:
                        () =>
                            onAction(const SettingsAction.onTapPrivacyPolicy()),
                  ),
                  _buildSettingItem(
                    title: '앱 사용 오픈 소스',
                    onTap: () => onAction(const SettingsAction.onTapAppInfo()),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorStyles.primary100,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        () => onAction(const SettingsAction.onTapLogout()),
                    child: Text(
                      '로그아웃',
                      style: AppTextStyles.button1Medium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        () =>
                            onAction(const SettingsAction.onTapDeleteAccount()),
                    child: Text(
                      '회원탈퇴',
                      style: AppTextStyles.button1Medium.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Text(
                //   '버전 ${state.appVersion}',
                //   style: AppTextStyles.captionRegular.copyWith(color: Colors.grey),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: AppTextStyles.subtitle1Medium),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      onTap: onTap,
    );
  }
}
