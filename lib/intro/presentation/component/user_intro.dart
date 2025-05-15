import 'dart:io';

import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:flutter/material.dart';

import '../../../auth/domain/model/member.dart';
import '../../../core/styles/app_text_styles.dart';

class ProfileInfo extends StatelessWidget {
  final Member member;

  const ProfileInfo({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 프로필 사진
              Container(
                width: 72, // radius 36 * 2
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3), // 그림자 위치 조정
                    ),
                  ],
                ),
                child: _buildProfileImage(),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.nickname, style: AppTextStyles.heading6Bold),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: AppColorStyles.primary100,
                        size: 30,
                      ),
                      const SizedBox(width: 4),
                      // Member 모델에 streakDays 필드가 없다면 원하는 텍스트로 바꿔 주세요
                      Text(
                        '${member.streakDays} Day',
                        style: AppTextStyles.heading6Regular,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 소개글
          if (member.description.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(
              member.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              softWrap: true, // 자동 줄바꿈 허용
              overflow: TextOverflow.visible, // 넘치는 텍스트도 보이게
              textAlign: TextAlign.start, // 정렬은 왼쪽
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // 이미지 경로가 있는지 확인
    if (member.image.isEmpty) {
      // 기본 아이콘 표시
      return CircleAvatar(
        radius: 36,
        backgroundColor: Colors.grey.shade200,
        child: Icon(Icons.person, size: 36, color: Colors.grey.shade400),
      );
    }

    // 이미지가 File 형식인지 확인 (로컬 이미지인 경우)
    if (member.image.startsWith('/')) {
      // 로컬 파일 경로인 경우
      return CircleAvatar(
        radius: 36,
        backgroundImage: FileImage(File(member.image)),
        backgroundColor: Colors.grey.shade200,
        onBackgroundImageError: (exception, stackTrace) {
          // 이미지 로딩 오류 시 처리
          debugPrint('이미지 로딩 오류: $exception');
          return;
        },
      );
    }

    // 네트워크 이미지인 경우
    return CircleAvatar(
      radius: 36,
      backgroundImage: NetworkImage(member.image),
      backgroundColor: Colors.grey.shade200,
      onBackgroundImageError: (exception, stackTrace) {
        // 이미지 로딩 오류 시 처리
        debugPrint('이미지 로딩 오류: $exception');
        return;
      },
    );
  }
}
