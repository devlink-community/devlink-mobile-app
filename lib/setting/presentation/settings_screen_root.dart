import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/component/custom_alert_dialog.dart';
import 'settings_action.dart';
import 'settings_notifier.dart';
import 'settings_screen.dart';

class SettingsScreenRoot extends ConsumerWidget {
  const SettingsScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.watch(settingsNotifierProvider.notifier);

    // 로그아웃 성공 리스너
    ref.listen(settingsNotifierProvider.select((s) => s.logoutResult), (
      previous,
      next,
    ) {
      if (next.hasValue) {
        context.go('/'); // 로그인 화면으로 이동
      } else if (next.hasError) {
        _showErrorSnackBar(context, '로그아웃할 수 없습니다.');
      }
    });

    // 회원탈퇴 성공 리스너
    ref.listen(settingsNotifierProvider.select((s) => s.deleteAccountResult), (
      previous,
      next,
    ) {
      if (next.hasValue) {
        context.go('/'); // 로그인 화면으로 이동
      } else if (next.hasError) {
        _showErrorSnackBar(context, '회원 탈퇴에 실패했습니다.');
      }
    });

    return SettingsScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case OnTapEditProfile():
            context.push('/edit-profile');
          case OnTapChangePassword():
            // 비밀번호 변경을 위해 비밀번호 찾기 화면으로 이동
            context.push('/forget-password');
          case OnTapPrivacyPolicy():
            // 웹 URL 열기
            await _launchUrl('https://www.privacypolicygenerator.info/');
          case OnTapAppInfo():
            // pub.dev로 연결
            await _launchUrl('https://pub.dev/');
          case OnTapLogout():
            _showLogoutConfirmDialog(context, notifier, action);
          case OnTapDeleteAccount():
            _showDeleteAccountConfirmDialog(context, notifier, action);
          case OpenUrlPrivacyPolicy():
            await _launchUrl('https://www.privacypolicygenerator.info/');
          case OpenUrlAppInfo():
            await _launchUrl('https://pub.dev/');
        }
      },
    );
  }

  // URL 실행 메서드
  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      // 외부 앱을 사용하는 방식으로 변경
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // 여기서 사용자에게 스낵바 등으로 알림을 줄 수 있습니다
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showLogoutConfirmDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsAction action,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomAlertDialog(
          title: "Are you sure ?",
          message: "정말 로그아웃 하시겠습니까?",
          cancelText: "Cancel",
          confirmText: "Confrim",
          onConfirm: () {
            Navigator.pop(dialogContext);
            notifier.onAction(action);
          },
        );
      },
    );
  }

  void _showDeleteAccountConfirmDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsAction action,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomAlertDialog(
          title: "Are you sure ?",
          message: "정말 회원탈퇴 하시겠습니까?\n 모든 데이터가 삭제됩니다.",
          cancelText: "Cancel",
          confirmText: "Confirm",
          onConfirm: () {
            Navigator.pop(dialogContext);
            notifier.onAction(action);
          },
        );
      },
    );
  }
}
