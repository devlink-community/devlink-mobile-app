import 'package:devlink_mobile_app/auth/data/data_source/mock_auth_data_source.dart';
import 'package:devlink_mobile_app/auth/data/mapper/member_mapper.dart';
import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import 'package:devlink_mobile_app/intro/data/mapper/focus_time_stats_dto_mapper.dart';

import '../../../auth/data/data_source/mock_profile_data_source.dart';
import '../../../core/result/result.dart';
import '../../domain/model/focus_time_stats.dart';
import '../../domain/repository/intro_repository.dart';
import '../data_source/mock_focus_time_data_source_impl.dart';

class IntroRepositoryImpl implements IntroRepository {
  final MockAuthDataSource _authDs;
  final MockProfileDataSource _profileDs;
  final MockFocusTimeDataSourceImpl _focusDs;

  IntroRepositoryImpl({
    required MockAuthDataSource authDataSource,
    required MockProfileDataSource profileDataSource,
    required MockFocusTimeDataSourceImpl focusDataSource,
  }) : _authDs = authDataSource,
       _profileDs = profileDataSource,
       _focusDs = focusDataSource;

  @override
  Future<Result<Member>> fetchIntroUser() async {
    try {
      // 1) AuthDataSource로부터 Map<String,dynamic>? 가져오기
      final authMap = await _authDs.fetchCurrentUser();
      if (authMap == null) {
        throw Exception('No user logged in');
      }

      // 2) Map → UserDto
      final authDto = authMap.toUserDto();

      // 3) ProfileDataSource로부터 Profile Map 가져오기
      final profileMap = await _profileDs.fetchUserProfile(authDto.id!);
      // 4) Map → ProfileDto
      final profileDto = profileMap.toProfileDto();

      // 5) UserDto + ProfileDto → Member
      final member = authDto.toModelFromProfile(profileDto);

      return Result.success(member);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<FocusTimeStats>> fetchFocusTimeStats() async {
    try {
      final dto = await _focusDs.fetchFocusTimeStats();
      final model = dto.toModel();
      return Result.success(model);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }
}
