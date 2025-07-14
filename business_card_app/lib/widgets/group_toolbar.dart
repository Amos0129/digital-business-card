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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 群組下拉選單 + ➕
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GroupModel>(
                value: vm.groups.isEmpty
                    ? null
                    : vm.groups.firstWhere(
                        (g) => g.name == vm.selectedGroup,
                        orElse: () => vm.groups.first,
                      ),
                onChanged: vm.groups.isEmpty
                    ? null
                    : (group) => vm.selectGroup(group!.name),
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
                items: vm.groups.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g.name));
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 4),
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

          const SizedBox(width: 12),

          // 搜尋欄
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: vm.searchController,
                onChanged: (_) => vm.notifyListeners(),
                decoration: InputDecoration(
                  hintText: '搜尋名片（姓名/公司）',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 篩選與檢視模式
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: '篩選條件',
                onPressed: () => _showFilterBottomSheet(context, vm),
              ),
              IconButton(
                icon: Icon(
                  vm.viewMode == ViewMode.card
                      ? Icons.view_list
                      : Icons.grid_view,
                ),
                tooltip: '切換檢視模式',
                onPressed: vm.toggleViewMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, CardGroupViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '篩選條件',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.public, size: 20),
                  const SizedBox(width: 8),
                  const Text('搜尋公開名片', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Switch(
                    value: vm.includePublicCards,
                    onChanged: (val) {
                      Navigator.pop(context);
                      vm.setIncludePublic(val);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
