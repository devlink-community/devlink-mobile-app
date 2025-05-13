import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_intro_action.freezed.dart';

@freezed
sealed class EditIntroAction with _$EditIntroAction {
  const factory EditIntroAction.onChangeNickname(String nickname) =
      OnChangeNickname;
  const factory EditIntroAction.onChangeMessage(String message) =
      OnChangeMessage;
  const factory EditIntroAction.onPickImage(File image) = OnPickImage;
  const factory EditIntroAction.onSave() = OnSave;
}
