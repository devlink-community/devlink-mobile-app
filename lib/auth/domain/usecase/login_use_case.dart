// lib/auth/domain/usecase/login_use_case.dart
import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:devlink_mobile_app/auth/domain/repository/auth_repository.dart';
import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase({required AuthRepository repository}) : _repository = repository;

  Future<AsyncValue<Member>> execute({
    required String email,
    required String password,
  }) async {
    // UseCase에서는 이메일 주소를 그대로 전달
    // 이메일 주소의 대소문자 정규화(소문자 변환)는 Repository/DataSource 레벨에서 처리
    final result = await _repository.login(email: email, password: password);

    switch (result) {
      case Success(data: final user):
        return AsyncData(user);
      case Error(failure: final error):
        return AsyncError(error, error.stackTrace ?? StackTrace.current);
    }
  }
}