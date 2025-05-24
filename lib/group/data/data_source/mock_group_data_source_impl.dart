// lib/group/data/data_source/mock_group_data_source_impl.dart
import 'dart:async';
import 'dart:math';

import 'package:devlink_mobile_app/core/utils/messages/group_error_messages.dart';
import 'package:intl/intl.dart';

import 'group_data_source.dart';

class MockGroupDataSourceImpl implements GroupDataSource {
  final Random _random = Random();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  // 메모리에 그룹 데이터 저장 (실제 DB 역할)
  final List<Map<String, dynamic>> _groups = [];

  // 멤버십 데이터 저장 (groupId -> List<Map>)
  final Map<String, List<Map<String, dynamic>>> _memberships = {};

  // 사용자별 그룹 가입 정보 (userId -> List<String>)
  final Map<String, List<String>> _userGroups = {};

  // 타이머 활동과 출석부를 위한 맵 추가
  final Map<String, List<Map<String, dynamic>>> _timerActivities = {};

  // 🔧 실시간 스트림 컨트롤러 추가
  final Map<String, StreamController<List<Map<String, dynamic>>>>
  _timerStatusControllers = {};

  bool _initialized = false;

  // 현재 사용자 ID (Mock 환경에서는 고정값 사용)
  static const String _currentUserId = 'user1';

  // 현재 사용자 정보 가져오기 헬퍼 메서드
  Map<String, String> _getCurrentUserInfo() {
    return {
      'userId': _currentUserId,
      'userName': '사용자1',
      'profileUrl':
          'https://i.pinimg.com/236x/31/fd/53/31fd53b6dc87e714783b5c52531ba6fb.jpg',
    };
  }

  // 현재 사용자의 가입 그룹 ID 목록 가져오기
  Set<String> _getCurrentUserJoinedGroupIds() {
    final userGroupIds = _userGroups[_currentUserId] ?? [];
    return userGroupIds.toSet();
  }

  // DiceBear API 기반 이미지 URL 생성 함수
  String _generateDiceBearUrl() {
    // 개발/코딩/기술 테마에 적합한 스타일 선택
    final styles = [
      'bottts', // 로봇형 아바타
      'pixel-art', // 픽셀 아트 스타일
      'identicon', // GitHub 스타일 아이덴티콘
      'shapes', // 기하학적 모양
      'initials', // 이니셜 기반 (그룹 이름의 첫 글자)
    ];
    final style = styles[_random.nextInt(styles.length)];

    // 랜덤 시드 값 생성 (그룹마다 다른 이미지가 나오도록)
    final seed =
        DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(10000).toString();

    // DiceBear API URL 생성
    return 'https://api.dicebear.com/7.x/$style/png?seed=$seed&size=200';
  }

  // 기본 사용자 데이터 생성 헬퍼
  Map<String, dynamic> _createMockMember(
    String id,
    String nickname, {
    bool onAir = false,
    String role = 'member',
  }) {
    final profileImages = [
      'https://randomuser.me/api/portraits/men/1.jpg',
      'https://randomuser.me/api/portraits/women/2.jpg',
      'https://randomuser.me/api/portraits/men/3.jpg',
      'https://randomuser.me/api/portraits/women/4.jpg',
      'https://randomuser.me/api/portraits/men/5.jpg',
      'https://randomuser.me/api/portraits/women/6.jpg',
      'https://randomuser.me/api/portraits/men/7.jpg',
    ];

    final imageIndex = id.hashCode % profileImages.length;

    return {
      'id': id,
      'userId': id,
      'userName': nickname,
      'profileUrl': profileImages[imageIndex],
      'role': role,
      'joinedAt': _dateFormat.format(
        DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ),
    };
  }

  // 🔧 멤버별 최신 타이머 활동 조회 (내부 메소드)
  List<Map<String, dynamic>> _getLatestTimerActivitiesByMember(String groupId) {
    _timerActivities[groupId] ??= [];
    final activities = _timerActivities[groupId]!;

    if (activities.isEmpty) {
      return [];
    }

    // 멤버별로 가장 최근 활동만 필터링
    final Map<String, Map<String, dynamic>> userIdToActivity = {};

    // 활동을 시간순으로 정렬 (최신순)
    activities.sort((a, b) {
      final timestampA = a['timestamp'] as String?;
      final timestampB = b['timestamp'] as String?;

      if (timestampA == null || timestampB == null) return 0;

      try {
        final dateA = _dateFormat.parse(timestampA);
        final dateB = _dateFormat.parse(timestampB);
        return dateB.compareTo(dateA); // 내림차순 (최신순)
      } catch (e) {
        return 0;
      }
    });

    // 각 멤버의 최신 활동만 수집
    for (final activity in activities) {
      final userId = activity['userId'] as String?;

      if (userId != null && !userIdToActivity.containsKey(userId)) {
        userIdToActivity[userId] = Map<String, dynamic>.from(activity);
      }
    }

    return userIdToActivity.values.toList();
  }

