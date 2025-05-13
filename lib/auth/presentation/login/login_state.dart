import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const LoginState({this.loginUserResult});

  final AsyncValue<Member>? loginUserResult;
}
