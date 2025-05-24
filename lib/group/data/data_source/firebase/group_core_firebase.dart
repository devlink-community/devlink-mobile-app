import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devlink_mobile_app/core/utils/api_call_logger.dart';
import 'package:devlink_mobile_app/core/utils/app_logger.dart';
import 'package:devlink_mobile_app/core/utils/messages/auth_error_messages.dart';
import 'package:devlink_mobile_app/core/utils/messages/group_error_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// 그룹 핵심 기능 (생성, 수정, 삭제, 가입, 탈퇴)
class GroupCoreFirebase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  GroupCoreFirebase({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _auth = auth,
       _storage = storage;

  // Collection 참조들
  CollectionReference<Map<String, dynamic>> get _groupsCollection =>
      _firestore.collection('groups');
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// 현재 사용자 ID 확인 헬퍼 메서드
  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception(AuthErrorMessages.noLoggedInUser);
    }
    return user.uid;
  }

  /// 현재 사용자 정보 가져오기 헬퍼 메서드
  Future<Map<String, String>> _getCurrentUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception(AuthErrorMessages.noLoggedInUser);
    }

    final userId = user.uid;
    final userName = user.displayName ?? '';
    final profileUrl = user.photoURL ?? '';

    return {
      'userId': userId,
      'userName': userName,
      'profileUrl': profileUrl,
    };
  }

  /// 🆕 새로운 메서드: 그룹 생성용 이미지 업로드
  Future<String> uploadGroupCreationImage(String localImagePath) async {
    return ApiCallDecorator.wrap(
      'GroupCore.uploadGroupCreationImage',
      () async {
        try {
          // URL인 경우 (이미 업로드된 이미지 사용)
          if (localImagePath.startsWith('http')) {
            return localImagePath;
          }

          // 로컬 파일 업로드
          final userId = _getCurrentUserId();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = '${timestamp}_${localImagePath.split('/').last}';

          // 그룹 생성용 이미지는 별도 폴더에 저장
          final storageRef = _storage.ref().child(
            'group_creation_images/$userId/$fileName',
          );

          // 파일 업로드
          final uploadTask = await storageRef.putFile(File(localImagePath));

          // 다운로드 URL 가져오기
          final downloadUrl = await uploadTask.ref.getDownloadURL();

          AppLogger.info(
            '그룹 생성용 이미지 업로드 완료: $downloadUrl',
            tag: 'GroupCoreFirebase',
          );

          return downloadUrl;
        } catch (e) {
          AppLogger.error(
            '그룹 생성용 이미지 업로드 오류',
            tag: 'GroupCoreFirebase',
            error: e,
          );
          throw Exception('이미지 업로드에 실패했습니다');
        }
      },
      params: {'localImagePath': localImagePath},
    );
  }

  /// 그룹 생성
  Future<Map<String, dynamic>> createGroup(
    Map<String, dynamic> groupData,
  ) async {
    return ApiCallDecorator.wrap('GroupCore.createGroup', () async {
      try {
        // 현재 사용자 정보 가져오기
        final userInfo = await _getCurrentUserInfo();
        final ownerId = userInfo['userId']!;
        final ownerNickname = userInfo['userName']!;
        final ownerProfileUrl = userInfo['profileUrl']!;

        // 새 그룹 ID 생성
        final groupRef = _groupsCollection.doc();
        final groupId = groupRef.id;

        // 타임스탬프 생성
        final now = FieldValue.serverTimestamp();

        // 그룹 데이터 준비
        final finalGroupData = {
          ...groupData,
          'createdAt': now,
          'updatedAt': now,
          'ownerId': ownerId,
          'ownerNickname': ownerNickname,
          'ownerProfileImage': ownerProfileUrl,
          'memberCount': 1, // 처음에는 생성자만 멤버
        };

        // 트랜잭션을 사용하여 그룹 생성 및 멤버 추가
        await _firestore.runTransaction((transaction) async {
          // 1. 그룹 문서 생성
          transaction.set(groupRef, finalGroupData);

          // 2. 소유자(방장) 멤버 추가
          transaction.set(groupRef.collection('members').doc(ownerId), {
            'userId': ownerId,
            'userName': ownerNickname,
            'profileUrl': ownerProfileUrl,
            'role': 'owner',
            'joinedAt': now,
          });

          // 3. 사용자 문서에 가입 그룹 정보 추가
          transaction.update(_usersCollection.doc(ownerId), {
            'joingroup': FieldValue.arrayUnion([
              {
                'group_id': groupId,
                'group_name': groupData['name'] ?? '',
                'group_image': groupData['imageUrl'] ?? '',
              },
            ]),
          });
        });

        // 생성된 그룹 정보 반환을 위한 준비
        final createdGroupDoc = await groupRef.get();
        if (!createdGroupDoc.exists) {
          throw Exception(GroupErrorMessages.createFailed);
        }

        // 생성된 그룹 데이터 반환
        final createdData = createdGroupDoc.data()!;
        createdData['id'] = groupId;
        createdData['isJoinedByCurrentUser'] = true; // 생성자는 항상 가입됨

        return createdData;
      } catch (e) {
        AppLogger.error(
          '그룹 생성 오류',
          tag: 'GroupCoreFirebase',
          error: e,
        );
        throw Exception(GroupErrorMessages.createFailed);
      }
    });
  }

  /// 그룹 정보 업데이트
  Future<void> updateGroup(
    String groupId,
    Map<String, dynamic> updateData,
  ) async {
    return ApiCallDecorator.wrap('GroupCore.updateGroup', () async {
      try {
        // 업데이트 필드 준비
        final updates = {...updateData};

        // id, createdAt, createdBy, memberCount는 수정 불가
        updates.remove('id');
        updates.remove('createdAt');
        updates.remove('createdBy');
        updates.remove('memberCount');

        // 업데이트 시간 추가
        updates['updatedAt'] = FieldValue.serverTimestamp();

        // 그룹 이름이나 이미지가 변경되는 경우에만 멤버 정보 업데이트 필요
        final nameChanged = updates.containsKey('name');
        final imageUrlChanged = updates.containsKey('imageUrl');

        if (nameChanged || imageUrlChanged) {
          // WriteBatch 생성
          final batch = _firestore.batch();

          // 그룹 문서 업데이트
          batch.update(_groupsCollection.doc(groupId), updates);

          // 멤버 목록 조회
          final membersSnapshot =
              await _groupsCollection.doc(groupId).collection('members').get();

          // 각 멤버의 사용자 문서에서 joingroup 배열 업데이트
          for (final memberDoc in membersSnapshot.docs) {
            final userId = memberDoc.data()['userId'] as String?;
            if (userId == null) continue;

            // 사용자 문서 참조
            final userRef = _usersCollection.doc(userId);

            // 현재 그룹 정보 조회
            final userDoc = await userRef.get();
            if (!userDoc.exists || !userDoc.data()!.containsKey('joingroup')) {
              continue;
            }

            final joingroups = userDoc.data()!['joingroup'] as List<dynamic>;

            // 현재 그룹 정보 찾기
            for (int i = 0; i < joingroups.length; i++) {
              final groupInfo = joingroups[i] as Map<String, dynamic>;

              if (groupInfo['group_id'] == groupId) {
                // 새 그룹 정보 생성
                final updatedGroupInfo = {
                  'group_id': groupId,
                  'group_name':
                      nameChanged ? updates['name'] : groupInfo['group_name'],
                  'group_image':
                      imageUrlChanged
                          ? updates['imageUrl']
                          : groupInfo['group_image'],
                };

                // 기존 그룹 정보 제거 후 새 정보 추가
                batch.update(userRef, {
                  'joingroup': FieldValue.arrayRemove([groupInfo]),
                });

                batch.update(userRef, {
                  'joingroup': FieldValue.arrayUnion([updatedGroupInfo]),
                });

                break;
              }
            }
          }

          // 모든 작업을 한 번에 커밋
          await batch.commit();
        } else {
          // 그룹 이름/이미지가 변경되지 않았으면 그룹 문서만 업데이트
          await _groupsCollection.doc(groupId).update(updates);
        }
      } catch (e) {
        AppLogger.error(
          '그룹 업데이트 오류',
          tag: 'GroupCoreFirebase',
          error: e,
        );
        throw Exception(GroupErrorMessages.updateFailed);
      }
    }, params: {'groupId': groupId});
  }

  /// 그룹 가입
  Future<void> joinGroup(String groupId) async {
    return ApiCallDecorator.wrap('GroupCore.joinGroup', () async {
      try {
        // 현재 사용자 정보 가져오기
        final userInfo = await _getCurrentUserInfo();
        final userId = userInfo['userId']!;
        final userName = userInfo['userName']!;
        final profileUrl = userInfo['profileUrl']!;

        // 트랜잭션을 사용하여 멤버 추가 및 카운터 업데이트
        return _firestore.runTransaction((transaction) async {
          // 1. 그룹 문서 조회
          final groupDoc = await transaction.get(
            _groupsCollection.doc(groupId),
          );

          if (!groupDoc.exists) {
            throw Exception(GroupErrorMessages.notFound);
          }

          // 2. 현재 멤버 수 확인
          final data = groupDoc.data()!;
          final currentMemberCount = data['memberCount'] as int? ?? 0;
          final maxMemberCount = data['maxMemberCount'] as int? ?? 10;

          // 3. 멤버 수 제한 확인
          if (currentMemberCount >= maxMemberCount) {
            throw Exception(GroupErrorMessages.memberLimitReached);
          }

          // 4. 멤버 추가
          transaction.set(
            _groupsCollection.doc(groupId).collection('members').doc(userId),
            {
              'userId': userId,
              'userName': userName,
              'profileUrl': profileUrl,
              'role': 'member',
              'joinedAt': FieldValue.serverTimestamp(),
            },
          );

          // 5. 멤버 수 증가
          transaction.update(_groupsCollection.doc(groupId), {
            'memberCount': currentMemberCount + 1,
          });

          // 6. 사용자 문서에 가입 그룹 정보 추가
          transaction.update(_usersCollection.doc(userId), {
            'joingroup': FieldValue.arrayUnion([
              {
                'group_id': groupId,
                'group_name': data['name'] ?? '',
                'group_image': data['imageUrl'] ?? '',
              },
            ]),
          });
        });
      } catch (e, st) {
        // 예외 구분 처리
        if (e is Exception &&
            (e.toString().contains(GroupErrorMessages.notFound) ||
                e.toString().contains(GroupErrorMessages.memberLimitReached))) {
          AppLogger.error(
            '그룹 가입 비즈니스 로직 오류',
            tag: 'GroupCoreFirebase',
            error: e,
          );
          rethrow;
        } else {
          AppLogger.error(
            '그룹 가입 Firebase 통신 오류',
            tag: 'GroupCoreFirebase',
            error: e,
            stackTrace: st,
          );
          rethrow;
        }
      }
    }, params: {'groupId': groupId});
  }

  /// 그룹 탈퇴
  Future<void> leaveGroup(String groupId) async {
    return ApiCallDecorator.wrap('GroupCore.leaveGroup', () async {
      try {
        final userId = _getCurrentUserId();

        // 트랜잭션을 사용하여 멤버 제거 및 카운터 업데이트
        return _firestore.runTransaction((transaction) async {
          // 1단계: 모든 읽기 작업을 먼저 수행
          final groupDoc = await transaction.get(
            _groupsCollection.doc(groupId),
          );
          final memberDoc = await transaction.get(
            _groupsCollection.doc(groupId).collection('members').doc(userId),
          );
          final userDoc = await transaction.get(_usersCollection.doc(userId));

          // 2단계: 읽기 완료 후 검증 로직
          if (!groupDoc.exists) {
            throw Exception(GroupErrorMessages.notFound);
          }

          // 비즈니스 로직 검증: 멤버 여부 확인
          if (!memberDoc.exists) {
            throw Exception(GroupErrorMessages.notMember);
          }

          // 소유자 확인 (소유자는 탈퇴 불가)
          final memberData = memberDoc.data()!;

          // 비즈니스 로직 검증: 소유자 탈퇴 방지
          if (memberData['role'] == 'owner') {
            throw Exception(GroupErrorMessages.ownerCannotLeave);
          }

          // 현재 멤버 수 확인
          final groupData = groupDoc.data()!;
          final currentMemberCount = groupData['memberCount'] as int? ?? 0;

          // 3단계: 모든 쓰기 작업을 나중에 수행
          // 멤버 제거
          transaction.delete(
            _groupsCollection.doc(groupId).collection('members').doc(userId),
          );

          // 멤버 수 감소
          transaction.update(_groupsCollection.doc(groupId), {
            'memberCount': currentMemberCount > 0 ? currentMemberCount - 1 : 0,
          });

          // 사용자 문서에서 가입 그룹 정보 제거
          if (userDoc.exists && userDoc.data()!.containsKey('joingroup')) {
            final joingroups = userDoc.data()!['joingroup'] as List<dynamic>;

            // 그룹 ID로 항목 찾기
            for (final joingroup in joingroups) {
              if (joingroup['group_id'] == groupId) {
                // 그룹 정보 제거
                transaction.update(_usersCollection.doc(userId), {
                  'joingroup': FieldValue.arrayRemove([joingroup]),
                });
                break;
              }
            }
          }
        });
      } catch (e, st) {
        // 예외 구분 처리
        if (e is Exception &&
            (e.toString().contains(GroupErrorMessages.notFound) ||
                e.toString().contains(GroupErrorMessages.notMember) ||
                e.toString().contains(GroupErrorMessages.ownerCannotLeave))) {
          AppLogger.error(
            '그룹 탈퇴 비즈니스 로직 오류',
            tag: 'GroupCoreFirebase',
            error: e,
          );
          rethrow;
        } else {
          AppLogger.error(
            '그룹 탈퇴 Firebase 통신 오류',
            tag: 'GroupCoreFirebase',
            error: e,
            stackTrace: st,
          );
          rethrow;
        }
      }
    }, params: {'groupId': groupId});
  }
}
