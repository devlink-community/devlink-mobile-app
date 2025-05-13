import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto {
  const ProfileDto({this.userId, this.image, this.onAir, this.description});

  @JsonKey(name: 'id')
  final String? userId;
  final String? image;
  final bool? onAir;
  final String? description;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);
}
