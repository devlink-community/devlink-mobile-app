// lib/auth/data/repository_impl/auth_repository_impl.dart
import 'package:devlink_mobile_app/auth/data/data_source/auth_data_source.dart';
import 'package:devlink_mobile_app/auth/data/data_source/profile_data_source.dart';
import 'package:devlink_mobile_app/auth/data/dto/profile_dto.dart';
import 'package:devlink_mobile_app/auth/data/dto/user_dto.dart';
import 'package:devlink_mobile_app/auth/data/mapper/member_mapper.dart';
import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:devlink_mobile_app/auth/domain/model/terms_agreement.dart';
import 'package:devlink_mobile_app/auth/domain/repository/auth_repository.dart';
import 'package:devlink_mobile_app/core/result/result.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용을 위함

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;
  final ProfileDataSource _profileDataSource;

  AuthRepositoryImpl({
    required AuthDataSource authDataSource,
    required profileDataSource,
  }) : _authDataSource = authDataSource,
       _profileDataSource = profileDataSource;

  @override
  Future<Result<Member>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Repository에서는 이메일을 그대로 전달
      // DataSource 레벨에서 이메일을 소문자로 변환하여 처리
      final response = await _authDataSource.fetchLogin(
        email: email,
        password: password,
      );
      final userDto = UserDto.fromJson(response);

      // 프로필 정보 가져오기
      final profileResponse = await _profileDataSource.fetchUserProfile(
        userDto.id!,
      );
      final profileDto = ProfileDto.fromJson(profileResponse);

      // DTO 병합 후 Member 모델로 변환
      final member = userDto.toModelFromProfile(profileDto);

      // response를 UserDto로 변환 후 Model로 변환
      return Result.success(member);
    } catch (e, st) {
      // 디버깅용 로그
      debugPrint('Login error: $e');
      debugPrint('StackTrace: $st');

      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Member>> signup({
    required String email,
    required String password,
    required String nickname,
    String? agreedTermsId,
  }) async {
    try {
      // Repository에서는 이메일을 그대로 전달
      // DataSource 레벨에서 이메일을 소문자로 변환하여 저장
      final response = await _authDataSource.createUser(
        email: email,
        password: password,
        nickname: nickname,
        agreedTermsId: agreedTermsId,
      );
      final user = response.toUserDto().toModel();
      return Result.success(user);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Member?>> getCurrentUser() async {
    try {
      final response = await _authDataSource.fetchCurrentUser();
      if (response == null) {
        return const Result.success(null);
      }
      final user = response.toUserDto().toModel();
      return Result.success(user);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authDataSource.signOut();
      return const Result.success(null);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<bool>> checkNicknameAvailability(String nickname) async {
    try {
      final isAvailable = await _authDataSource.checkNicknameAvailability(
        nickname,
      );
      return Result.success(isAvailable);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<bool>> checkEmailAvailability(String email) async {
    try {
      // Repository에서는 이메일을 그대로 전달
      // DataSource 레벨에서 이메일을 소문자로 변환하여 확인
      final isAvailable = await _authDataSource.checkEmailAvailability(email);
      return Result.success(isAvailable);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      // Repository에서는 이메일을 그대로 전달
      // DataSource 레벨에서 이메일을 소문자로 변환하여 처리
      await _authDataSource.sendPasswordResetEmail(email);
      return const Result.success(null);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String email) async {
    try {
      // Repository에서는 이메일을 그대로 전달
      // DataSource 레벨에서 이메일을 소문자로 변환하여 처리
      await _authDataSource.deleteAccount(email);
      return const Result.success(null);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<TermsAgreement?>> getTermsInfo(String? termsId) async {
    try {
      // termsId가 없으면 기본 약관 정보 반환
      if (termsId == null) {
        final response = await _authDataSource.fetchTermsInfo();
        final termsAgreement = TermsAgreement(
          id: response['id'] as String,
          isAllAgreed: false,
          isServiceTermsAgreed: false,
          isPrivacyPolicyAgreed: false,
          isMarketingAgreed: false,
        );
        return Result.success(termsAgreement);
      }

      // termsId가 있으면 해당 약관 정보 조회
      final response = await _authDataSource.getTermsInfo(termsId);
      if (response == null) {
        return const Result.success(null);
      }

      final termsAgreement = TermsAgreement(
        id: response['id'] as String,
        isAllAgreed: response['isAllAgreed'] as bool? ?? false,
        isServiceTermsAgreed:
            response['isServiceTermsAgreed'] as bool? ?? false,
        isPrivacyPolicyAgreed:
            response['isPrivacyPolicyAgreed'] as bool? ?? false,
        isMarketingAgreed: response['isMarketingAgreed'] as bool? ?? false,
        agreedAt:
            response['agreedAt'] != null
                ? DateTime.parse(response['agreedAt'] as String)
                : null,
      );
      return Result.success(termsAgreement);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<TermsAgreement>> saveTermsAgreement(
    TermsAgreement terms,
  ) async {
    try {
      final Map<String, dynamic> termsData = {
        'id': terms.id,
        'isAllAgreed': terms.isAllAgreed,
        'isServiceTermsAgreed': terms.isServiceTermsAgreed,
        'isPrivacyPolicyAgreed': terms.isPrivacyPolicyAgreed,
        'isMarketingAgreed': terms.isMarketingAgreed,
        'agreedAt':
            terms.agreedAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      };

      final response = await _authDataSource.saveTermsAgreement(termsData);

      return Result.success(
        TermsAgreement(
          id: response['id'] as String,
          isAllAgreed: response['isAllAgreed'] as bool,
          isServiceTermsAgreed: response['isServiceTermsAgreed'] as bool,
          isPrivacyPolicyAgreed: response['isPrivacyPolicyAgreed'] as bool,
          isMarketingAgreed: response['isMarketingAgreed'] as bool,
          agreedAt:
              response['agreedAt'] != null
                  ? DateTime.parse(response['agreedAt'] as String)
                  : null,
        ),
      );
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }
}
