import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/card_group_viewmodel.dart';
import '../widgets/unified_card_item.dart';
import '../utils/qr_share_utils.dart';
import '../utils/app_dialog.dart';

class CardGroupList extends StatelessWidget {
  const CardGroupList({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CardGroupViewModel>();
    final cards = vm.filteredCards;

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.all(12),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Container(
          key: ValueKey(card.id),
          margin: const EdgeInsets.only(bottom: 12),
          child: UnifiedCardItem(
            card: card,
            viewMode: vm.viewMode,
            isSelectionMode: vm.isSelectionMode,
            isSelected: vm.selectedCardIds.contains(card.id),
            onSelected: (selected) => vm.toggleCardSelection(card.id),
            onTap: () {
              if (vm.isSelectionMode) {
                vm.toggleCardSelection(card.id);
              } else {
                Navigator.pushNamed(context, '/cardDetail', arguments: card);
              }
            },
            onDelete: () {
              vm.deleteCard(card.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${card.name} 已從群組移除'),
                  action: SnackBarAction(
                    label: '復原',
                    textColor: Colors.green,
                    onPressed: () => vm.restoreCard(card),
                  ),
                ),
              );
            },
            onShare: () => showQrShareDialog(context, card),
            onAddToGroup: () {
              final alreadyMultiSelecting = vm.selectedCardIds.length > 1;

              if (!alreadyMultiSelecting) {
                // 只有單選，視為從卡片內點「加入群組」
                vm.clearSelection();
                vm.toggleCardSelection(card.id);
              }

              showAppDialog(
                context: context,
                type: AppDialogType.selectList,
                title: '加入群組',
                options: vm.groups
                    .where((g) => g.name != '全部')
                    .map((g) => g.name)
                    .toList(),
                onOptionSelected: (selectedGroupName) async {
                  final group = vm.groups.firstWhere(
                    (g) => g.name == selectedGroupName,
                  );
                  await vm.assignGroupToSelectedByGroup(group);
                  await vm.loadCards();

                  final affectedCount = vm.selectedCardIds.length;

                  // 清除選取
                  vm.clearSelection();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已加入 $affectedCount 筆名片至「${group.name}」群組'),
                    ),
                  );
                },
              );
            },
            dragHandle: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ),
        );
      },
      onReorder: (oldIndex, newIndex) => vm.reorderCards(oldIndex, newIndex),
    );
  }
}
