import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

import '../utils/app_dialog.dart';

class ForgotPasswordPage extends StatelessWidget {
  final emailController = TextEditingController();

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "重設密碼",
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
            Text(
              "請輸入註冊信箱，我們將寄送重設連結給您。",
              style: GoogleFonts.notoSans(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            AppTextFormField(label: "Email", controller: emailController),
            const SizedBox(height: 20),
            AppButton(
              text: "送出",
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  showAppDialog(
                    context: context,
                    type: AppDialogType.error,
                    title: "錯誤",
                    message: "請輸入電子信箱",
                  );
                } else {
                  // TODO: 寄送重設信件
                  showAppDialog(
                    context: context,
                    type: AppDialogType.success,
                    title: "已寄送",
                    message: "請查看您的信箱以完成重設密碼流程。",
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
