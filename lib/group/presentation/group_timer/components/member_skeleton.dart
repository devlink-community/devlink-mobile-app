// lib/group/presentation/group_timer/components/member_skeleton.dart
import 'package:flutter/material.dart';

/// 멤버 그리드에 사용되는 스켈레톤 UI 컴포넌트
/// 멤버 데이터 로딩 중 표시되는 로딩 플레이스홀더
class MemberSkeleton extends StatelessWidget {
  /// 표시할 스켈레톤 아이템 개수
  final int count;

  /// 그리드의 열 개수
  final int crossAxisCount;

  /// 스켈레톤 아이템 간 가로 간격
  final double crossAxisSpacing;

  /// 스켈레톤 아이템 간 세로 간격
  final double mainAxisSpacing;

  /// 애니메이션 효과 적용 여부
  final bool withAnimation;

  const MemberSkeleton({
    super.key,
    this.count = 3, // 기본 스켈레톤 아이템 개수
    this.crossAxisCount = 3, // 기본 열 개수
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 16,
    this.withAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return _buildSkeletonItem();
      },
    );
  }

  /// 스켈레톤 아이템 위젯 생성
  Widget _buildSkeletonItem() {
    // 애니메이션 효과가 필요한 경우 적용
    final Widget skeleton = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 원형 프로필 이미지 플레이스홀더
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade300,
          ),
        ),

        const SizedBox(height: 4),

        // 타이머 디스플레이 플레이스홀더
        Container(
          width: 40,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        const SizedBox(height: 4),

        // 이름 텍스트 플레이스홀더
        Container(
          width: 40,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );

    // 애니메이션 적용 여부에 따라 반환
    if (withAnimation) {
      return _SkeletonAnimation(child: skeleton);
    } else {
      return skeleton;
    }
  }
}

/// 스켈레톤 UI에 애니메이션 효과를 적용하는 래퍼 위젯
class _SkeletonAnimation extends StatefulWidget {
  final Widget child;

  const _SkeletonAnimation({required this.child});

  @override
  _SkeletonAnimationState createState() => _SkeletonAnimationState();
}

class _SkeletonAnimationState extends State<_SkeletonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // 애니메이션 커브 설정
    _animation = Tween<double>(
      begin: 0.4,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: widget.child);
      },
    );
  }
}
