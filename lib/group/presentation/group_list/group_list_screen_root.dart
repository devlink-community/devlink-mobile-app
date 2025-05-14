import 'package:devlink_mobile_app/group/presentation/group_join_dialog.dart';
import 'package:devlink_mobile_app/group/presentation/group_list/group_list_action.dart';
import 'package:devlink_mobile_app/group/presentation/group_list/group_list_notifier.dart';
import 'package:devlink_mobile_app/group/presentation/group_list/group_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/group.dart';

class GroupListScreenRoot extends ConsumerWidget {
  const GroupListScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupListNotifierProvider);
    final notifier = ref.watch(groupListNotifierProvider.notifier);

    ref.listen(
      groupListNotifierProvider.select((value) => value.selectedGroup),
      (previous, next) {
        if (next is AsyncData && next.value != null) {
          _showGroupDialog(context, next.value!, notifier);
        }
      },
    );

    return GroupListScreen(
      state: state,
      onAction: (action) {
        switch (action) {
          case OnTapSearch():
            context.push('/group/search');
          case OnTapCreateGroup():
            context.push('/group/create');
          case OnCloseDialog():
            Navigator.of(context).pop();
          case OnJoinGroup(:final groupId):
            notifier.onAction(action);
            Navigator.of(context).pop();
            context.push('/group/$groupId');
          default:
            notifier.onAction(action);
        }
      },
    );
  }

  void _showGroupDialog(
    BuildContext context,
    Group group,
    GroupListNotifier notifier,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GroupJoinDialog(
          group: group,
          onAction: (action) {
            if (action is OnJoinGroup) {
              Navigator.of(context).pop();
              notifier.onAction(action);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (context.mounted) {
                  context.push('/group/${(action).groupId}');
                }
              });
            } else {
              notifier.onAction(action);
            }
          },
        );
      },
    );
  }
}
