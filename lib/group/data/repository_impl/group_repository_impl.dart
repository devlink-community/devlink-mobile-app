import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:devlink_mobile_app/group/data/mapper/group_mapper.dart';
import 'package:devlink_mobile_app/group/domain/model/group.dart';
import 'package:devlink_mobile_app/group/domain/repository/group_repository.dart';

import '../data_source/group_data_source.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupDataSource _dataSource;

  GroupRepositoryImpl({required GroupDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<List<Group>>> getGroupList() async {
    try {
      final groupDtoList = await _dataSource.fetchGroupList();
      final groupList = groupDtoList.toModelList();
      return Result.success(groupList);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '그룹 목록을 불러오는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Group>> getGroupDetail(String groupId) async {
    try {
      final groupDto = await _dataSource.fetchGroupDetail(groupId);
      final group = groupDto.toModel();
      return Result.success(group);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '그룹 정보를 불러오는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> joinGroup(String groupId) async {
    try {
      await _dataSource.fetchJoinGroup(groupId);
      return const Result.success(null);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '그룹 참여에 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Group>> createGroup(Group group) async {
    try {
      final groupDto = group.toDto();
      final createdGroupDto = await _dataSource.fetchCreateGroup(groupDto);
      final createdGroup = createdGroupDto.toModel();
      return Result.success(createdGroup);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '그룹 생성에 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> updateGroup(Group group) async {
    try {
      final groupDto = group.toDto();
      await _dataSource.fetchUpdateGroup(groupDto);
      return const Result.success(null);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '그룹 수정에 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> leaveGroup(String groupId) async {
    try {
      await _dataSource.fetchLeaveGroup(groupId);
      return const Result.success(null);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '그룹 탈퇴에 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<Group>>> searchGroups(String query) async {
    try {
      // 먼저 모든 그룹 데이터를 가져옵니다
      final groupDtoList = await _dataSource.fetchGroupList();
      final allGroups = groupDtoList.toModelList();

      // 검색어를 소문자로 변환하여 대소문자 구분 없이 검색
      final queryLower = query.toLowerCase();

      // 이름, 설명, 해시태그에서 검색어 포함 여부 확인
      final filteredGroups =
          allGroups.where((group) {
            // 그룹 이름에서 검색
            if (group.name.toLowerCase().contains(queryLower)) {
              return true;
            }

            // 그룹 설명에서 검색 (description이 null이 아닌 경우에만)
            if (group.description.toLowerCase().contains(queryLower)) {
              return true;
            }

            // 해시태그에서 검색
            if (group.hashTags.any(
              (tag) => tag.content.toLowerCase().contains(queryLower),
            )) {
              return true;
            }

            return false;
          }).toList();

      return Result.success(filteredGroups);
    } catch (e) {
      return Result.error(
        Failure(FailureType.unknown, '그룹 검색 중 오류가 발생했습니다', cause: e),
      );
    }
  }
}
