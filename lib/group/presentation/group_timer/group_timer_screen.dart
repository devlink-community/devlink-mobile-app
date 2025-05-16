import 'package:devlink_mobile_app/core/component/app_image.dart';
import 'package:devlink_mobile_app/core/styles/app_color_styles.dart';
import 'package:devlink_mobile_app/core/styles/app_text_styles.dart';
import 'package:devlink_mobile_app/group/domain/model/member_timer.dart';
import 'package:devlink_mobile_app/group/domain/model/member_timer_status.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/components/gradient_wave_animation.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/components/member_grid.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/components/member_section_header.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/components/member_skeleton.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/components/timer_display.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/group_timer_action.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/group_timer_state.dart';
import 'package:flutter/material.dart';

class GroupTimerScreen extends StatefulWidget {
  const GroupTimerScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  final GroupTimerState state;
  final void Function(GroupTimerAction action) onAction;

  @override
  State<GroupTimerScreen> createState() => _GroupTimerScreenState();
}

class _GroupTimerScreenState extends State<GroupTimerScreen> {
  late ScrollController _scrollController;
  bool _isTimerVisible = true;
  bool _isMessageExpanded = false; // 메시지 펼치기/접기 상태

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 멤버 이미지 URLs 수집
    final List<String> imageUrls = [];
    for (final member in widget.state.memberTimers) {
      if (member.imageUrl.isNotEmpty) {
        imageUrls.add(member.imageUrl);
      }
    }

