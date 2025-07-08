import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_dialog.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _accountFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  UserModel? user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final u = Provider.of<UserProvider>(context, listen: false).user;
    if (u == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      user = u;
      nameController.text = user!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('帳戶資訊編輯'),
        backgroundColor: const Color(0xFF4A6CFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _accountFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '基本資訊',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              AppTextFormField(
                label: '顯示名稱',
                controller: nameController,
                validator: (val) =>
                    val == null || val.isEmpty ? '顯示名稱不能為空' : null,
              ),
              const SizedBox(height: 16),
              Text('Email：$email', style: const TextStyle(color: Colors.grey)),
              const Divider(height: 32),

              const Text(
                '更改密碼',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              AppTextFormField(
                label: '舊密碼',
                controller: oldPasswordController,
                obscure: true,
              ),
              const SizedBox(height: 12),
              AppTextFormField(
                label: '新密碼',
                controller: newPasswordController,
                obscure: true,
              ),
              const SizedBox(height: 12),
              AppTextFormField(
                label: '確認新密碼',
                controller: confirmPasswordController,
                obscure: true,
              ),
              const SizedBox(height: 32),

              AppButton(text: '儲存', onPressed: _handleSave),
              const SizedBox(height: 32),

              const Divider(),
              TextButton.icon(
                onPressed: _confirmDeleteAccount,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('刪除帳號', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
    if (!_accountFormKey.currentState!.validate()) return;

    final userService = UserService();
    final oldPw = oldPasswordController.text;
    final newPw = newPasswordController.text;
    final confirmPw = confirmPasswordController.text;
    final newName = nameController.text;

    try {
      if (oldPw.isNotEmpty || newPw.isNotEmpty || confirmPw.isNotEmpty) {
        if (oldPw.isEmpty) throw '請輸入舊密碼';
        if (newPw.length < 6) throw '新密碼長度需至少 6 碼';
        if (newPw != confirmPw) throw '新密碼與確認密碼不一致';

        await userService.changePassword(oldPw, newPw);
      }

      await userService.updateDisplayName(newName);

      final updatedUser = UserModel(
        id: user!.id,
        name: newName,
        email: user!.email,
      );

      if (!mounted) return;

      Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);

      showAppDialog(
        context: context,
        type: AppDialogType.success,
        title: '更新成功',
        message: '您的帳戶資訊已儲存',
        onConfirm: () => Navigator.pop(context),
      );
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _confirmDeleteAccount() {
    showAppDialog(
      context: context,
      type: AppDialogType.confirm,
      title: '確定刪除帳號？',
      message: '此操作無法復原，您將失去所有資料。',
      onConfirm: () async {
        try {
          final userService = UserService();
          // TODO: await userService.deleteAccount();

          if (!mounted) return;

          Provider.of<UserProvider>(context, listen: false).clear();

          showAppDialog(
            context: context,
            type: AppDialogType.success,
            title: '帳號已刪除',
            message: '我們會想念你的 👋',
            onConfirm: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (_) => false,
            ),
          );
        } catch (e) {
          _showError(e.toString().replaceAll('Exception: ', ''));
        }
      },
    );
  }

  void _showError(String msg) {
    showAppDialog(
      context: context,
      type: AppDialogType.error,
      title: '錯誤',
      message: msg,
    );
  }
}
