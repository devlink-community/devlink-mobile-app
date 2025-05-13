import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

/// 공통으로 사용될 알림 다이얼로그 위젯
///
/// [title] : 경고 문구 (상단 문구)
/// [message] : 세부 메시지 (하단 본문)
/// [cancelText] : 취소 버튼 텍스트 (기본값: '취소')
/// [confirmText] : 확인 버튼 텍스트 (기본값: '확인')
/// [onCancel] : 취소 버튼 클릭 시 콜백
/// [onConfirm] : 확인 버튼 클릭 시 콜백
class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = '취소',
    this.confirmText = '확인',
    this.onCancel,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ContentBox(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    );
  }
}

class ContentBox extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const ContentBox({
    super.key,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    this.onCancel,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘 및 제목
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            child: Column(
              children: [
                // 알림 아이콘
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColorStyles.primary100.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: AppColorStyles.primary60,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),

                // 제목
                Text(
                  title,
                  style: AppTextStyles.heading6Bold.copyWith(
                    color: AppColorStyles.primary100,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 메시지
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            child: Text(
              message,
              style: AppTextStyles.body1Regular.copyWith(
                color: AppColorStyles.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 버튼 영역
          IntrinsicHeight(
            child: Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (onCancel != null) {
                        onCancel!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        cancelText,
                        style: AppTextStyles.subtitle1Bold.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // 확인 버튼
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (onConfirm != null) {
                        onConfirm!();
                      } else {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColorStyles.primary100,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        confirmText,
                        style: AppTextStyles.subtitle1Bold.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
