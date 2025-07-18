import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../models/group.dart';
import '../../core/constants.dart';

class GroupsScreen extends StatefulWidget {
  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.loadGroups();
  }

  Future<void> _createGroup() async {
    final nameController = TextEditingController();
    
    final groupName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('新增群組'),
        content: AppTextField(
          controller: nameController,
          label: '群組名稱',
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: Text('建立'),
          ),
        ],
      ),
    );

    if (groupName != null && groupName.isNotEmpty) {
      try {
        final groupProvider = Provider.of<GroupProvider>(context, listen: false);
        await groupProvider.createGroup(groupName);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('群組建立成功')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('建立失敗: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _renameGroup(CardGroup group) async {
    final nameController = TextEditingController(text: group.name);
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('重新命名群組'),
        content: AppTextField(
          controller: nameController,
          label: '群組名稱',
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: Text('儲存'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != group.name) {
      try {
        final groupProvider = Provider.of<GroupProvider>(context, listen: false);
        await groupProvider.renameGroup(group.id, newName);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('群組重新命名成功')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重新命名失敗: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteGroup(CardGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('刪除群組'),
        content: Text('確定要刪除「${group.name}」群組嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final groupProvider = Provider.of<GroupProvider>(context, listen: false);
        await groupProvider.deleteGroup(group.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('群組已刪除')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刪除失敗: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('群組管理'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createGroup,
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (groupProvider.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '還沒有群組',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createGroup,
                    child: Text('建立第一個群組'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadGroups,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: groupProvider.groups.length,
              itemBuilder: (context, index) {
                final group = groupProvider.groups[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.folder,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      group.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text('點擊查看群組內容'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'rename':
                            _renameGroup(group);
                            break;
                          case 'delete':
                            _deleteGroup(group);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('重新命名'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('刪除', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.groupDetail,
                        arguments: group.id,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}