// lib/auth/presentation/login/login_notifier.dart
import 'package:devlink_mobile_app/auth/domain/usecase/login_use_case.dart';
import 'package:devlink_mobile_app/auth/module/auth_di.dart';
import 'package:devlink_mobile_app/auth/presentation/login/login_action.dart';
import 'package:devlink_mobile_app/auth/presentation/login/login_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_notifier.g.dart';

@Riverpod(keepAlive: false)
class LoginNotifier extends _$LoginNotifier {
  late final LoginUseCase _loginUseCase;

  @override
  LoginState build() {
    _loginUseCase = ref.watch(loginUseCaseProvider);
    return const LoginState(loginUserResult: null);
  }

  Future<void> onAction(LoginAction action) async {
    switch (action) {
      case LoginPressed(:final email, :final password):
        await _handleLogin(email, password);

      case NavigateToForgetPassword():
      // Root에서 이동 처리 (UI context 이용 → Root 처리 예정)

      case NavigateToSignUp():
      // Root에서 이동 처리 (UI context 이용 → Root 처리 예정)
    }
  }

  Future<void> _handleLogin(String email, String password) async {
    state = state.copyWith(loginUserResult: const AsyncLoading());

    // 이메일 주소는 그대로 전달 - 소문자 변환은 Repository/DataSource 레벨에서 처리
    // 사용자가 입력한 이메일 주소 형식을 UI에서는 유지하고,
    // 로그인 처리 과정에서 소문자로 변환되어 비교됨
    final asyncResult = await _loginUseCase.execute(
      email: email, // 원본 이메일 그대로 전달
      password: password,
    );

    state = state.copyWith(loginUserResult: asyncResult);
  }

  void logout() {
    state = const LoginState();
  }
}