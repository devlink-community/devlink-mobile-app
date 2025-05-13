import 'package:freezed_annotation/freezed_annotation.dart';

part 'intro_action.freezed.dart';

@freezed
sealed class IntroAction with _$IntroAction {
  /// 톱니바퀴(설정) 아이콘 클릭
  const factory IntroAction.openSettings() = OpenSettings;

  /// 데이터 새로고침
  const factory IntroAction.refresh() = RefreshIntro;
}