    // 이미지 사전 캐싱
    if (imageUrls.isNotEmpty) {
      AppImage.precacheImages(imageUrls, context);
    }
  }

  void _onScroll() {
    // 스크롤 위치에 따라 타이머 가시성 상태 업데이트
    final double timerThreshold = 220; // 타이머 영역 높이
    final isTimerCurrentlyVisible = _scrollController.offset < timerThreshold;

    if (isTimerCurrentlyVisible != _isTimerVisible) {
      setState(() {
        _isTimerVisible = isTimerCurrentlyVisible;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = widget.state.timerStatus == TimerStatus.running;

    // 상태에 따른 배경색 결정
    final Color primaryBgColor =
        isRunning ? const Color(0xFF8080FF) : const Color(0xFFCDCDFF);
    final Color secondaryBgColor =
        isRunning ? const Color(0xFF7070EE) : const Color(0xFFE6E6FA);

    return Scaffold(
      backgroundColor: Colors.white,
      // 앱바를 포함한 상단 영역을 집중시간 배경으로 통일
      appBar: _buildAppBar(primaryBgColor),
      body: Stack(
        children: [
          // 메인 콘텐츠
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 집중시간 영역 (그라데이션 배경)
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryBgColor, secondaryBgColor],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 그라데이션 물결 애니메이션 배경
                      if (isRunning)
                        GradientWaveAnimation(
                          primaryColor: primaryBgColor,
                          secondaryColor: secondaryBgColor,
                        ),

                      // 타이머 콘텐츠
                      Column(
                        children: [
                          _buildHeader(), // 상단 정보 영역
                          // 타이머 영역 - 분리된 컴포넌트 사용
                          TimerDisplay(
                            elapsedSeconds: widget.state.elapsedSeconds,
                            timerStatus: widget.state.timerStatus,
                            onToggle:
                                () => widget.onAction(
                                  const GroupTimerAction.toggleTimer(),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 메시지 영역 (해시태그 포함)
              SliverToBoxAdapter(child: _buildMessage()),

              // 멤버 섹션 헤더
              SliverToBoxAdapter(child: _buildMemberSectionHeader()),

              // 활성 멤버 섹션
              _buildMemberSection(
                title: '활성 멤버',
                color: const Color(0xFF4CAF50),
                icon: Icons.check_circle,
                members: _getActiveMembers(),
                isLoading:
                    //widget.state.isLoading ||
                    widget
                        .state
                        .memberTimers
                        .isEmpty, // 로딩 상태 또는 멤버가 없을 때 로딩 표시
              ),

              // 휴식 중인 멤버 섹션
              _buildMemberSection(
                title: '휴식 중인 멤버',
                color: Colors.grey,
                icon: Icons.nightlight,
                members: _getInactiveMembers(),
                isLoading:
                    // widget.state.isLoading ||
                    widget
                        .state
                        .memberTimers
                        .isEmpty, // 로딩 상태 또는 멤버가 없을 때 로딩 표시
              ),

              // 바닥 여백
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),

          // 플로팅 타이머
          _buildFloatingTimerContainer(),
        ],
      ),
    );
  }

  // 앱바 위젯
  PreferredSizeWidget _buildAppBar(Color backgroundColor) {
    return AppBar(
      title: Text(
        widget.state.groupName,
        style: AppTextStyles.heading6Bold.copyWith(color: Colors.white),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundColor,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed:
              () =>
                  widget.onAction(const GroupTimerAction.navigateToSettings()),
        ),
      ],
    );
  }

  // 멤버 섹션 헤더 위젯
  Widget _buildMemberSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColorStyles.primary100,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '함께 공부 중인 멤버 (${widget.state.participantCount}/${widget.state.totalMemberCount})',
            style: AppTextStyles.subtitle1Bold.copyWith(
              color: AppColorStyles.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // 플로팅 타이머 컨테이너
  Widget _buildFloatingTimerContainer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: _isTimerVisible ? -80 : 0,
      // 보이지 않을 때는 위로 숨김
      left: 0,
      right: 0,
      height: 56,
      // 높이를 명시적으로 지정
      child: Material(
        elevation: 4,
        color: Colors.transparent,
        child: TimerDisplay(
          elapsedSeconds: widget.state.elapsedSeconds,
          timerStatus: widget.state.timerStatus,
          onToggle: () => widget.onAction(const GroupTimerAction.toggleTimer()),
          isCompact: true, // 작은 디스플레이 모드
        ),
      ),
    );
  }

  // 멤버 섹션 (헤더 + 그리드)
  Widget _buildMemberSection({
    required String title,
    required Color color,
    required IconData icon,
    required List<MemberTimer> members,
    bool isLoading = false, // 로딩 상태 파라미터 추가
  }) {
    // 로딩 중이면서 멤버가 없는 경우 스켈레톤 UI 표시
    if (isLoading && members.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 섹션 헤더 - 분리된 컴포넌트 사용
              MemberSectionHeader(title: title, color: color, icon: icon),

              // 스켈레톤 UI 표시
              const MemberSkeleton(count: 3),
            ],
          ),
        ),
      );
    }

    // 멤버가 없는 경우 빈 공간 반환
    if (members.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더 - 분리된 컴포넌트 사용
            MemberSectionHeader(title: title, color: color, icon: icon),

            // 멤버 그리드 - 분리된 컴포넌트 사용
            MemberGrid(
              members: members,
              onMemberTap:
                  (memberId) => widget.onAction(
                    GroupTimerAction.navigateToUserProfile(memberId),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // 활성 멤버 가져오기
  List<MemberTimer> _getActiveMembers() {
    return widget.state.memberTimers
        .where((m) => m.status == MemberTimerStatus.active)
        .toList();
  }

  // 비활성 멤버 가져오기
  List<MemberTimer> _getInactiveMembers() {
    return widget.state.memberTimers
        .where((m) => m.status != MemberTimerStatus.active)
        .toList();
  }

  // 상단 정보 영역 (참여자 수, 날짜)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${widget.state.participantCount} / ${widget.state.totalMemberCount}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap:
                () => widget.onAction(
                  const GroupTimerAction.navigateToAttendance(),
                ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorStyles.gray40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 - 아이콘과 타이틀, 토글 버튼
          GestureDetector(
            onTap: () {
              setState(() {
                _isMessageExpanded = !_isMessageExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: AppColorStyles.gray100,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '그룹 메시지',
                      style: AppTextStyles.body2Regular.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColorStyles.gray100,
                      ),
                    ),
                  ],
                ),
                // 확장/축소 아이콘
                Icon(
                  _isMessageExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 22,
                  color: AppColorStyles.gray100,
                ),
              ],
            ),
          ),

          // 메시지 내용 - 확장 시에만 표시
          if (_isMessageExpanded) ...[
            const SizedBox(height: 8),
            Text(
              '안녕하세요. 저희는 소금빵을 먹으며 공부하는 소막입니다.\n'
              '다들 소금빵 좋아하시나요?\n'
              '한 줄이라도 코드를 나가주세요.',
              style: AppTextStyles.body1Regular.copyWith(
                height: 1.4,
                color: AppColorStyles.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // 해시태그
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.state.hashTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorStyles.primary60.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTextStyles.captionRegular.copyWith(
                          color: AppColorStyles.primary100,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
