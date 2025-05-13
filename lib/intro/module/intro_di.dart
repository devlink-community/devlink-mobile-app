import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth/data/data_source/mock_auth_data_source.dart';
import '../../auth/data/data_source/mock_profile_data_source.dart';
import '../data/data_source/mock_focus_time_data_source_impl.dart';
import '../data/repository_impl/intro_repository_impl.dart';
import '../domain/repository/intro_repository.dart';
import '../domain/use_case/fetch_intro_data_use_case.dart';
import '../domain/use_case/fetch_intro_stats_use_case.dart';

/// DataSource Providers
final authDataSourceProvider = Provider<MockAuthDataSource>(
  (ref) => MockAuthDataSource(),
);
final profileDataSourceProvider = Provider<MockProfileDataSource>(
  (ref) => MockProfileDataSource(),
);
final focusTimeDataSourceProvider = Provider<MockFocusTimeDataSourceImpl>(
  (ref) => MockFocusTimeDataSourceImpl(),
);

/// Repository Provider
final introRepositoryProvider = Provider<IntroRepository>((ref) {
  final authDs = ref.watch(authDataSourceProvider);
  final profileDs = ref.watch(profileDataSourceProvider);
  final focusDs = ref.watch(focusTimeDataSourceProvider);

  return IntroRepositoryImpl(
    authDataSource: authDs,
    profileDataSource: profileDs,
    focusDataSource: focusDs,
  );
});

/// UseCase Providers
final fetchIntroUserUseCaseProvider = Provider<FetchIntroUserUseCase>(
  (ref) => FetchIntroUserUseCase(ref.watch(introRepositoryProvider)),
);

final fetchIntroStatsUseCaseProvider = Provider<FetchIntroStatsUseCase>(
  (ref) => FetchIntroStatsUseCase(ref.watch(introRepositoryProvider)),
);
