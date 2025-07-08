import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_dialog.dart';
import '../viewmodels/card_group_viewmodel.dart';
import '../screens/group_manager_page.dart';
import '../enums/view_mode.dart';

class CardGroupAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CardGroupAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CardGroupViewModel>();
    final filteredCards = vm.filteredCards;

    return AppBar(
      title: vm.isSelectionMode
          ? Text('已選 ${vm.selectedCardIds.length} 筆')
          : const Text('名片群組'),
      backgroundColor: const Color(0xFF4A6CFF),
      actions: vm.isSelectionMode
          ? [
              IconButton(
                icon: Icon(
                  vm.selectedCardIds.length == filteredCards.length
                      ? Icons.check_box_outline_blank
                      : Icons.select_all,
                ),
                tooltip: vm.selectedCardIds.length == filteredCards.length
                    ? '取消全選'
                    : '全選',
                onPressed: () {
                  if (vm.selectedCardIds.length == filteredCards.length) {
                    vm.clearSelection();
                  } else {
                    for (final card in filteredCards) {
                      vm.toggleCardSelection(card.id);
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: '刪除選取',
                onPressed: () {
                  if (vm.selectedCardIds.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('請先選取要刪除的名片')));
                    return;
                  }

                  showAppDialog(
                    context: context,
                    type: AppDialogType.confirm,
                    title: '確認刪除',
                    message: '你確定要刪除 ${vm.selectedCardIds.length} 筆名片嗎？',
                    onConfirm: () async {
                      await vm.deleteSelectedCards(); // ✅ 關鍵這行
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已從群組移除選取名片')),
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.group_add),
                tooltip: '加入群組',
                onPressed: () {
                  final groups = vm.groups
                      .where((g) => g.name != '全部')
                      .toList();

                  showAppDialog(
                    context: context,
                    type: AppDialogType.selectList,
                    title: '加入群組',
                    options: groups.map((g) => g.name).toList(),
                    onOptionSelected: (groupName) async {
                      final group = groups.firstWhere(
                        (g) => g.name == groupName,
                      );

                      await vm.assignGroupToSelectedByGroup(group); // 多選加入群組
                      await vm.loadCards(); // 更新列表
                      final count = vm.selectedCardIds.length;
                      vm.clearSelection();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已加入 $count 筆名片至「${group.name}」群組'),
                        ),
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: '取消選取',
                onPressed: vm.clearSelection,
              ),
            ]
          : [
              IconButton(
                icon: Icon(
                  vm.viewMode == ViewMode.card
                      ? Icons.view_list
                      : Icons.grid_view,
                ),
                tooltip: '切換檢視模式',
                onPressed: vm.toggleViewMode,
              ),
              IconButton(
                icon: const Icon(Icons.select_all),
                tooltip: '多選模式',
                onPressed: vm.toggleSelectionMode,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                tooltip: '群組管理',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GroupManagerPage()),
                  );
                  await vm.loadGroups(); // 回來後刷新 CardGroup 的群組
                },
              ),
            ],
    );
  }
}
