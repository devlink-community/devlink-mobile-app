import 'package:flutter/material.dart';

import '../styles/app_color_styles.dart';
import '../styles/app_text_styles.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String? profileImageUrl;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 구분선
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.withOpacity(0.2),
          ),
          // 내비게이션 바
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined),
                  _buildNavItem(1, Icons.chat_bubble_outline),
                  _buildNavItem(2, Icons.people_outline),
                  _buildNavItem(3, Icons.notifications_none),
                  _buildProfileItem(4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        color: isSelected ? AppColorStyles.primary100 : Colors.grey,
        size: 26, // 텍스트가 없어서 아이콘 크기를 약간 키웠습니다
      ),
    );
  }

  Widget _buildProfileItem(int index) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        width: 26, // 다른 아이콘과 크기 맞춤
        height: 26, // 다른 아이콘과 크기 맞춤
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColorStyles.primary100 : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 11,
          backgroundImage: NetworkImage(
            profileImageUrl ?? 'https://via.placeholder.com/150',
          ),
          backgroundColor: Colors.grey.shade200,
        ),
      ),
    );
  }
}
