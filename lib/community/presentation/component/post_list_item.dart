import 'package:devlink_mobile_app/community/domain/model/post.dart';
import 'package:flutter/material.dart';


class PostListItem extends StatelessWidget {
  const PostListItem({
    super.key,
    required this.post,
    required this.onTap,
  });

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(post.title),
        subtitle: Text('${post.member.nickname} · ${post.createdAt.toLocal()}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 16),
            const SizedBox(width: 4),
            Text('${post.like.length}'),
          ],
        ),
        onTap: onTap,
      );
}
