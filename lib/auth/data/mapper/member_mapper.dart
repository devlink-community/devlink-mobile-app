import 'package:devlink_mobile_app/auth/data/dto/profile_dto.dart';
import 'package:devlink_mobile_app/auth/data/dto/user_dto.dart';
import 'package:devlink_mobile_app/auth/domain/model/member.dart';

// UserDto → Member 변환
extension UserDtoToMemberMapper on UserDto {
  Member toModel() {
    return Member(
      id: id ?? '',
      email: email ?? '',
      nickname: nickname ?? '',
      onAir: false,
      image: '',
      uid: '',
      description: '',
    );
  }
}

// Member → UserDto 변환
extension MemberToUserDtoMapper on Member {
  UserDto toDto() {
    return UserDto(id: id, email: email, nickname: nickname);
  }
}

// Map → UserDto 변환
extension MapToUserDtoMapper on Map<String, dynamic> {
  UserDto toUserDto() => UserDto.fromJson(this);
}

// Map → ProfileDto 변환
extension MapToProfileDtoMapper on Map<String, dynamic> {
  ProfileDto toProfileDto() => ProfileDto.fromJson(this);
}

// UserDto와 ProfileDto를 병합하여 Member 객체로 변환
extension UserDtoToMemberFromProfileMapper on UserDto {
  Member toModelFromProfile(ProfileDto profileDto) {
    return Member(
      id: id ?? '',
      email: email ?? '',
      nickname: nickname ?? '',
      uid: uid ?? '',
      image: profileDto.image ?? '',
      // 병합된 프로필 이미지
      onAir: profileDto.onAir ?? false,
      // 병합된 onAir 상태
      description: profileDto.description ?? '', // 병합된 description
    );
  }
}