  // 🔧 스트림 컨트롤러 가져오기 또는 생성
  StreamController<List<Map<String, dynamic>>> _getTimerStatusController(
    String groupId,
  ) {
    if (!_timerStatusControllers.containsKey(groupId) ||
        _timerStatusControllers[groupId]!.isClosed) {
      _timerStatusControllers[groupId] =
          StreamController<List<Map<String, dynamic>>>.broadcast();
    }
    return _timerStatusControllers[groupId]!;
  }

  // 🔧 스트림으로 데이터 전송
  void _notifyTimerStatusChange(String groupId) {
    if (_timerStatusControllers.containsKey(groupId) &&
        !_timerStatusControllers[groupId]!.isClosed) {
      final latestActivities = _getLatestTimerActivitiesByMember(groupId);
      _timerStatusControllers[groupId]!.add(latestActivities);
    }
  }

  // Mock 데이터 초기화
  Future<void> _initializeIfNeeded() async {
    if (_initialized) return;

    // 기본 사용자 목록 생성
    final mockUsers = [
      _createMockMember('user1', '사용자1', onAir: false),
      _createMockMember('user2', '사용자2', onAir: true),
      _createMockMember('user3', '사용자3', onAir: false),
      _createMockMember('user4', '사용자4', onAir: true),
      _createMockMember('user5', '사용자5', onAir: false),
      _createMockMember('user6', '관리자', onAir: true),
      _createMockMember('user7', '개발자', onAir: true),
    ];

    // 초기 15개 그룹 생성 및 저장
    for (int i = 0; i < 15; i++) {
      // 랜덤 멤버 수 (소유자 포함)
      final memberCount = _random.nextInt(5) + 1; // 1~5명의 멤버
      final maxMemberCount =
          memberCount + _random.nextInt(5) + 2; // 현재 멤버 수 + 2~6명 여유

      // 임의의 생성일과 수정일 생성
      final now = DateTime.now();
      final createdDate = now.subtract(
        Duration(days: _random.nextInt(90)),
      ); // 최대 90일 전
      final updatedDate = createdDate.add(
        Duration(days: _random.nextInt(30)),
      ); // 생성일 이후 최대 30일 후

      // 그룹 소유자 - 기본 사용자 중 하나를 선택
      final ownerIndex = i % mockUsers.length;
      final owner = {...mockUsers[ownerIndex]};
      owner['role'] = 'owner'; // 소유자 역할 설정

      // 해시태그 생성
      final hashTags = ['주제${i % 5 + 1}', '그룹$i'];

      // 그룹 주제에 따라 추가 태그
      if (i % 3 == 0) {
        hashTags.add('스터디');
      } else if (i % 3 == 1) {
        hashTags.add('프로젝트');
      } else {
        hashTags.add('취미');
      }

      // 그룹명 생성 - 일관성 있게
      String groupName;
      if (i % 3 == 0) {
        groupName = '${owner['userName']}의 스터디 그룹';
      } else if (i % 3 == 1) {
        groupName = '${owner['userName']}의 프로젝트';
      } else {
        groupName = '${owner['userName']}의 모임';
      }

      // DiceBear API로 그룹 이미지 URL 생성
      final imageUrl = _generateDiceBearUrl();

      // 그룹 ID 생성
      final groupId = 'group_$i';

      // 그룹 데이터 생성
      final groupData = {
        'id': groupId,
        'name': groupName,
        'description':
            '${owner['userName']}님이 만든 ${hashTags.join(', ')} 그룹입니다. 현재 $memberCount명이 활동 중입니다!',
        'imageUrl': imageUrl,
        'createdAt': _dateFormat.format(createdDate),
        'updatedAt': _dateFormat.format(updatedDate),
        'createdBy': owner['userId'],
        'maxMemberCount': maxMemberCount,
        'hashTags': hashTags,
        'memberCount': memberCount,
      };

      // 그룹에 멤버 추가
      final members = <Map<String, dynamic>>[
        {...owner},
      ];

      // 소유자를 제외한 추가 멤버 선택
      final availableUsers = List<Map<String, dynamic>>.from(mockUsers);
      availableUsers.removeWhere(
        (user) => user['userId'] == owner['userId'],
      ); // 소유자 제외

      // 랜덤하게 추가 멤버 선택
      availableUsers.shuffle(_random);
      for (int j = 0; j < min(memberCount - 1, availableUsers.length); j++) {
        members.add({...availableUsers[j]});
      }

      // 그룹 및 멤버십 정보 저장
      _groups.add(groupData);
      _memberships[groupId] = members;

      // 사용자별 가입 그룹 정보 업데이트
      for (final member in members) {
        final userId = member['userId'] as String;
        _userGroups[userId] ??= [];
        _userGroups[userId]!.add(groupId);
      }

      // 🔧 각 멤버에 대해 기본 타이머 활동 생성
      _timerActivities[groupId] = [];
      for (final member in members) {
        final userId = member['userId'] as String?;
        final userName = member['userName'] as String?;

        if (userId != null && userName != null) {
          // 기본 활동 추가 (end 타입)
          _timerActivities[groupId]!.add({
            'id': 'activity_${userId}_${DateTime.now().millisecondsSinceEpoch}',
            'userId': userId,
            'userName': userName,
            'type': 'end',
            'timestamp': _dateFormat.format(
              DateTime.now().subtract(const Duration(hours: 1)),
            ),
            'groupId': groupId,
          });
        }
      }
    }

    _initialized = true;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchGroupList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _initializeIfNeeded();

    // 현재 사용자의 가입 그룹 ID 목록 가져오기
    final joinedGroupIds = _getCurrentUserJoinedGroupIds();

    // 그룹 리스트의 깊은 복사본 생성
    final groupsCopy =
        _groups.map((group) => Map<String, dynamic>.from(group)).toList();

    // 가입 그룹 정보로 멤버십 상태 설정
    for (final group in groupsCopy) {
      group['isJoinedByCurrentUser'] = joinedGroupIds.contains(group['id']);
    }

    return groupsCopy;
  }

