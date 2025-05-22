네, 이제 정확한 개선 방향으로 문서를 개선하겠습니다.

---

# 🧩 Firebase 데이터 모델 설계 가이드

---

# 🧩 User

---

## 📁 1. Firestore 컬렉션 구조: `users/{userId}`

| 필드명                     | 타입           | 설명                                 |
|--------------------------|----------------|--------------------------------------|
| `email`                  | `string`       | 로그인용 이메일                       |
| `nickname`               | `string`       | 닉네임 또는 표시 이름                  |
| `uid`                    | `string`       | Firebase Auth UID (문서 ID와 동일)    |
| `image`                  | `string`       | 프로필 이미지 URL                    |
| `agreedTermId`           | `string`       | 동의한 약관 버전 ID                   |
| `description`            | `string`       | 자기소개                             |
| `isServiceTermsAgreed`   | `boolean`      | 서비스 이용약관 동의 여부             |
| `isPrivacyPolicyAgreed`  | `boolean`      | 개인정보 수집 이용 동의 여부          |
| `isMarketingAgreed`      | `boolean`      | 마케팅 수신 동의 여부                 |
| `agreedAt`               | `timestamp`    | 약관 동의 시간                        |
| `joingroup`              | `array`        | 가입된 그룹 목록 (JoinedGroup 객체 배열) |

### ✅ JoinedGroup 객체 구조

| 필드명         | 타입      | 설명                    |
|----------------|-----------|-------------------------|
| `group_name`   | `string`  | 그룹 이름               |
| `group_image`  | `string`  | 그룹 대표 이미지 URL     |

### ✅ 예시 JSON

```json
{
  "email": "test@example.com",
  "nickname": "개발돌이",
  "uid": "firebase-uid-123",
  "image": "https://cdn.example.com/profile.jpg",
  "agreedTermId": "v2.3",
  "description": "Flutter 개발자입니다",
  "isServiceTermsAgreed": true,
  "isPrivacyPolicyAgreed": true,
  "isMarketingAgreed": false,
  "agreedAt": "2025-05-13T10:00:00Z",
  "joingroup": [
    {
      "group_name": "개발자모임",
      "group_image": "https://cdn.example.com/group1.jpg"
    },
    {
      "group_name": "타이머스터디",
      "group_image": "https://cdn.example.com/group2.jpg"
    }
  ]
}
```

### ✅ 예시 쿼리

```js
// 닉네임으로 검색
db.collection("users").where("nickname", "==", "개발돌이").get();

// 마케팅 동의 유저 목록
db.collection("users").where("isMarketingAgreed", "==", true).get();
```

---

## 📁 2. 하위 컬렉션: `users/{userId}/timerActivities/{activityId}`

| 필드명       | 타입                     | 설명                                   |
|--------------|--------------------------|----------------------------------------|
| `memberId`   | `string`                 | 활동을 수행한 사용자 ID                |
| `type`       | `string`                 | `"start"`, `"pause"`, `"resume"`, `"end"` 중 하나 |
| `timestamp`  | `timestamp`              | 활동 발생 시간                         |
| `metadata`   | `object`                 | 부가 데이터 (기기, 설명 등)             |

### ✅ 예시 JSON

```json
{
  "memberId": "user123",
  "type": "start",
  "timestamp": "2025-05-13T10:00:00Z",
  "metadata": {
    "from": "mobile",
    "task": "공부 타이머"
  }
}
```

### ✅ 예시 쿼리

```js
// 특정 유저의 모든 활동 로그
db.collection("users")
  .doc("user123")
  .collection("timerActivities")
  .orderBy("timestamp", "desc")
  .get();

// 특정 날짜 이후 활동
db.collection("users")
  .doc("user123")
  .collection("timerActivities")
  .where("timestamp", ">=", new Date("2025-05-13T00:00:00Z"))
  .get();
```

---

## 📦 DTO 구조 정리

### 1. UserDto

