// lib/auth/data/dto/user_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  const UserDto({
    this.id,
    this.email,
    this.nickname,
    this.uid,
    this.agreedTermsId, // 약관 동의 ID 추가
  });

  final String? id;
  final String? email;
  final String? nickname;
  final String? uid;
  final String? agreedTermsId; // 약관 동의 ID 추가

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}