  @override
  Future<Map<String, dynamic>> fetchGroupDetail(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    await _initializeIfNeeded();

    // 해당 ID의 그룹 찾기
    final groupIndex = _groups.indexWhere((group) => group['id'] == groupId);
    if (groupIndex == -1) {
      throw Exception('그룹을 찾을 수 없습니다: $groupId');
    }

    // 그룹 데이터 복사
    final groupData = Map<String, dynamic>.from(_groups[groupIndex]);

    // 현재 사용자의 가입 여부 확인
    final joinedGroupIds = _getCurrentUserJoinedGroupIds();
    groupData['isJoinedByCurrentUser'] = joinedGroupIds.contains(groupId);

    return groupData;
  }

  @override
  Future<void> fetchJoinGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _initializeIfNeeded();

    // 현재 사용자 정보 가져오기
    final userInfo = _getCurrentUserInfo();
    final userId = userInfo['userId']!;
    final userName = userInfo['userName']!;
    final profileUrl = userInfo['profileUrl']!;

    // 그룹 존재 확인
    final groupIndex = _groups.indexWhere((g) => g['id'] == groupId);
    if (groupIndex == -1) {
      throw Exception('참여할 그룹을 찾을 수 없습니다: $groupId');
    }

    // 이미 가입되어 있는지 확인
    final userGroupIds = _userGroups[userId] ?? [];
    if (userGroupIds.contains(groupId)) {
      throw Exception('이미 가입한 그룹입니다');
    }

    // 그룹 멤버 수 확인
    final group = _groups[groupIndex];
    final memberCount = group['memberCount'] as int;
    final maxMemberCount = group['maxMemberCount'] as int;

    if (memberCount >= maxMemberCount) {
      throw Exception('그룹 최대 인원에 도달했습니다');
    }

    // 랜덤으로 실패 케이스 발생 (10% 확률)
    if (_random.nextInt(10) == 0) {
      throw Exception('그룹 참여 중 오류가 발생했습니다');
    }

    // 그룹에 멤버 추가
    final newMember = {
      'id': userId,
      'userId': userId,
      'userName': userName,
      'profileUrl': profileUrl,
      'role': 'member',
      'joinedAt': _dateFormat.format(DateTime.now()),
    };

    _memberships[groupId] ??= [];
    _memberships[groupId]!.add(newMember);

    // 그룹 멤버 수 증가
    _groups[groupIndex]['memberCount'] = memberCount + 1;

