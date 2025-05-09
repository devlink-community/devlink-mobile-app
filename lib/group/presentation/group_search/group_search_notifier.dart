// lib/group/presentation/group_search/group_search_notifier.dart
import 'package:devlink_mobile_app/group/domain/model/group.dart';
import 'package:devlink_mobile_app/group/domain/usecase/search_groups_use_case.dart';
import 'package:devlink_mobile_app/group/module/group_di.dart';
import 'package:devlink_mobile_app/group/presentation/group_search/group_search_action.dart';
import 'package:devlink_mobile_app/group/presentation/group_search/group_search_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_search_notifier.g.dart';

@riverpod
class GroupSearchNotifier extends _$GroupSearchNotifier {
  late final SearchGroupsUseCase _searchGroupsUseCase;

  @override
  GroupSearchState build() {
    _searchGroupsUseCase = ref.watch(searchGroupsUseCaseProvider);

    // 최근 검색어는 로컬 저장소에서 가져올 수 있지만, 여기서는 간단히 하드코딩
    final recentSearches = ['정보처리기사', '개발자', '스터디'];

    return GroupSearchState(recentSearches: recentSearches);
  }

  Future<void> onAction(GroupSearchAction action) async {
    switch (action) {
      case OnSearch(:final query):
        if (query.trim().isEmpty) return;

        // 1. 쿼리 업데이트
        state = state.copyWith(query: query);

        // 2. 로딩 상태로 변경
        state = state.copyWith(searchResults: const AsyncLoading());

        // 3. 검색 수행
        final results = await _searchGroupsUseCase.execute(query);

        // 4. 결과 반영
        state = state.copyWith(searchResults: results);

        // 5. 최근 검색어에 추가 (맨 앞에 추가)
        if (!state.recentSearches.contains(query)) {
          final updatedRecentSearches = [query, ...state.recentSearches];
          // 최대 5개만 유지
          if (updatedRecentSearches.length > 5) {
            updatedRecentSearches.removeLast();
          }
          state = state.copyWith(recentSearches: updatedRecentSearches);
        } else {
          // 이미 있으면 맨 앞으로 이동 (삭제 후 맨 앞에 추가)
          final updatedRecentSearches = [...state.recentSearches];
          updatedRecentSearches.remove(query);
          updatedRecentSearches.insert(0, query);
          state = state.copyWith(recentSearches: updatedRecentSearches);
        }

      case OnClearSearch():
        state = state.copyWith(
          query: '',
          searchResults: const AsyncValue.data([]),
        );

      case OnTapGroup(:final groupId):
        // Root에서 처리할 네비게이션 액션
        break;

      case OnGoBack():
        break;
      case OnRemoveRecentSearch(:final query):
        final updatedRecentSearches = [...state.recentSearches]..remove(query);
        state = state.copyWith(recentSearches: updatedRecentSearches);

      case OnClearAllRecentSearches():
        state = state.copyWith(recentSearches: []);
    }
  }
}
