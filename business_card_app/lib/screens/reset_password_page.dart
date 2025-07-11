import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../utils/app_dialog.dart';
import '../services/user_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({Key? key, required this.token}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '重設密碼',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            AppTextFormField(
              label: '新密碼',
              controller: newPasswordController,
              obscure: true,
            ),
            const SizedBox(height: 20),
            AppTextFormField(
              label: '確認密碼',
              controller: confirmPasswordController,
              obscure: true,
            ),
            const SizedBox(height: 30),
            AppButton(
              text: '確認重設',
              onPressed: () async {
                final newPassword = newPasswordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                if (newPassword.isEmpty || confirmPassword.isEmpty) {
                  showAppDialog(
                    context: context,
                    type: AppDialogType.error,
                    title: '錯誤',
                    message: '請輸入所有欄位',
                  );
                  return;
                }
                if (newPassword != confirmPassword) {
                  showAppDialog(
                    context: context,
                    type: AppDialogType.error,
                    title: '錯誤',
                    message: '密碼與確認密碼不一致',
                  );
                  return;
                }

                try {
                  final userService = UserService();
                  await userService.resetPassword(widget.token, newPassword);

                  showAppDialog(
                    context: context,
                    type: AppDialogType.success,
                    title: '成功',
                    message: '密碼已成功重設，請重新登入。',
                    onClose: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  );
                } catch (e) {
                  showAppDialog(
                    context: context,
                    type: AppDialogType.error,
                    title: '失敗',
                    message: e.toString().replaceFirst('Exception: ', ''),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