| 필드명                   | 타입                   | nullable | @JsonKey | 설명                                  |
|------------------------|------------------------|----------|----------|---------------------------------------|
| `email`                | `String`              | ✅        | -        | 사용자 이메일                         |
| `nickname`             | `String`              | ✅        | -        | 사용자 닉네임                         |
| `uid`                  | `String`              | ✅        | -        | Firebase UID (문서 ID와 동일)          |
| `image`                | `String`              | ✅        | -        | 프로필 이미지 URL                     |
| `agreedTermId`         | `String`              | ✅        | -        | 약관 버전 ID                          |
| `description`          | `String`              | ✅        | -        | 자기소개                              |
| `isServiceTermsAgreed` | `bool`                | ✅        | -        | 서비스 이용약관 동의 여부              |
| `isPrivacyPolicyAgreed`| `bool`                | ✅        | -        | 개인정보처리방침 동의 여부             |
| `isMarketingAgreed`    | `bool`                | ✅        | -        | 마케팅 동의 여부                       |
| `agreedAt`             | `DateTime`            | ✅        | -        | 동의한 시점                            |
| `joingroup`            | `List<JoinedGroupDto>`| ✅        | -        | 가입한 그룹 목록                       |

---

### 2. JoinedGroupDto (내장 객체 - ID 불필요)

| 필드명         | 타입      | nullable | @JsonKey | 설명                    |
|----------------|-----------|----------|----------|-------------------------|
| `groupName`    | `String` | ✅        | `group_name` | 그룹 이름               |
| `groupImage`   | `String` | ✅        | `group_image` | 그룹 대표 이미지 URL     |

---

### 3. TimerActivityDto (독립 문서 - ID 필요)

| 필드명     | 타입                     | nullable | @JsonKey | 설명                                            |
|------------|--------------------------|----------|----------|-------------------------------------------------|
| `id`       | `String`                | ✅        | -        | 활동 ID (문서 ID와 동일)                        |
| `memberId` | `String`                | ✅        | -        | 활동을 수행한 사용자 ID                         |
| `type`     | `String`                | ✅        | -        | `"start"`, `"pause"`, `"resume"`, `"end"` 중 하나 |
| `timestamp`| `DateTime`              | ✅        | -        | 활동 발생 시간                                   |
| `metadata` | `Map<String, dynamic>`  | ✅        | -        | 부가 정보 (기기, 설명 등)                         |

---

---

# 🧩 Group

---

## 📁 1. 컬렉션: `groups/{groupId}`

| 필드명            | 타입            | 설명                                  |
|------------------|-----------------|---------------------------------------|
| `name`           | `string`        | 그룹 이름                              |
| `description`    | `string`        | 그룹 설명                              |
| `imageUrl`       | `string`        | 그룹 대표 이미지 URL                   |
| `createdAt`      | `timestamp`     | 그룹 생성 시간                          |
| `createdBy`      | `string`        | 생성자 ID                              |
| `maxMemberCount` | `number`        | 최대 멤버 수                            |
| `hashTags`       | `array`         | 해시태그 리스트 (예: ["#스터디", "#공부"]) |

### ✅ 예시 JSON

```json
{
  "name": "공부 타이머 그룹",
  "description": "같이 집중해서 공부하는 그룹",
  "imageUrl": "https://cdn.example.com/group.jpg",
  "createdAt": "2025-05-13T09:00:00Z",
  "createdBy": "user_abc",
  "maxMemberCount": 10,
  "hashTags": ["#스터디", "#공부"]
}
```

---

## 📁 2. 하위 컬렉션: `groups/{groupId}/members/{userId}`

| 필드명       | 타입      | 설명                                       |
|--------------|-----------|--------------------------------------------|
| `userId`     | `string`  | 사용자 ID                                  |
| `userName`   | `string`  | 사용자 닉네임 또는 이름                        |
| `profileUrl` | `string`  | 프로필 이미지 URL                           |
| `role`       | `string`  | 역할 (`"admin"`, `"moderator"`, `"member"`) |
| `joinedAt`   | `timestamp` | 그룹 가입 시간                              |
| `isActive`   | `boolean` | 현재 활동 중인지 여부                        |

### ✅ 예시 JSON

```json
{
  "userId": "user_123",
  "userName": "홍길동",
  "profileUrl": "https://cdn.example.com/profile.jpg",
  "role": "member",
  "joinedAt": "2025-05-12T15:00:00Z",
  "isActive": false
}
```

