import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/group_model.dart';
import '../services/group_service.dart';
import '../viewmodels/card_group_viewmodel.dart';
import 'create_group_dialog.dart';
import '../enums/view_mode.dart';

class CardGroupToolbar extends StatelessWidget {
  const CardGroupToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CardGroupViewModel>();
    final groupService = GroupService();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          vm.groups.isNotEmpty
              ? DropdownButton<GroupModel>(
                  value: vm.groups.firstWhere(
                    (g) => g.name == vm.selectedGroup,
                    orElse: () => vm.groups.first,
                  ),
                  onChanged: (group) => vm.selectGroup(group!.name),
                  items: vm.groups.map((g) {
                    return DropdownMenuItem(value: g, child: Text(g.name));
                  }).toList(),
                )
              : const Text("無可用群組"),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: vm.searchController,
              onChanged: (_) => vm.notifyListeners(),
              decoration: InputDecoration(
                hintText: '搜尋名片（姓名/公司）',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              vm.viewMode == ViewMode.card ? Icons.view_list : Icons.grid_view,
            ),
            tooltip: '切換檢視模式',
            onPressed: vm.toggleViewMode,
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: '新增群組',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CreateGroupDialog(
                  existingGroups: vm.groups.map((g) => g.name).toList(),
                  onCreate: (newGroup) async {
                    try {
                      final created = await groupService.createGroup(newGroup);
                      await vm.loadGroups();
                      vm.selectGroup(created.name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已新增群組 $newGroup')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('新增群組失敗: $e')));
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
