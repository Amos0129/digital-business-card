import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/group_model.dart';
import '../utils/app_dialog.dart';
import '../viewmodels/group_manager_viewmodel.dart';

class GroupManagerPage extends StatelessWidget {
  const GroupManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupManagerViewModel()..loadGroups(),
      child: const _GroupManagerPageContent(),
    );
  }
}

class _GroupManagerPageContent extends StatelessWidget {
  const _GroupManagerPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroupManagerViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('管理群組')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: vm.controller,
              decoration: InputDecoration(
                hintText: '輸入新的群組名稱',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => _handleAddGroup(context),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAddGroup(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CFF),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('新增'),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: vm.sortedGroups.length,
                itemBuilder: (_, index) {
                  final group = vm.sortedGroups[index];
                  final isProtected = vm.isProtected(group.name);

                  return ListTile(
                    title: Text('${group.name} (${group.id})'),
                    subtitle: isProtected
                        ? const Text(
                            '系統預設群組，無法刪除',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          )
                        : null,
                    trailing: isProtected
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _handleRenameGroup(context, group),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _handleDeleteGroup(context, group),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddGroup(BuildContext context) async {
    final vm = context.read<GroupManagerViewModel>();
    final name = vm.controller.text.trim();
    try {
      await vm.addGroup(name);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已新增群組：$name')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _handleRenameGroup(BuildContext context, GroupModel group) {
    final vm = context.read<GroupManagerViewModel>();
    showAppDialog(
      context: context,
      type: AppDialogType.input,
      title: '編輯群組名稱',
      message: group.name,
      onOptionSelected: (newName) async {
        if (newName.isEmpty || newName == group.name) return;
        try {
          await vm.renameGroup(group, newName);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('已修改為：$newName')));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('修改失敗：$e')));
        }
      },
    );
  }

  void _handleDeleteGroup(BuildContext context, GroupModel group) {
    final vm = context.read<GroupManagerViewModel>();
    showAppDialog(
      context: context,
      type: AppDialogType.confirm,
      title: '確認刪除',
      message: '你確定要刪除群組「${group.name}」嗎？',
      onConfirm: () async {
        try {
          await vm.deleteGroup(group);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('已刪除群組：${group.name}')));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('刪除失敗：$e')));
        }
      },
    );
  }
}