---

## 📁 3. 하위 컬렉션: `groups/{groupId}/timerActivities/{activityId}`

| 필드명      | 타입                   | 설명                                             |
|-------------|------------------------|--------------------------------------------------|
| `memberId`  | `string`               | 타이머를 수행한 멤버 ID                             |
| `type`      | `string`               | `"start"`, `"pause"`, `"resume"`, `"end"` 중 하나 |
| `timestamp` | `timestamp`            | 발생 시각                                         |
| `metadata`  | `object`               | 선택적 메타 정보 (예: 태그, 디바이스 정보 등)        |

### ✅ 예시 JSON

```json
{
  "memberId": "user_123",
  "type": "pause",
  "timestamp": "2025-05-13T10:30:00Z",
  "metadata": {
    "reason": "잠시 휴식",
    "device": "iOS"
  }
}
```

---

## 📦 DTO 구조 정리

### 1. GroupDto (독립 문서 - ID 필요)

| 필드명            | 타입            | nullable | @JsonKey | 설명                           |
|------------------|-----------------|----------|----------|--------------------------------|
| `id`             | `String`        | ✅        | -        | 그룹 ID (문서 ID와 동일)         |
| `name`           | `String`        | ✅        | -        | 그룹 이름                        |
| `description`    | `String`        | ✅        | -        | 그룹 설명                        |
| `imageUrl`       | `String`        | ✅        | -        | 이미지 URL                       |
| `createdAt`      | `DateTime`      | ✅        | -        | 생성 시각                        |
| `createdBy`      | `String`        | ✅        | -        | 생성자 ID                        |
| `maxMemberCount` | `int`           | ✅        | -        | 최대 멤버 수                     |
| `hashTags`       | `List<String>`  | ✅        | -        | 해시태그 목록                     |

---

### 2. GroupMemberDto (독립 문서 - ID 필요)

| 필드명       | 타입      | nullable | @JsonKey | 설명                         |
|--------------|-----------|----------|----------|------------------------------|
| `id`         | `String` | ✅        | -        | 멤버 ID (문서 ID와 동일)       |
| `userId`     | `String` | ✅        | -        | 사용자 ID                     |
| `userName`   | `String` | ✅        | -        | 닉네임                         |
| `profileUrl` | `String` | ✅        | -        | 프로필 이미지 URL              |
| `role`       | `String` | ✅        | -        | 역할: `"admin"`, `"moderator"`, `"member"` |
| `joinedAt`   | `DateTime` | ✅        | -        | 가입 시각                      |
| `isActive`   | `bool`   | ✅        | -        | 현재 활동 여부                 |

---

### 3. GroupTimerActivityDto (독립 문서 - ID 필요)

| 필드명      | 타입                     | nullable | @JsonKey | 설명                                      |
|-------------|--------------------------|----------|----------|-------------------------------------------|
| `id`        | `String`                | ✅        | -        | 활동 ID (문서 ID와 동일)                   |
| `memberId`  | `String`                | ✅        | -        | 활동한 멤버 ID                             |
| `type`      | `String`                | ✅        | -        | 활동 타입                                  |
| `timestamp` | `DateTime`              | ✅        | -        | 활동 발생 시각                              |
| `metadata`  | `Map<String, dynamic>`  | ✅        | -        | 선택적 메타데이터 (이유, 디바이스 등)         |

---

---

# 🧩 POST

---

## 📁 1. 컬렉션 구조: `posts/{postId}`

| 필드명             | 타입             | 설명                                    |
|-------------------|------------------|-----------------------------------------|
| `id`              | `string`         | 게시글 ID (문서 ID와 동일)               |
| `authorId`        | `string`         | 작성자 UID                              |
| `authorNickname`  | `string`         | 작성자 닉네임 (비정규화)                 |
| `authorPosition`  | `string`         | 작성자 직책/포지션 (비정규화)            |
| `userProfileImage`| `string`         | 작성자 프로필 이미지 URL                |
| `title`           | `string`         | 게시글 제목                              |
| `content`         | `string`         | 게시글 본문 내용                         |
| `mediaUrls`       | `array`          | 첨부 이미지, 비디오 등의 URL 목록        |
| `createdAt`       | `timestamp`      | 게시글 작성 시간                         |
| `hashTags`        | `array`          | 해시태그 목록 (예: ["스터디", "정처기"]) |
| `likeCount`       | `number`         | 좋아요 수 (비정규화)                     |
| `commentCount`    | `number`         | 댓글 수 (비정규화)                       |

