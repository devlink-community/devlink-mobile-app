// lib/group/presentation/group_create/group_create_notifier.dart
import 'package:devlink_mobile_app/auth/domain/model/user.dart';
import 'package:devlink_mobile_app/community/domain/model/hash_tag.dart';
import 'package:devlink_mobile_app/core/auth/auth_provider.dart';
import 'package:devlink_mobile_app/group/data/data_source/group_data_source.dart';
import 'package:devlink_mobile_app/group/domain/model/group.dart';
import 'package:devlink_mobile_app/group/domain/usecase/create_group_use_case.dart';
import 'package:devlink_mobile_app/group/module/group_di.dart';
import 'package:devlink_mobile_app/group/presentation/group_create/group_create_action.dart';
import 'package:devlink_mobile_app/group/presentation/group_create/group_create_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_create_notifier.g.dart';

@riverpod
class GroupCreateNotifier extends _$GroupCreateNotifier {
  late final CreateGroupUseCase _createGroupUseCase;
  late final GroupDataSource _groupDataSource;

  @override
  GroupCreateState build() {
    _createGroupUseCase = ref.watch(createGroupUseCaseProvider);
    _groupDataSource = ref.watch(groupDataSourceProvider);
    return const GroupCreateState();
  }

  Future<void> onAction(GroupCreateAction action) async {
    switch (action) {
      case NameChanged(:final name):
        state = state.copyWith(name: name);

      case DescriptionChanged(:final description):
        state = state.copyWith(description: description);

      case LimitMemberCountChanged(:final count):
        final validCount = count < 1 ? 1 : count;
        state = state.copyWith(limitMemberCount: validCount);

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

      case ImageUrlChanged(:final imageUrl):
        state = state.copyWith(imageUrl: imageUrl);

      // 🆕 추가: 일시정지 제한시간 변경 액션
      case PauseTimeLimitChanged(:final minutes):
        final validMinutes =
            minutes < 30 ? 30 : (minutes > 480 ? 480 : minutes); // 30분~8시간
        state = state.copyWith(pauseTimeLimit: validMinutes);

      case MemberInvited(userId: final memberUserId):
        // 실제 구현에서는 멤버 조회 API 호출 등이 필요
        final mockMember = User(
          id: memberUserId,
          email: 'user$memberUserId@example.com',
          nickname: 'User $memberUserId',
          uid: 'uid_$memberUserId',
        );
        if (!state.invitedMembers.any((m) => m.id == memberUserId)) {
          state = state.copyWith(
            invitedMembers: [...state.invitedMembers, mockMember],
          );
        }

      case MemberRemoved(:final userId):
        state = state.copyWith(
          invitedMembers:
              state.invitedMembers.where((m) => m.id != userId).toList(),
        );

      case Submit():
        await _submit();

      case Cancel():
        // Root에서 처리
        break;

      case SelectImage():
        // Root에서 처리
        break;

      // 🆕 추가: 새로운 액션들 처리
      case ClearError():
        clearError();

      case ClearSuccess():
        clearSuccess();

      case ResetForm():
        resetForm();

      case ValidateForm():
        _validateForm();
    }
  }

  Future<void> _submit() async {
    // 🔧 수정: 입력 검증 강화
    if (state.name.trim().isEmpty) {
      state = state.copyWith(errorMessage: '그룹 이름을 입력하세요');
      return;
    }

    if (state.name.trim().length < 2) {
      state = state.copyWith(errorMessage: '그룹 이름은 2자 이상이어야 합니다');
      return;
    }

    if (state.name.trim().length > 50) {
      state = state.copyWith(errorMessage: '그룹 이름은 50자 이하여야 합니다');
      return;
    }

    if (state.description.trim().isEmpty) {
      state = state.copyWith(errorMessage: '그룹 설명을 입력하세요');
      return;
    }

    if (state.description.trim().length < 10) {
      state = state.copyWith(errorMessage: '그룹 설명은 10자 이상이어야 합니다');
      return;
    }

    if (state.description.trim().length > 500) {
      state = state.copyWith(errorMessage: '그룹 설명은 500자 이하여야 합니다');
      return;
    }

    if (state.limitMemberCount < 2) {
      state = state.copyWith(errorMessage: '최소 멤버 수는 2명 이상이어야 합니다');
      return;
    }

    if (state.limitMemberCount > 100) {
      state = state.copyWith(errorMessage: '최대 멤버 수는 100명 이하여야 합니다');
      return;
    }

    // 🆕 추가: 일시정지 제한시간 검증
    if (state.pauseTimeLimit < 30) {
      state = state.copyWith(errorMessage: '일시정지 제한시간은 최소 30분이어야 합니다');
      return;
    }

    if (state.pauseTimeLimit > 480) {
      state = state.copyWith(errorMessage: '일시정지 제한시간은 최대 8시간이어야 합니다');
      return;
    }

    // 해시태그 검증
    if (state.hashTags.length > 10) {
      state = state.copyWith(errorMessage: '해시태그는 최대 10개까지만 추가할 수 있습니다');
      return;
    }

    // 중복 해시태그 검증
    final hashTagContents =
        state.hashTags.map((tag) => tag.content.toLowerCase()).toSet();
    if (hashTagContents.length != state.hashTags.length) {
      state = state.copyWith(errorMessage: '중복된 해시태그가 있습니다');
      return;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      // 현재 로그인한 사용자 정보 가져오기
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: '로그인 정보를 찾을 수 없습니다',
        );
        return;
      }

