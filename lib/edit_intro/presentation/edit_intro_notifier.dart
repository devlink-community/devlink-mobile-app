import 'dart:io';
import 'package:devlink_mobile_app/edit_intro/presentation/edit_intro_action.dart';
import 'package:devlink_mobile_app/edit_intro/presentation/states/edit_intro_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/result/result.dart';
import '../domain/usecase/get_current_profile_usecase.dart';
import '../domain/usecase/update_profile_image_usecase.dart';
import '../domain/usecase/update_profile_usecase.dart';
import '../module/edit_intro_di.dart';

part 'edit_intro_notifier.g.dart';

@riverpod
class EditIntroNotifier extends _$EditIntroNotifier {
  late final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final UpdateProfileImageUseCase _updateProfileImageUseCase;

  @override
  EditIntroState build() {
    _getCurrentProfileUseCase = ref.watch(getCurrentProfileUseCaseProvider);
    _updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);
    _updateProfileImageUseCase = ref.watch(updateProfileImageUseCaseProvider);

    // 초기 상태만 반환하고, 프로필 로드는 별도 메서드로 분리
    return const EditIntroState();
  }

  // 프로필 로드를 public 메서드로 변경하여 외부에서 호출 가능하게 함
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    final result = await _getCurrentProfileUseCase.execute();

    switch (result) {
      case Success(:final data):
        state = state.copyWith(isLoading: false, isSuccess: true, member: data);
      case Error(:final failure):
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: failure.message,
        );
    }
  }

  Future<void> onAction(EditIntroAction action) async {
    switch (action) {
      case OnChangeNickname(:final nickname):
        if (state.member != null) {
          final updatedMember = state.member!.copyWith(nickname: nickname);
          state = state.copyWith(member: updatedMember);
        }
        break;

      case OnChangeMessage(:final message):
        if (state.member != null) {
          final updatedMember = state.member!.copyWith(description: message);
          state = state.copyWith(member: updatedMember);
        }
        break;

      case OnPickImage(:final image):
        await _updateProfileImage(image);
        break;

      case OnSave():
        await _saveProfile();
        break;
    }
  }

  Future<void> updateProfileImage(XFile image) async {
    await _updateProfileImage(File(image.path));
  }

  Future<void> _updateProfileImage(File image) async {
    state = state.copyWith(
      isImageUploading: true,
      isImageUploadError: false,
      imageUploadErrorMessage: null,
    );

    try {
      final xFile = XFile(image.path);
      final result = await _updateProfileImageUseCase.execute(xFile);

      if (result is AsyncData) {
        state = state.copyWith(
          isImageUploading: false,
          isImageUploadSuccess: true,
          member: result.value,
        );
      } else if (result is AsyncError) {
        final error = result.error;
        state = state.copyWith(
          isImageUploading: false,
          isImageUploadError: true,
          imageUploadErrorMessage: error.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isImageUploading: false,
        isImageUploadError: true,
        imageUploadErrorMessage: '프로필 이미지를 업데이트할 수 없습니다: ${e.toString()}',
      );
    }
  }

  Future<bool> updateProfile({required String nickname, String? intro}) async {
    final updated = state.member?.copyWith(
      nickname: nickname,
      description: intro ?? state.member?.description ?? '',
    );

    if (updated != null) {
      state = state.copyWith(member: updated);
    }

    return await _saveProfile();
  }

  Future<bool> _saveProfile() async {
    if (state.member == null) return false;

    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final result = await _updateProfileUseCase.execute(
        nickname: state.member!.nickname,
        intro: state.member!.description,
      );

      if (result is AsyncData) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          member: result.value,
        );
        return true;
      } else if (result is AsyncError) {
        final error = result.error;
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: error.toString(),
        );
        return false;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: '프로필 정보를 수정할 수 없습니다: ${e.toString()}',
      );
      return false;
    }
  }
}
