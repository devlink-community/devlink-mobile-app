// lib/auth/domain/repository/auth_repository.dart
import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:devlink_mobile_app/auth/domain/model/terms_agreement.dart';
import 'package:devlink_mobile_app/core/result/result.dart';

abstract interface class AuthRepository {
  /// 이메일, 비밀번호로 로그인
  Future<Result<Member>> login({
    required String email,
    required String password,
  });

  /// 이메일, 비밀번호, 닉네임으로 회원가입 (약관 ID 추가)
  Future<Result<Member>> signup({
    required String email,
    required String password,
    required String nickname,
    String? agreedTermsId, // 약관 동의 ID 추가
  });

  /// 현재 로그인된 유저 조회
  Future<Result<Member?>> getCurrentUser();

  /// 로그아웃
  Future<Result<void>> signOut();

  /// 닉네임 중복 확인 (true: 사용 가능, false: 중복)
  Future<Result<bool>> checkNicknameAvailability(String nickname);

  /// 이메일 중복 확인 (true: 사용 가능, false: 중복)
  Future<Result<bool>> checkEmailAvailability(String email);

  /// 비밀번호 재설정 이메일 발송
  Future<Result<void>> resetPassword(String email);

  /// 계정삭제
  Future<Result<void>> deleteAccount(String email);

  /// 약관 동의 정보 저장
  Future<Result<TermsAgreement>> saveTermsAgreement(
    TermsAgreement termsAgreement,
  );

  /// 약관 정보 조회
  Future<Result<TermsAgreement?>> getTermsInfo(String? termsId);
}
