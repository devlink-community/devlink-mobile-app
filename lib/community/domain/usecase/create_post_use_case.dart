// lib/community/domain/usecase/create_post_use_case.dart
import 'package:devlink_mobile_app/community/domain/model/post.dart';
import 'package:devlink_mobile_app/community/domain/repository/post_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 게시글 작성 요청
class CreatePostUseCase {
  CreatePostUseCase({required PostRepository repo}) : _repo = repo;
  final PostRepository _repo;

  /// AsyncValue<String>으로 반환하도록 수정
  Future<AsyncValue<String>> execute({
    required String title,
    required String content,
    required List<String> hashTags,
    required List<Uri> imageUris,
  }) async {
    try {
      final postId = await _repo.createPost(
        title: title,
        content: content,
        hashTags: hashTags,
        imageUris: imageUris,
      );
      return AsyncData(postId);
    } catch (e, stackTrace) {
      return AsyncError(e, stackTrace);
    }
  }
}