      // 🔧 수정: 이미지 업로드 처리
      String? finalImageUrl = state.imageUrl;

      // 로컬 이미지인 경우 Firebase Storage에 업로드
      if (finalImageUrl != null && finalImageUrl.startsWith('file://')) {
        try {
          // 임시 그룹 ID 생성 (실제로는 그룹 생성 후 업데이트하는 방식으로 변경될 수 있음)
          final tempGroupId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
          final localImagePath = finalImageUrl.replaceFirst('file://', '');

          // Firebase Storage에 업로드
          finalImageUrl = await _groupDataSource.updateGroupImage(
            tempGroupId,
            localImagePath,
          );
        } catch (e) {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: '이미지 업로드에 실패했습니다. 다시 시도해주세요.',
          );
          return;
        }
      }

      // 🔧 수정: 새로운 Group 모델 구조에 맞게 생성
      final group = Group(
        id: 'temp_id', // 서버에서 생성될 ID
        name: state.name.trim(),
        description: state.description.trim(),
        ownerId: currentUser.id, // owner 객체 대신 ownerId 문자열 사용
        ownerNickname: currentUser.nickname, // 방장 닉네임 추가
        ownerProfileImage: currentUser.image, // 방장 프로필 이미지 추가
        hashTags:
            state.hashTags
                .map((tag) => tag.content)
                .toList(), // HashTag 객체 리스트 → 문자열 리스트로 변환
        maxMemberCount: state.limitMemberCount,
        imageUrl: finalImageUrl, // 업로드된 이미지 URL 또는 null
        createdAt: DateTime.now(),
        memberCount: 1 + state.invitedMembers.length, // 방장 + 초대된 멤버 수
        isJoinedByCurrentUser: true, // 생성자는 자동으로 그룹에 가입됨
        pauseTimeLimit: state.pauseTimeLimit, // 🆕 추가: 일시정지 제한시간
      );

      // UseCase 호출하여 그룹 생성
      final result = await _createGroupUseCase.execute(group);

      // 결과 처리
      switch (result) {
        case AsyncData(:final value):
          state = state.copyWith(
            isSubmitting: false,
            createdGroupId: value.id,
            successMessage: '그룹이 성공적으로 생성되었습니다!',
          );
        case AsyncError(:final error):
          // 🔧 수정: 에러 메시지 개선
          String errorMessage = '그룹 생성에 실패했습니다';

          if (error.toString().contains('이미 사용 중인 그룹 이름')) {
            errorMessage = '이미 사용 중인 그룹 이름입니다. 다른 이름을 선택해주세요';
          } else if (error.toString().contains('네트워크')) {
            errorMessage = '네트워크 연결을 확인하고 다시 시도해주세요';
          } else if (error.toString().contains('권한')) {
            errorMessage = '그룹 생성 권한이 없습니다. 로그인 상태를 확인해주세요';
          } else if (error.toString().contains('서버')) {
            errorMessage = '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요';
          }

          state = state.copyWith(
            isSubmitting: false,
            errorMessage: errorMessage,
          );
        case AsyncLoading():
          // 로딩 상태는 이미 isSubmitting으로 처리됨
          break;
      }
    } catch (e) {
      // 🔧 수정: 예외 처리 개선
      String errorMessage = '그룹 생성 중 알 수 없는 오류가 발생했습니다';

      if (e.toString().contains('FormatException')) {
        errorMessage = '입력 데이터 형식이 올바르지 않습니다';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = '요청 시간이 초과되었습니다. 다시 시도해주세요';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '인터넷 연결을 확인하고 다시 시도해주세요';
      }

      state = state.copyWith(
        isSubmitting: false,
        errorMessage: errorMessage,
      );
    }
  }

  // 🆕 추가: 유틸리티 메서드들

  /// 해시태그 유효성 검사
  bool isValidHashTag(String tag) {
    final trimmed = tag.trim();

    // 빈 문자열 체크
    if (trimmed.isEmpty) return false;

    // 길이 체크 (1-20자)
    if (trimmed.length > 20) return false;

    // 중복 체크
    if (state.hashTags.any((existingTag) => existingTag.content == trimmed)) {
      return false;
    }

    // 특수문자 제한 (한글, 영문, 숫자만 허용)
    if (!RegExp(r'^[가-힣a-zA-Z0-9\s]+$').hasMatch(trimmed)) {
      return false;
    }

    return true;
  }

  /// 그룹 이름 실시간 유효성 검사
  String? validateGroupName(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return '그룹 이름을 입력하세요';
    }

    if (trimmed.length < 2) {
      return '그룹 이름은 2자 이상이어야 합니다';
    }

    if (trimmed.length > 50) {
      return '그룹 이름은 50자 이하여야 합니다';
    }

    // 특수문자 제한
    if (!RegExp(r'^[가-힣a-zA-Z0-9\s\-_.]+$').hasMatch(trimmed)) {
      return '그룹 이름에는 특수문자를 사용할 수 없습니다';
    }

    return null;
  }

  /// 그룹 설명 실시간 유효성 검사
  String? validateGroupDescription(String description) {
    final trimmed = description.trim();

    if (trimmed.isEmpty) {
      return '그룹 설명을 입력하세요';
    }

    if (trimmed.length < 10) {
      return '그룹 설명은 10자 이상이어야 합니다';
    }

    if (trimmed.length > 500) {
      return '그룹 설명은 500자 이하여야 합니다';
    }

    return null;
  }

  /// 멤버 수 제한 유효성 검사
  String? validateMemberLimit(int count) {
    if (count < 2) {
      return '최소 멤버 수는 2명 이상이어야 합니다';
    }

    if (count > 100) {
      return '최대 멤버 수는 100명 이하여야 합니다';
    }

    return null;
  }

  /// 일시정지 제한시간 유효성 검사
  String? validatePauseTimeLimit(int minutes) {
    if (minutes < 30) {
      return '일시정지 제한시간은 최소 30분이어야 합니다';
    }

    if (minutes > 480) {
      return '일시정지 제한시간은 최대 8시간(480분)이어야 합니다';
    }

    return null;
  }

  /// 폼 전체 유효성 검사
  bool get isFormValid {
    return validateGroupName(state.name) == null &&
        validateGroupDescription(state.description) == null &&
        validateMemberLimit(state.limitMemberCount) == null &&
        validatePauseTimeLimit(state.pauseTimeLimit) == null &&
        state.hashTags.length <= 10;
  }

  /// 에러 메시지 초기화
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// 성공 메시지 초기화
  void clearSuccess() {
    if (state.successMessage != null) {
      state = state.copyWith(successMessage: null);
    }
  }

  /// 폼 초기화
  void resetForm() {
    state = const GroupCreateState();
  }

  /// 실시간 폼 유효성 검사
  void _validateForm() {
    final nameError = validateGroupName(state.name);
    final descriptionError = validateGroupDescription(state.description);
    final memberLimitError = validateMemberLimit(state.limitMemberCount);
    final pauseTimeLimitError = validatePauseTimeLimit(state.pauseTimeLimit);

    state = state.copyWith(
      nameError: nameError,
      descriptionError: descriptionError,
      memberLimitError: memberLimitError,
      pauseTimeLimitError: pauseTimeLimitError,
      showValidationErrors: true,
    );
  }

  /// 필드별 실시간 유효성 검사 (UI에서 호출)
  void validateField(String fieldName, dynamic value) {
    switch (fieldName) {
      case 'name':
        final error = validateGroupName(value as String);
        state = state.copyWith(nameError: error);
        break;
      case 'description':
        final error = validateGroupDescription(value as String);
        state = state.copyWith(descriptionError: error);
        break;
      case 'memberLimit':
        final error = validateMemberLimit(value as int);
        state = state.copyWith(memberLimitError: error);
        break;
      case 'pauseTimeLimit':
        final error = validatePauseTimeLimit(value as int);
        state = state.copyWith(pauseTimeLimitError: error);
        break;
    }
  }
}
