// lib/auth/presentation/component/custom_button.dart
import 'package:flutter/material.dart';
import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';

/// 커스텀 버튼 컴포넌트
///
/// 기본, 비활성화, 로딩 상태를 지원합니다.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderRadius = 10,
    this.padding,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColorStyles.primary100,
          foregroundColor: foregroundColor ?? AppColorStyles.white,
          disabledBackgroundColor: disabledBackgroundColor ?? AppColorStyles.primary60,
          disabledForegroundColor: disabledForegroundColor ?? AppColorStyles.white,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: Size.fromHeight(height),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: textStyle ??
              AppTextStyles.button1Medium.copyWith(
                color: AppColorStyles.white,
              ),
        ),
      ),
    );
  }
}