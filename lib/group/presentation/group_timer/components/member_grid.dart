import 'package:devlink_mobile_app/group/domain/model/member_timer.dart';
import 'package:devlink_mobile_app/group/presentation/group_timer/components/member_timer_item.dart';
import 'package:flutter/material.dart';

class MemberGrid extends StatelessWidget {
  final List<MemberTimer> members;
  final Function(String) onMemberTap;

  const MemberGrid({
    super.key,
    required this.members,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        // 화면 너비에 따라 적절한 열 수 계산 (3~6 사이)
        // final int crossAxisCount = (maxWidth / 90).floor().clamp(3, 6);
        const int crossAxisCount = 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return GestureDetector(
              onTap: () => onMemberTap(member.memberId),
              child: Column(
                children: [
                  // MemberTimerItem은 이미 Column을 사용하지만,
                  // 여기서는 확장과 이름 표시를 위해 다시 Column으로 감싸고 있습니다.
                  Expanded(
                    child: MemberTimerItem(
                      imageUrl: member.imageUrl,
                      status: member.status,
                      timeDisplay: member.timeDisplay,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '이용자${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
