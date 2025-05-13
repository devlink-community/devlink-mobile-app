import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_intro_state.freezed.dart';

@freezed
class EditIntroState with _$EditIntroState {
  /// generative constructor
  const EditIntroState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.member,
    this.isImageUploading = false,
    this.isImageUploadSuccess = false,
    this.isImageUploadError = false,
    this.imageUploadErrorMessage,
  });

  /// 필드 선언
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final Member? member;
  final bool isImageUploading;
  final bool isImageUploadSuccess;
  final bool isImageUploadError;
  final String? imageUploadErrorMessage;

  /// 편의 getter
  bool get isInitial => !isLoading && !isSuccess && !isError;
  bool get hasError => isError && errorMessage != null;
  bool get hasImageUploadError =>
      isImageUploadError && imageUploadErrorMessage != null;
}
