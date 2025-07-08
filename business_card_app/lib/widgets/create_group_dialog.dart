import 'package:flutter/material.dart';

class CreateGroupDialog extends StatefulWidget {
  final Function(String groupName) onCreate;
  final List<String> existingGroups;

  const CreateGroupDialog({
    super.key,
    required this.onCreate,
    required this.existingGroups,
  });

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  void _submit() {
    final groupName = _controller.text.trim();

    if (groupName.isEmpty) {
      setState(() => _error = '群組名稱不可為空');
      return;
    }

    if (widget.existingGroups.contains(groupName)) {
      setState(() => _error = '群組已存在');
      return;
    }

    widget.onCreate(groupName);
    Navigator.pop(context);

    // 顯示成功訊息
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已新增群組：$groupName')));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新增群組',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: '請輸入群組名稱',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text(
                    '取消',
                    style: TextStyle(color: Colors.black87),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CFF),
                    foregroundColor: Colors.white, // 🔧 強制設定字為白色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('新增'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
