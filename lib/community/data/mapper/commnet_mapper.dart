// lib/community/data/mapper/comment_mapper.dart
import 'package:devlink_mobile_app/community/data/dto/comment_dto.dart';
import 'package:devlink_mobile_app/community/domain/model/comment.dart';

extension CommentDtoMapper on CommentDto {
  Comment toModel() => Comment(
        boardId: boardId ?? '',
        memberId: memberId ?? '',
        createdAt: createdAt ?? DateTime.now(),
        content: content ?? '',
      );
}

extension CommentDtoListX on List<CommentDto> {
  List<Comment> toModelList() => map((e) => e.toModel()).toList();
}