### ✅ 예시 JSON

```json
{
  "id": "post_001",
  "authorId": "user_abc",
  "authorNickname": "개발자123",
  "authorPosition": "프론트엔드 개발자",
  "userProfileImage": "https://cdn.example.com/profile.jpg",
  "title": "함께 공부해요",
  "content": "오늘도 열심히 타이머 돌려봅시다.",
  "mediaUrls": ["https://cdn.example.com/img1.png"],
  "createdAt": "2025-05-13T12:00:00Z",
  "hashTags": ["스터디", "정처기"],
  "likeCount": 5,
  "commentCount": 3
}
```

---

## 📁 2. 하위 컬렉션: `posts/{postId}/likes/{userId}`

| 필드명       | 타입       | 설명                            |
|--------------|------------|---------------------------------|
| `userId`     | `string`   | 좋아요를 누른 사용자 ID         |
| `userName`   | `string`   | 사용자 이름                     |
| `timestamp`  | `timestamp`| 좋아요를 누른 시간              |

### ✅ 예시 JSON

```json
{
  "userId": "user_456",
  "userName": "김개발",
  "timestamp": "2025-05-13T12:30:00Z"
}
```

---

## 📁 3. 하위 컬렉션: `posts/{postId}/comments/{commentId}`

| 필드명            | 타입       | 설명                                |
|-------------------|------------|-------------------------------------|
| `id`              | `string`   | 댓글 ID (문서 ID와 동일)            |
| `userId`          | `string`   | 댓글 작성자 ID                      |
| `userName`        | `string`   | 댓글 작성자 이름                    |
| `userProfileImage`| `string`   | 댓글 작성자 프로필 이미지 URL       |
| `text`            | `string`   | 댓글 내용                           |
| `createdAt`       | `timestamp`| 댓글 작성 시간                      |
| `likeCount`       | `number`   | 해당 댓글의 좋아요 수 (비정규화)    |

### ✅ 예시 JSON

```json
{
  "id": "comment_123",
  "userId": "user_789",
  "userName": "박코딩",
  "userProfileImage": "https://cdn.example.com/profile2.jpg",
  "text": "저도 참여하고 싶어요!",
  "createdAt": "2025-05-13T12:45:00Z",
  "likeCount": 2
}
```

---

## 📦 DTO 구조 정리

### 1. PostDto (최적화 버전)

| 필드명             | 타입             | nullable | @JsonKey | 설명                                  |
|-------------------|------------------|----------|----------|---------------------------------------|
| `id`              | `String`        | ✅        | -        | 게시글 ID (문서 ID와 동일)             |
| `authorId`        | `String`        | ✅        | -        | 작성자 ID                              |
| `authorNickname`  | `String`        | ✅        | -        | 작성자 닉네임 (비정규화)               |
| `authorPosition`  | `String`        | ✅        | -        | 작성자 직책/포지션 (비정규화)          |
| `userProfileImage`| `String`        | ✅        | -        | 프로필 이미지 URL                     |
| `title`           | `String`        | ✅        | -        | 제목                                  |
| `content`         | `String`        | ✅        | -        | 내용                                  |
| `mediaUrls`       | `List<String>`  | ✅        | -        | 첨부 이미지/비디오 URL 목록           |
| `createdAt`       | `DateTime`      | ✅        | 특수처리   | 작성 시각                             |
| `hashTags`        | `List<String>`  | ✅        | -        | 해시태그 목록                         |
| `likeCount`       | `int`           | ✅        | Firebase에 저장 | 좋아요 수 (비정규화)              |
| `commentCount`    | `int`           | ✅        | Firebase에 저장 | 댓글 수 (비정규화)                |
| `isLikedByCurrentUser`    | `bool`  | ✅        | 저장 안함 | 현재 사용자의 좋아요 상태 (UI용)     |

