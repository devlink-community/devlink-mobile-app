import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';

@freezed
class Member with _$Member {
  const Member({
    required this.id,
    required this.email,
    required this.nickname,
    required this.uid,
    this.image = "",
    this.onAir = false,
    this.agreedTermsId, // 동의한 약관 ID (단일 ID)
    this.description = "",
    this.streakDays = 0,
  });

  final String id;
  final String email;
  final String nickname;
  final String uid;
  final String image;
  final bool onAir;
  final String? agreedTermsId; // 약관 동의 ID (하나만 저장)
  final String description;
  final int streakDays;
}
