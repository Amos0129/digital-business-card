// lib/screens/groups/groups_screen.dart
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';
import '../../models/user.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<Group> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  _loadGroups() async {
    setState(() => _loading = true);
    try {
      final response = await API.get('/group/by-user');
      final groups = (response as List)
          .map((json) => Group.fromJson(json))
          .toList();
      setState(() => _groups = groups);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('群組管理'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showCreateGroupDialog(),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : _groups.isEmpty
                ? _buildEmptyState()
                : _buildGroupsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              CupertinoIcons.folder,
              size: 40,
              color: AppTheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '還沒有群組',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '建立群組來整理您的名片',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          CupertinoButton.filled(
            onPressed: () => _showCreateGroupDialog(),
            child: const Text('建立群組'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    return RefreshIndicator(
      onRefresh: () async => _loadGroups(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          return _buildGroupItem(group);
        },
      ),
    );
  }

  Widget _buildGroupItem(Group group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () => _showGroupOptions(group),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.folder_fill,
                color: AppTheme.primary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '建立於 ${_formatDate(group.createdAt)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _showCreateGroupDialog() {
    final controller = TextEditingController();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('建立群組'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: controller,
              placeholder: '請輸入群組名稱',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _createGroup(controller.text.trim());
              }
            },
            child: const Text('建立'),
          ),
        ],
      ),
    );
  }

  void _showGroupOptions(Group group) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(group.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showRenameDialog(group);
            },
            child: const Text('重新命名'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteDialog(group);
            },
            isDestructiveAction: true,
            child: const Text('刪除群組'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  void _showRenameDialog(Group group) {
    final controller = TextEditingController(text: group.name);
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('重新命名群組'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: controller,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            onPressed: () {
              if (controller.text.trim().isNotEmpty && controller.text.trim() != group.name) {
                Navigator.pop(context);
                _renameGroup(group, controller.text.trim());
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Group group) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('刪除群組'),
        content: Text('確定要刪除「${group.name}」群組嗎？\n群組內的名片不會被刪除。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteGroup(group);
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _createGroup(String name) async {
    try {
      await API.post('/group/create', {'name': name});
      _loadGroups();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _renameGroup(Group group, String newName) async {
    try {
      await API.put('/group/rename/${group.id}', {'name': newName});
      _loadGroups();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _deleteGroup(Group group) async {
    try {
      await API.delete('/group/${group.id}');
      _loadGroups();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('錯誤'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('確定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}