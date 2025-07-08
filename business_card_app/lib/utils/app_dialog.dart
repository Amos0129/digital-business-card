import 'package:flutter/material.dart';
import 'dart:async';
import '../models/group_model.dart';
import '../main.dart';

enum AppDialogType { confirm, success, error, selectList, input }

void showAppDialog({
  required BuildContext context,
  required AppDialogType type,
  String? title,
  String? message,
  List<String>? options,
  void Function(String)? onOptionSelected,
  VoidCallback? onConfirm,
  VoidCallback? onClose,
  bool dismissible = true,
}) {
  final safeContext = navigatorKey.currentContext!;

  showDialog(
    context: safeContext,
    barrierDismissible: dismissible,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Builder(
          builder: (_) {
            switch (type) {
              case AppDialogType.confirm:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '確認',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(message ?? '', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(safeContext),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(safeContext);
                            onConfirm?.call();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('確定'),
                        ),
                      ],
                    ),
                  ],
                );

              case AppDialogType.input:
                final inputController = TextEditingController(text: message);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title ?? '輸入內容',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: inputController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: '請輸入',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(safeContext),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(safeContext);
                            onOptionSelected?.call(inputController.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6CFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('確定'),
                        ),
                      ],
                    ),
                  ],
                );

              case AppDialogType.success:
              case AppDialogType.error:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type == AppDialogType.success
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 48,
                      color: type == AppDialogType.success
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(message ?? '', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(safeContext);
                          if (onClose != null) onClose();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6CFF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "確定",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );

              case AppDialogType.selectList:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '選擇項目',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...?options?.map(
                      (option) => Column(
                        children: [
                          ListTile(
                            title: Text(option),
                            leading: const Icon(Icons.folder_open),
                            onTap: () {
                              Navigator.pop(safeContext);
                              onOptionSelected?.call(option);
                            },
                          ),
                          if (option != options.last) const Divider(height: 1),
                        ],
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    ),
  );
}

Future<String?> showGroupSelectionDialog(
  BuildContext context,
  List<GroupModel> groups,
) async {
  final completer = Completer<String?>();

  showAppDialog(
    context: context,
    type: AppDialogType.selectList,
    title: '選擇要加入的群組',
    options: groups.where((g) => g.name != '全部').map((g) => g.name).toList(),
    onOptionSelected: completer.complete,
  );

  return completer.future;
}
