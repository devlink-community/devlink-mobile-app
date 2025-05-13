// lib/community/presentation/community_detail/widget/comment_item.dart
import 'package:devlink_mobile_app/community/domain/model/comment.dart';
import 'package:flutter/material.dart';


class CommentItem extends StatelessWidget {
  const CommentItem({super.key, required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const CircleAvatar(radius: 18),
        title: Text('테스트 유저', style: const TextStyle(fontSize: 14)),
        subtitle: Text(comment.content),
        trailing: Text(
          '${comment.createdAt.year}-${comment.createdAt.month.toString().padLeft(2, '0')}-${comment.createdAt.day.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
}
