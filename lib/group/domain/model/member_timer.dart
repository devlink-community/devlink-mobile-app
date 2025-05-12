import 'package:devlink_mobile_app/group/domain/model/member_timer_status.dart';

class MemberTimer {
  final String memberId;
  final String memberName;
  final String imageUrl;
  final int elapsedSeconds;
  final MemberTimerStatus status;

  MemberTimer({
    required this.memberId,
    required this.memberName,
    required this.imageUrl,
    required this.elapsedSeconds,
    required this.status,
  });

  // 시간 표시 문자열 (hh:mm:ss)
  String get timeDisplay {
    if (status == MemberTimerStatus.sleeping) return 'zzz';

    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
