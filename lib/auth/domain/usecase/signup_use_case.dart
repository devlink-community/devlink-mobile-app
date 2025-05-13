// lib/auth/domain/usecase/signup_use_case.dart
import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:devlink_mobile_app/auth/domain/repository/auth_repository.dart';
import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignupUseCase {
  final AuthRepository _repository;

  SignupUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<AsyncValue<Member>> execute({
    required String email,
    required String password,
    required String nickname,
    String? agreedTermsId, // 약관 동의 ID 추가
  }) async {
    // 필수 약관 동의 여부 확인 (약관 ID가 null이면 약관 동의를 하지 않은 것으로 간주)
    if (agreedTermsId == null) {
      return AsyncError(
        Failure(
          FailureType.validation,
          '필수 약관에 동의해야 합니다',
        ),
        StackTrace.current,
      );
    }

    // UseCase에서는 이메일을 그대로 전달
    // 이메일 주소의 대소문자 정규화(소문자 변환)는 Repository/DataSource 레벨에서 처리
    final result = await _repository.signup(
      email: email,
      password: password,
      nickname: nickname,
      agreedTermsId: agreedTermsId, // 약관 동의 ID 전달
    );

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(failure: final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}