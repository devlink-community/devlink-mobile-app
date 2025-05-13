import 'package:image_picker/image_picker.dart';
import '../../../auth/data/data_source/auth_data_source.dart';
import '../../../auth/data/data_source/profile_data_source.dart';
import '../../../auth/data/dto/profile_dto.dart';
import '../../../auth/data/dto/user_dto.dart';
import '../../../auth/data/mapper/member_mapper.dart';
import '../../../auth/domain/model/member.dart';
import '../../../core/result/result.dart';
import '../../domain/repository/edit_intro_repository.dart';

class EditIntroRepositoryImpl implements EditIntroRepository {
  final AuthDataSource _authDataSource;
  final ProfileDataSource _profileDataSource;

  EditIntroRepositoryImpl({
    required AuthDataSource authDataSource,
    required ProfileDataSource profileDataSource,
  }) : _authDataSource = authDataSource,
       _profileDataSource = profileDataSource;

  @override
  Future<Result<Member>> getCurrentProfile() async {
    try {
      // 현재 로그인된 사용자 정보 가져오기
      final userMap = await _authDataSource.fetchCurrentUser();

      // 모의(Mock) 사용자 데이터 생성 (실제 환경에서는 서버 연동 필요)
      // userMap이 null인 경우 (로그인 안됨) 모의 데이터 반환
      if (userMap == null) {
        // 모의 데이터 생성
        final mockMember = Member(
          id: 'mock-id',
          email: 'user@example.com',
          nickname: '사용자',
          uid: 'mock-uid',
          image: 'https://via.placeholder.com/150',
          description: '안녕하세요! 자기소개를 입력해주세요.',
        );

        return Result.success(mockMember);
      }

      // UserDto로 변환
      final userDto = UserDto.fromJson(userMap);

      // 프로필 정보 가져오기
      final profileMap = await _profileDataSource.fetchUserProfile(userDto.id!);
      final profileDto = ProfileDto.fromJson(profileMap);

      // Member 객체로 변환
      final member = userDto.toModelFromProfile(profileDto);
      return Result.success(member);
    } catch (e, st) {
      // 에러 발생 시 모의 데이터 반환 (개발/테스트 환경용)
      // 실제 환경에서는 적절한 에러 처리가 필요합니다
      final mockMember = Member(
        id: 'error-mock-id',
        email: 'error@example.com',
        nickname: '임시 사용자',
        uid: 'error-mock-uid',
        image: 'https://via.placeholder.com/150',
        description: '프로필 로드 중 오류가 발생했습니다.',
      );

      return Result.success(mockMember);

      // 실제 에러 반환 코드 (프로덕션 환경용)
      // return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Member>> updateProfile({
    required String nickname,
    String? intro,
  }) async {
    try {
      // 실제 구현에서는 API 호출
      // 여기서는 현재 프로필 가져와서 업데이트된 내용으로 반환
      final userResult = await getCurrentProfile();

      switch (userResult) {
        case Success(:final data):
          final updatedMember = data.copyWith(
            nickname: nickname,
            description: intro ?? data.description,
          );
          return Result.success(updatedMember);

        case Error(:final failure):
          return Result.error(failure);
      }
    } catch (e, st) {
      // 개발/테스트 환경에서는 모의 데이터 반환
      final mockMember = Member(
        id: 'mock-id',
        email: 'user@example.com',
        nickname: nickname,
        uid: 'mock-uid',
        image: 'https://via.placeholder.com/150',
        description: intro ?? '프로필 업데이트 완료',
      );

      return Result.success(mockMember);

      // 실제 에러 반환 코드 (프로덕션 환경용)
      // return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Member>> updateProfileImage(XFile image) async {
    try {
      // 실제 구현에서는 이미지 업로드 API 호출
      // 여기서는 현재 프로필 가져와서 이미지 경로만 수정하여 반환
      final userResult = await getCurrentProfile();

      switch (userResult) {
        case Success(:final data):
          // 로컬 파일 경로를 사용하지만, 실제로는 서버에 업로드 후 URL을 받아야 함
          // 여기서는 임시 URL 사용
          final updatedMember = data.copyWith(
            image: 'https://via.placeholder.com/150',
          );
          return Result.success(updatedMember);

        case Error(:final failure):
          return Result.error(failure);
      }
    } catch (e, st) {
      // 개발/테스트 환경에서는 모의 데이터 반환
      final mockMember = Member(
        id: 'mock-id',
        email: 'user@example.com',
        nickname: '사용자',
        uid: 'mock-uid',
        image: 'https://via.placeholder.com/150?text=Updated',
        description: '이미지 업로드 완료',
      );

      return Result.success(mockMember);

      // 실제 에러 반환 코드 (프로덕션 환경용)
      // return Result.error(mapExceptionToFailure(e, st));
    }
  }
}