---

### 2. PostLikeDto

| 필드명      | 타입       | nullable | @JsonKey | 설명                         |
|-------------|------------|----------|----------|------------------------------|
| `id`        | `String`  | ✅        | -        | 좋아요 ID (문서 ID와 동일)     |
| `userId`    | `String`  | ✅        | -        | 좋아요 누른 사용자 ID         |
| `userName`  | `String`  | ✅        | -        | 사용자 이름                   |
| `timestamp` | `DateTime`| ✅        | 특수처리   | 좋아요 시간                   |

---

### 3. PostCommentDto (최적화 버전)

| 필드명            | 타입       | nullable | @JsonKey | 설명                             |
|-------------------|------------|----------|----------|----------------------------------|
| `id`              | `String`  | ✅        | -        | 댓글 ID (문서 ID와 동일)          |
| `userId`          | `String`  | ✅        | -        | 댓글 작성자 ID                    |
| `userName`        | `String`  | ✅        | -        | 댓글 작성자 이름                  |
| `userProfileImage`| `String`  | ✅        | -        | 댓글 작성자 프로필 이미지 URL      |
| `text`            | `String`  | ✅        | -        | 댓글 본문 내용                     |
| `createdAt`       | `DateTime`| ✅        | 특수처리   | 댓글 작성 시각                     |
| `likeCount`       | `int`     | ✅        | Firebase에 저장 | 좋아요 수 (비정규화)          |
| `isLikedByCurrentUser` | `bool` | ✅      | 저장 안함 | 현재 사용자의 좋아요 상태 (UI용)    |

---

## 📝 좋아요 상태 처리 최적화

### N+1 문제 해결을 위한 일괄 상태 조회

게시글 목록을 조회할 때 N개의 게시글마다 각각 좋아요 상태를 확인하면 총 N+1번의 쿼리가 발생합니다. 이를 개선하기 위해 일괄 처리 방식을 적용할 수 있습니다:

```dart
// DataSource 레벨에서 일괄 조회 메소드 제공
Future<Map<String, bool>> checkUserLikeStatus(List<String> postIds, String userId) async {
  final result = <String, bool>{};
  
  // 병렬 처리로 효율화
  final futures = postIds.map((postId) async {
    final doc = await firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .get();
        
    result[postId] = doc.exists;
  });
  
  await Future.wait(futures);
  return result;
}
```

### 적용 방법

1. 게시글 목록 조회 후 즉시 좋아요 상태 일괄 조회
   ```dart
   // Repository 레벨에서 구현
   Future<List<Post>> getPostListWithLikeStatus(String userId) async {
     // 1. 게시글 목록 조회
     final postDtos = await _dataSource.fetchPostList();
     
     // 2. 좋아요 상태 일괄 조회 (N+1 문제 해결)
     final postIds = postDtos.map((dto) => dto.id!).toList();
     final likeStatuses = await _dataSource.checkUserLikeStatus(postIds, userId);
     
     // 3. 결과 병합
     return postDtos.map((dto) {
       final isLiked = likeStatuses[dto.id] ?? false;
       return dto.copyWith(isLikedByCurrentUser: isLiked).toModel();
     }).toList();
   }
   ```

2. 비정규화된 likeCount와 함께 사용하여 UI 렌더링 최적화
   ```dart
   // 모든 게시글에 좋아요 상태 정보 적용
   void _applyLikeStatus(List<PostDto> posts, Map<String, bool> likeStatuses) {
     return posts.map((post) {
       // isLikedByCurrentUser 필드 업데이트
       return post.copyWith(
         isLikedByCurrentUser: likeStatuses[post.id] ?? false,
       );
     }).toList();
   }
   ```

### 장점

1. 게시글 수에 관계없이 좋아요 상태 조회는 항상 단 한 번의 일괄 요청
2. 비정규화된 `likeCount` 필드로 좋아요 수를 바로 표시할 수 있음
3. 각 게시글의 좋아요 상태(`isLikedByCurrentUser`)는 UI 전용 필드로 활용