    // 사용자의 가입 그룹 목록에 추가
    _userGroups[userId] ??= [];
    _userGroups[userId]!.add(groupId);
  }

  @override
  Future<Map<String, dynamic>> fetchCreateGroup(
    Map<String, dynamic> groupData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await _initializeIfNeeded();

    // 현재 사용자 정보 가져오기
    final userInfo = _getCurrentUserInfo();
    final ownerId = userInfo['userId']!;
    final ownerNickname = userInfo['userName']!;
    final ownerProfileUrl = userInfo['profileUrl']!;

    // 새 그룹 ID 생성
    final newGroupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    // 입력받은 데이터에 필수 필드 추가
    final newGroupData = {
      ...groupData,
      'id': newGroupId,
      'createdAt': _dateFormat.format(now),
      'updatedAt': _dateFormat.format(now),
      'ownerId': ownerId,
      'ownerNickname': ownerNickname,
      'ownerProfileImage': ownerProfileUrl,
      'memberCount': 1, // 처음에는 생성자만 멤버
    };

    // 이미지 URL이 없으면 기본 이미지 생성
    if (newGroupData['imageUrl'] == null ||
        (newGroupData['imageUrl'] as String).isEmpty) {
      newGroupData['imageUrl'] = _generateDiceBearUrl();
    }

    // 소유자(방장) 정보 생성
    final ownerData = {
      'id': ownerId,
      'userId': ownerId,
      'userName': ownerNickname,
      'profileUrl': ownerProfileUrl,
      'role': 'owner',
      'joinedAt': _dateFormat.format(now),
    };

    // 그룹 및 멤버십 정보 저장
    _groups.add(newGroupData);
    _memberships[newGroupId] = [ownerData];

    // 사용자의 가입 그룹 목록에 추가
    _userGroups[ownerId] ??= [];
    _userGroups[ownerId]!.add(newGroupId);

    return newGroupData;
  }

  @override
  Future<void> fetchUpdateGroup(
    String groupId,
    Map<String, dynamic> updateData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _initializeIfNeeded();

    // 업데이트 실패 케이스 (5% 확률)
    if (_random.nextInt(20) == 0) {
      throw Exception('그룹 정보 업데이트 중 오류가 발생했습니다');
    }

    // 그룹 찾기
    final groupIndex = _groups.indexWhere((g) => g['id'] == groupId);
    if (groupIndex == -1) {
      throw Exception('업데이트할 그룹을 찾을 수 없습니다: $groupId');
    }

    // 그룹 정보 업데이트
    final group = _groups[groupIndex];

    // 업데이트 데이터 적용
    updateData.forEach((key, value) {
      // id와 createdBy는 변경 불가
      if (key != 'id' && key != 'createdBy' && key != 'memberCount') {
        group[key] = value;
      }
    });

    // updatedAt 필드 업데이트
    group['updatedAt'] = _dateFormat.format(DateTime.now());
  }

  @override
  Future<void> fetchLeaveGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    await _initializeIfNeeded();

    final userId = _currentUserId;

    // 그룹 존재 확인
    final groupIndex = _groups.indexWhere((g) => g['id'] == groupId);
    if (groupIndex == -1) {
      throw Exception('탈퇴할 그룹을 찾을 수 없습니다: $groupId');
    }

    // 멤버십 확인
    final members = _memberships[groupId] ?? [];
    final memberIndex = members.indexWhere((m) => m['userId'] == userId);

    if (memberIndex == -1) {
      throw Exception('해당 그룹의 멤버가 아닙니다');
    }

    // 소유자(방장)인지 확인
    final member = members[memberIndex];
    if (member['role'] == 'owner') {
      throw Exception('그룹 소유자는 탈퇴할 수 없습니다. 그룹을 삭제하거나 소유권을 이전하세요.');
    }

    // 탈퇴 실패 케이스 (5% 확률)
    if (_random.nextInt(20) == 0) {
      throw Exception('그룹 탈퇴 중 오류가 발생했습니다');
    }

    // 멤버 제거
    members.removeAt(memberIndex);

    // 그룹 멤버 수 감소
    _groups[groupIndex]['memberCount'] =
        (_groups[groupIndex]['memberCount'] as int) - 1;

    // 사용자의 가입 그룹 목록에서 제거
    final userGroupIds = _userGroups[userId] ?? [];
    userGroupIds.remove(groupId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchGroupMembers(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _initializeIfNeeded();

    // 그룹 존재 확인
    final groupIndex = _groups.indexWhere((g) => g['id'] == groupId);
    if (groupIndex == -1) {
      throw Exception('그룹을 찾을 수 없습니다: $groupId');
    }

    // 그룹 멤버 목록 복사
    final members = _memberships[groupId] ?? [];
    return members.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  Future<String> updateGroupImage(String groupId, String localImagePath) async {
    await Future.delayed(const Duration(milliseconds: 700));
    await _initializeIfNeeded();

    // 그룹 존재 확인
    final groupIndex = _groups.indexWhere((g) => g['id'] == groupId);
    if (groupIndex == -1) {
      throw Exception('그룹을 찾을 수 없습니다: $groupId');
    }

    // 실제로는 이미지 업로드 작업이 필요하지만, Mock에서는 경로를 URL로 간주
    final newImageUrl =
        localImagePath.startsWith('http')
            ? localImagePath
            : _generateDiceBearUrl(); // 로컬 경로인 경우 새 이미지 생성

    // 그룹 이미지 업데이트
    _groups[groupIndex]['imageUrl'] = newImageUrl;

    return newImageUrl;
  }

  @override
  Future<List<Map<String, dynamic>>> searchGroups(
    String query, {
    bool searchKeywords = true,
    bool searchTags = true,
    int? limit,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _initializeIfNeeded();

    if (query.isEmpty) {
      return [];
    }

    // 현재 사용자의 가입 그룹 ID 목록 가져오기
    final joinedGroupIds = _getCurrentUserJoinedGroupIds();

    final lowercaseQuery = query.toLowerCase();
    final Set<Map<String, dynamic>> resultSet = {};

    // 키워드 검색 (이름, 설명)
    if (searchKeywords) {
      final keywordResults = _groups.where((group) {
        final name = (group['name'] as String).toLowerCase();
        final description = (group['description'] as String).toLowerCase();
        return name.contains(lowercaseQuery) ||
            description.contains(lowercaseQuery);
      });

      resultSet.addAll(keywordResults);
    }

    // 태그 검색
    if (searchTags) {
      final tagResults = _groups.where((group) {
        final tags = (group['hashTags'] as List<dynamic>).cast<String>();
        return tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      });

      resultSet.addAll(tagResults);
    }

    // 결과를 리스트로 변환
    final results = resultSet.map((g) => Map<String, dynamic>.from(g)).toList();

    // 가입 그룹 정보를 이용하여 isJoinedByCurrentUser 설정
    for (final group in results) {
      final groupId = group['id'] as String;
      group['isJoinedByCurrentUser'] = joinedGroupIds.contains(groupId);
    }

    // 정렬 적용
    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          results.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String),
          );
          break;
        case 'createdAt':
          results.sort((a, b) {
            try {
              final dateA = _dateFormat.parse(a['createdAt'] as String);
              final dateB = _dateFormat.parse(b['createdAt'] as String);
              return dateB.compareTo(dateA); // 최신순
            } catch (e) {
              return 0;
            }
          });
          break;
        case 'memberCount':
          results.sort(
            (a, b) =>
                (b['memberCount'] as int).compareTo(a['memberCount'] as int),
          );
          break;
      }
    } else {
      // 기본 정렬: 이름순
      results.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );
    }

    // 결과 개수 제한
    if (limit != null && limit > 0 && results.length > limit) {
      return results.sublist(0, limit);
    }

    return results;
  }

  // 🔧 기존 fetchGroupTimerActivities를 private으로 변경하고 최적화
  @override
  Future<List<Map<String, dynamic>>> fetchGroupTimerActivities(
    String groupId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _initializeIfNeeded();

    // 그룹 존재 확인
    final groupIndex = _groups.indexWhere((g) => g['id'] == groupId);
    if (groupIndex == -1) {
      throw Exception('그룹을 찾을 수 없습니다: $groupId');
    }

    return _getLatestTimerActivitiesByMember(groupId);
  }

  // 🔧 새로운 실시간 스트림 메소드
  @override
  Stream<List<Map<String, dynamic>>> streamGroupMemberTimerStatus(
    String groupId,
  ) {
    // 그룹 초기화
    _initializeIfNeeded().then((_) {
      // 초기화 완료 후 첫 데이터 전송
      final controller = _getTimerStatusController(groupId);
      if (!controller.isClosed) {
        final latestActivities = _getLatestTimerActivitiesByMember(groupId);
        controller.add(latestActivities);
      }
    });

    return _getTimerStatusController(groupId).stream;
  }

  @override
  Future<Map<String, dynamic>> startMemberTimer(String groupId) async {
    // 일관된 방식으로 recordTimerActivityWithTimestamp 메서드 호출
    return recordTimerActivityWithTimestamp(groupId, 'start', DateTime.now());
  }

  @override
  Future<Map<String, dynamic>> pauseMemberTimer(String groupId) async {
    // 일관된 방식으로 recordTimerActivityWithTimestamp 메서드 호출
    return recordTimerActivityWithTimestamp(groupId, 'pause', DateTime.now());
  }

  @override
  Future<Map<String, dynamic>> stopMemberTimer(String groupId) async {
    // 일관된 방식으로 recordTimerActivityWithTimestamp 메서드 호출
    return recordTimerActivityWithTimestamp(groupId, 'end', DateTime.now());
  }

  @override
  Future<Map<String, dynamic>> resumeMemberTimer(String groupId) async {
    // 일관된 방식으로 recordTimerActivityWithTimestamp 메서드 호출
    return recordTimerActivityWithTimestamp(groupId, 'resume', DateTime.now());
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMonthlyAttendances(
    String groupId,
    int year,
    int month, {
    int preloadMonths = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _initializeIfNeeded();

    // 그룹 존재 확인
    final groupIndex = _groups.indexWhere((g) => g['id'] == groupId);
    if (groupIndex == -1) {
      throw Exception('그룹을 찾을 수 없습니다');
    }

    // 타이머 활동 컬렉션 초기화 (없으면)
    _timerActivities[groupId] ??= [];

    // 이전 개월 수를 고려한 시작일 계산
    final startMonth = DateTime(year, month - preloadMonths, 1);
    final endDate = DateTime(year, month + 1, 1);

    // 해당 기간에 속하는 타이머 활동 필터링
    return _timerActivities[groupId]!
        .where((activity) {
          try {
            // 활동의 timestamp가 문자열 형태일 경우 DateTime으로 변환
            final timestamp = activity['timestamp'] as String?;
            if (timestamp == null) return false;

            final activityDate = _dateFormat.parse(timestamp);

            // 확장된 기간 범위 내에 있는지 확인
            return activityDate.isAfter(
                  startMonth.subtract(const Duration(seconds: 1)),
                ) &&
                activityDate.isBefore(endDate);
          } catch (e) {
            // 날짜 파싱 오류 시 제외
            return false;
          }
        })
        .map((activity) => Map<String, dynamic>.from(activity))
        .toList();
  }

  // lib/group/data/data_source/mock_group_data_source_impl.dart 끝부분에 추가

  // ===== 타임스탬프 지정 가능한 메서드들 추가 =====

  @override
  Future<Map<String, dynamic>> recordTimerActivityWithTimestamp(
    String groupId,
    String activityType,
    DateTime timestamp,
  ) async {
    // 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 그룹 존재 확인
    if (!_groups.containsKey(groupId)) {
      throw Exception(GroupErrorMessages.notFound);
    }

    // 현재 활동 상태 찾기
    final activityData = _findMemberActivity(groupId, _mockUserId);
    final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);

    // 활동 타입에 따라 처리
    switch (activityType) {
      case 'start':
        // 이미 실행 중인 타이머 확인
        if (activityData!['state'] == 'running' ||
            activityData['state'] == 'resume') {
          throw Exception(GroupErrorMessages.timerAlreadyRunning);
        }

        // 새 타이머 시작
        activityData['state'] = 'running';
        activityData['startAt'] = timestamp;
        activityData['lastUpdatedAt'] = timestamp;
        activityData['elapsed'] = 0;

        // monthlyDurations 초기화 (없는 경우)
        if (!activityData.containsKey('monthlyDurations')) {
          activityData['monthlyDurations'] = {};
        }

        // 해당 날짜에 대한 초기값 설정 (없는 경우)
        final monthlyDurations =
            activityData['monthlyDurations'] as Map<dynamic, dynamic>;
        if (!monthlyDurations.containsKey(dateKey)) {
          monthlyDurations[dateKey] = 0;
        }
        break;

      case 'pause':
        // 타이머 실행 중인지 확인
        if (activityData!['state'] != 'running' &&
            activityData['state'] != 'resume') {
          throw Exception(GroupErrorMessages.timerNotRunning);
        }

        // 시작 시간
        final startAt = activityData['startAt'] as DateTime?;
        if (startAt == null) {
          throw Exception(GroupErrorMessages.invalidTimerState);
        }

        // 현재 세션 경과 시간 계산
        final sessionDuration = timestamp.difference(startAt).inSeconds;
        final previousElapsed = activityData['elapsed'] as int? ?? 0;
        final totalElapsed = previousElapsed + sessionDuration;

        // 오늘 누적 시간 업데이트
        final todayDuration = activityData['todayDuration'] as int? ?? 0;
        final newTodayDuration = todayDuration + sessionDuration;

        // 월별 누적 시간 업데이트
        final monthlyDurations =
            activityData['monthlyDurations'] as Map<dynamic, dynamic>;
        final todayMinutes = monthlyDurations[dateKey] as int? ?? 0;
        monthlyDurations[dateKey] = todayMinutes + sessionDuration;

        // 전체 누적 시간 업데이트
        final totalDuration = activityData['totalDuration'] as int? ?? 0;
        final newTotalDuration = totalDuration + sessionDuration;

        // 타이머 일시정지
        activityData['state'] = 'paused';
        activityData['startAt'] = null;
        activityData['lastUpdatedAt'] = timestamp;
        activityData['elapsed'] = totalElapsed;
        activityData['todayDuration'] = newTodayDuration;
        activityData['totalDuration'] = newTotalDuration;
        break;

      case 'resume':
        // 타이머가 일시정지 상태인지 확인
        if (activityData!['state'] != 'paused') {
          throw Exception(GroupErrorMessages.timerNotPaused);
        }

        // 타이머 재개
        activityData['state'] = 'resume';
        activityData['startAt'] = timestamp;
        activityData['lastUpdatedAt'] = timestamp;
        break;

      case 'end':
        // 타이머 상태 확인
        if (activityData!['state'] != 'running' &&
            activityData['state'] != 'paused' &&
            activityData['state'] != 'resume') {
          throw Exception(GroupErrorMessages.timerNotActive);
        }

        int sessionDuration = 0;

        // 실행 중인 타이머는 경과 시간 계산이 필요
        if (activityData['state'] == 'running' ||
            activityData['state'] == 'resume') {
          // 시작 시간
          final startAt = activityData['startAt'] as DateTime?;
          if (startAt == null) {
            throw Exception(GroupErrorMessages.invalidTimerState);
          }

          // 현재 세션 경과 시간 계산
          sessionDuration = timestamp.difference(startAt).inSeconds;
          final previousElapsed = activityData['elapsed'] as int? ?? 0;
          final totalElapsed = previousElapsed + sessionDuration;
          activityData['elapsed'] = totalElapsed;
        }

        // 오늘 누적 시간 업데이트
        final todayDuration = activityData['todayDuration'] as int? ?? 0;
        final newTodayDuration = todayDuration + sessionDuration;

        // 월별 누적 시간 업데이트
        final monthlyDurations =
            activityData['monthlyDurations'] as Map<dynamic, dynamic>;
        final todayMinutes = monthlyDurations[dateKey] as int? ?? 0;
        monthlyDurations[dateKey] = todayMinutes + sessionDuration;

        // 전체 누적 시간 업데이트
        final totalDuration = activityData['totalDuration'] as int? ?? 0;
        final newTotalDuration = totalDuration + sessionDuration;

        // 타이머 종료
        activityData['state'] = 'idle';
        activityData['startAt'] = null;
        activityData['lastUpdatedAt'] = timestamp;
        activityData['elapsed'] = 0;
        activityData['todayDuration'] = newTodayDuration;
        activityData['totalDuration'] = newTotalDuration;

        // 월별 통계 업데이트
        _updateMonthlyStats(
          groupId,
          _mockUserId,
          _mockUserName,
          timestamp,
          sessionDuration,
        );
        break;

      default:
        throw Exception('지원하지 않는 활동 타입입니다: $activityType');
    }

    return {...activityData};
  }

  @override
  Future<Map<String, dynamic>> startMemberTimerWithTimestamp(
    String groupId,
    DateTime timestamp,
  ) async {
    return recordTimerActivityWithTimestamp(groupId, 'start', timestamp);
  }

  @override
  Future<Map<String, dynamic>> pauseMemberTimerWithTimestamp(
    String groupId,
    DateTime timestamp,
  ) async {
    return recordTimerActivityWithTimestamp(groupId, 'pause', timestamp);
  }

  @override
  Future<Map<String, dynamic>> stopMemberTimerWithTimestamp(
    String groupId,
    DateTime timestamp,
  ) async {
    return recordTimerActivityWithTimestamp(groupId, 'end', timestamp);
  }

  @override
  Future<Map<String, dynamic>> resumeMemberTimerWithTimestamp(
    String groupId,
    DateTime timestamp,
  ) async {
    return recordTimerActivityWithTimestamp(groupId, 'resume', timestamp);
  }

  @override
  Future<Map<String, dynamic>> fetchUserMaxStreakDays() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _initializeIfNeeded();

    final userId = _currentUserId;
    final userGroupIds = _userGroups[userId] ?? [];

    if (userGroupIds.isEmpty) {
      // 가입한 그룹이 없으면 기본값 반환
      return {
        'maxStreakDays': 0,
        'bestGroupId': null,
        'bestGroupName': null,
        'lastActiveDate': _dateFormat.format(DateTime.now()),
      };
    }

    int maxStreakDays = 0;
    String? bestGroupId;
    String? bestGroupName;
    DateTime? lastActiveDate;

    // 각 그룹별로 연속 출석일 계산
    for (final groupId in userGroupIds) {
      final streakInfo = _calculateUserStreakInfoInGroup(groupId, userId);

      if (streakInfo['streakDays'] > maxStreakDays) {
        maxStreakDays = streakInfo['streakDays'];
        bestGroupId = groupId;
        bestGroupName = streakInfo['groupName'];
        lastActiveDate = streakInfo['lastActiveDate'];
      }
    }

    return {
      'maxStreakDays': maxStreakDays,
      'bestGroupId': bestGroupId,
      'bestGroupName': bestGroupName,
      'lastActiveDate':
          lastActiveDate != null
              ? _dateFormat.format(lastActiveDate)
              : _dateFormat.format(DateTime.now()),
    };
  }

  /// 특정 그룹에서 특정 사용자의 연속 출석일 및 상세 정보 계산
  Map<String, dynamic> _calculateUserStreakInfoInGroup(
    String groupId,
    String userId,
  ) {
    final activities = _timerActivities[groupId] ?? [];

    // 해당 사용자의 활동만 필터링
    final userActivities =
        activities.where((activity) => activity['memberId'] == userId).toList();

    // 그룹 이름 찾기
    final group = _groups.firstWhere(
      (g) => g['id'] == groupId,
      orElse: () => {'name': '알 수 없는 그룹'},
    );
    final groupName = group['name'] as String;

    if (userActivities.isEmpty) {
      return {
        'streakDays': 0,
        'groupName': groupName,
        'lastActiveDate': DateTime.now(),
      };
    }

    // 활동을 날짜순으로 정렬 (최신순)
    userActivities.sort((a, b) {
      try {
        final dateA = _dateFormat.parse(a['timestamp'] as String);
        final dateB = _dateFormat.parse(b['timestamp'] as String);
        return dateB.compareTo(dateA); // 내림차순
      } catch (e) {
        return 0;
      }
    });

    // 날짜별로 그룹화하여 실제 활동한 날짜들 추출
    final Set<String> activeDates = {};
    DateTime? latestActiveDate;

    for (final activity in userActivities) {
      try {
        final timestamp = activity['timestamp'] as String;
        final activityDate = _dateFormat.parse(timestamp);
        final dateKey = DateFormat('yyyy-MM-dd').format(activityDate);

        // 가장 최근 활동 날짜 업데이트
        if (latestActiveDate == null ||
            activityDate.isAfter(latestActiveDate)) {
          latestActiveDate = activityDate;
        }

        // start/end 페어가 있는 날만 실제 활동한 날로 간주
        if (activity['type'] == 'start' || activity['type'] == 'end') {
          activeDates.add(dateKey);
        }
      } catch (e) {
        continue;
      }
    }

    if (activeDates.isEmpty) {
      return {
        'streakDays': 0,
        'groupName': groupName,
        'lastActiveDate': DateTime.now(),
      };
    }

    // 연속 출석일 계산
    final streakDays = _calculateStreakDaysFromActiveDates(activeDates);

    return {
      'streakDays': streakDays,
      'groupName': groupName,
      'lastActiveDate': latestActiveDate ?? DateTime.now(),
    };
  }

  /// 활동한 날짜들로부터 연속 출석일 계산
  int _calculateStreakDaysFromActiveDates(Set<String> activeDates) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd').format(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    // 오늘 또는 어제까지 활동이 있었는지 확인 (연속성 유지 조건)
    bool hasRecentActivity =
        activeDates.contains(today) || activeDates.contains(yesterday);
    if (!hasRecentActivity) {
      return 0; // 최근 활동이 없으면 연속 출석일 0
    }

    int streakDays = 0;

    // 오늘부터 역순으로 연속일 계산
    for (int i = 0; i < 30; i++) {
      // 최대 30일까지만 확인
      final checkDate = DateFormat('yyyy-MM-dd').format(
        DateTime.now().subtract(Duration(days: i)),
      );

      if (activeDates.contains(checkDate)) {
        streakDays++;
      } else {
        break; // 연속성이 끊어지면 중단
      }
    }

    return streakDays;
  }

  @override
  Future<int> fetchWeeklyStudyTimeMinutes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _initializeIfNeeded();

    final userId = _currentUserId;
    final userGroupIds = _userGroups[userId] ?? [];

    if (userGroupIds.isEmpty) {
      return 0; // 가입한 그룹이 없으면 0분 반환
    }

    int totalWeeklyMinutes = 0;

    // 이번 주 시작일과 종료일 계산
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // 월요일
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final weekEndDate = weekStartDate.add(const Duration(days: 7));

    // 각 그룹별로 이번 주 타이머 활동 집계
    for (final groupId in userGroupIds) {
      final activities = _timerActivities[groupId] ?? [];

      // 현재 사용자의 이번 주 활동만 필터링
      final userWeeklyActivities =
          activities.where((activity) {
            if (activity['memberId'] != userId) return false;

            try {
              final timestamp = activity['timestamp'] as String?;
              if (timestamp == null) return false;

              final activityDate = _dateFormat.parse(timestamp);
              return activityDate.isAfter(
                    weekStartDate.subtract(const Duration(seconds: 1)),
                  ) &&
                  activityDate.isBefore(weekEndDate);
            } catch (e) {
              return false;
            }
          }).toList();

      // 시간순 정렬
      userWeeklyActivities.sort((a, b) {
        try {
          final dateA = _dateFormat.parse(a['timestamp'] as String);
          final dateB = _dateFormat.parse(b['timestamp'] as String);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

      // start/end 페어 매칭하여 시간 계산
      DateTime? startTime;
      for (final activity in userWeeklyActivities) {
        final type = activity['type'] as String?;
        final timestamp = activity['timestamp'] as String?;

        if (timestamp == null) continue;

        try {
          final activityTime = _dateFormat.parse(timestamp);

          if (type == 'start') {
            startTime = activityTime;
          } else if (type == 'end' && startTime != null) {
            final duration = activityTime.difference(startTime).inMinutes;
            if (duration > 0) {
              totalWeeklyMinutes += duration;
            }
            startTime = null; // 페어 처리 완료
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Mock 환경에서는 임의의 값도 추가 (더 현실적인 데이터를 위해)
    if (totalWeeklyMinutes == 0) {
      // 기본적으로 8-25시간 사이의 랜덤한 주간 공부 시간 생성
      final baseMinutes = 8 * 60; // 8시간
      final randomAdditional = _random.nextInt(17 * 60); // 0-17시간 추가
      totalWeeklyMinutes = baseMinutes + randomAdditional;
    }

    return totalWeeklyMinutes;
  }
}
