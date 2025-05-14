import 'package:devlink_mobile_app/community/domain/model/hash_tag.dart';
import 'package:devlink_mobile_app/group/domain/model/group.dart';
import 'package:devlink_mobile_app/group/domain/usecase/get_group_detail_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/leave_group_use_case.dart';
import 'package:devlink_mobile_app/group/domain/usecase/update_group_use_case.dart';
import 'package:devlink_mobile_app/group/module/group_di.dart';
import 'package:devlink_mobile_app/group/presentation/group_setting/group_settings_action.dart';
import 'package:devlink_mobile_app/group/presentation/group_setting/group_settings_state.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_settings_notifier.g.dart';

@riverpod
class GroupSettingsNotifier extends _$GroupSettingsNotifier {
  late final GetGroupDetailUseCase _getGroupDetailUseCase;
  late final UpdateGroupUseCase _updateGroupUseCase;
  late final LeaveGroupUseCase _leaveGroupUseCase;

  @override
  GroupSettingsState build(String groupId) {
    _getGroupDetailUseCase = ref.watch(getGroupDetailUseCaseProvider);
    _updateGroupUseCase = ref.watch(updateGroupUseCaseProvider);
    _leaveGroupUseCase = ref.watch(leaveGroupUseCaseProvider);

    // 그룹 정보 로드
    _loadGroupDetail(groupId);

    return const GroupSettingsState();
  }

  Future<void> _loadGroupDetail(String groupId) async {
    final result = await _getGroupDetailUseCase.execute(groupId);

    switch (result) {
      case AsyncData(:final value):
        const currentUserId = 'owner_5'; // 실제 구현에서는 로그인한 사용자 ID
        final isOwner = value.owner.id == currentUserId; // 방장 여부 확인

        state = state.copyWith(
          group: result,
          name: value.name,
          description: value.description,
          imageUrl: value.imageUrl,
          hashTags: value.hashTags,
          limitMemberCount: value.limitMemberCount,
          isOwner: isOwner,
        );
      case AsyncError(:final error):
        state = state.copyWith(
          group: result,
          errorMessage: '그룹 정보를 불러오는데 실패했습니다: $error',
        );
      case AsyncLoading():
        state = state.copyWith(group: result);
    }
  }

  Future<void> onAction(GroupSettingsAction action) async {
    switch (action) {
      case NameChanged(:final name):
        state = state.copyWith(name: name);

      case DescriptionChanged(:final description):
        state = state.copyWith(description: description);

      case LimitMemberCountChanged(:final count):
        final validCount = count < 1 ? 1 : count;
        state = state.copyWith(limitMemberCount: validCount);

      case ImageUrlChanged(:final imageUrl):
        state = state.copyWith(imageUrl: imageUrl);

      case HashTagAdded(:final tag):
        final trimmed = tag.trim();
        if (trimmed.isEmpty ||
            state.hashTags.any((t) => t.content == trimmed) ||
            trimmed.length > 20) {
          return;
        }

        final newTag = HashTag(
          id: DateTime.now().toString(),
          content: tag.trim(),
        );

        state = state.copyWith(hashTags: [...state.hashTags, newTag]);

      case HashTagRemoved(:final tag):
        state = state.copyWith(
          hashTags: state.hashTags.where((t) => t.content != tag).toList(),
        );

      case ToggleEditMode():
        // 현재 편집 모드 상태의 반대로 변경
        state = state.copyWith(isEditing: !state.isEditing);

        // 편집 모드를 종료하면 원래 그룹 정보로 되돌림
        if (!state.isEditing) {
          final originalGroup = state.group.valueOrNull;
          if (originalGroup != null) {
            state = state.copyWith(
              name: originalGroup.name,
              description: originalGroup.description,
              imageUrl: originalGroup.imageUrl,
              hashTags: originalGroup.hashTags,
              limitMemberCount: originalGroup.limitMemberCount,
            );
          }
        }

      case Save():
        await _updateGroup();

      case LeaveGroup():
        await _leaveGroup();

      case Refresh():
        // 그룹 ID 가져오기
        final group = state.group.valueOrNull;
        if (group != null) {
          await _loadGroupDetail(group.id);
        }

      case SelectImage():
        // Root에서 처리 (이미지 선택 다이얼로그 표시)
        break;
    }
  }

  Future<void> _updateGroup() async {
    // 현재 그룹 정보 가져오기
    final currentGroup = state.group.valueOrNull;
    if (currentGroup == null) {
      state = state.copyWith(errorMessage: '그룹 정보가 없습니다. 다시 시도해주세요.');
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    // 업데이트된 그룹 생성
    final updatedGroup = Group(
      id: currentGroup.id,
      name: state.name,
      description: state.description,
      members: currentGroup.members,
      hashTags: state.hashTags,
      limitMemberCount: state.limitMemberCount,
      owner: currentGroup.owner,
      imageUrl: state.imageUrl,
      createdAt: currentGroup.createdAt,
      updatedAt: DateTime.now(),
    );

    // 그룹 업데이트
    final result = await _updateGroupUseCase.execute(updatedGroup);

    // 결과 처리
    switch (result) {
      case AsyncData():
        // 그룹 정보 다시 로드
        await _loadGroupDetail(currentGroup.id);
        state = state.copyWith(
          isSubmitting: false,
          isEditing: false, // 편집 모드 종료
          successMessage: '그룹 정보가 성공적으로 업데이트되었습니다.',
        );
      case AsyncError(:final error):
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: '그룹 정보 업데이트 실패: $error',
        );
      case AsyncLoading():
        // 이미 처리됨
        break;
    }
  }

  Future<void> _leaveGroup() async {
    final currentGroup = state.group.valueOrNull;
    if (currentGroup == null) {
      state = state.copyWith(errorMessage: '그룹 정보가 없습니다. 다시 시도해주세요.');
      return;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    // 그룹 탈퇴
    final result = await _leaveGroupUseCase.execute(currentGroup.id);

    // 결과 처리
    switch (result) {
      case AsyncData():
        state = state.copyWith(
          isSubmitting: false,
          successMessage: '그룹에서 성공적으로 탈퇴했습니다.',
        );
      case AsyncError(:final error):
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: '그룹 탈퇴 실패: $error',
        );
      case AsyncLoading():
        // 이미 처리됨
        break;
    }
  }
}
