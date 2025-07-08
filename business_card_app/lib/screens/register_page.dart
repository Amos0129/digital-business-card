import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

import '../utils/app_dialog.dart';

import '../services/user_service.dart';

import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: 'auth-title',
            child: Text(
              "註冊",
              style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
        ),
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Text(
                "建立帳號",
                style: GoogleFonts.notoSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "請輸入您的資訊以建立帳號",
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              AppTextFormField(label: "Email", controller: emailController),
              const SizedBox(height: 20),
              AppTextFormField(
                label: "密碼",
                controller: passwordController,
                obscure: true,
              ),
              const SizedBox(height: 20),
              AppTextFormField(
                label: "確認密碼",
                controller: confirmPasswordController,
                obscure: true,
              ),
              const SizedBox(height: 30),
              AppButton(
                text: "建立帳號",
                onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  final confirmPassword = confirmPasswordController.text.trim();

                  if (password != confirmPassword) {
                    showAppDialog(
                      context: context,
                      type: AppDialogType.error,
                      title: "錯誤",
                      message: "密碼與確認密碼不一致",
                    );
                    return;
                  }

                  if (email.isEmpty || password.isEmpty) {
                    showAppDialog(
                      context: context,
                      type: AppDialogType.error,
                      title: "錯誤",
                      message: "請填寫所有欄位",
                    );
                    return;
                  }

                  try {
                    // 使用 UserService 進行註冊
                    final userService = UserService();

                    final user = await userService.register(
                      "新用戶",
                      email,
                      password,
                    );

                    showAppDialog(
                      context: context,
                      type: AppDialogType.success,
                      title: "註冊成功",
                      message: "${user.name} 歡迎你加入！",
                      onClose: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                    );
                  } catch (e) {
                    showAppDialog(
                      context: context,
                      type: AppDialogType.error,
                      title: "註冊失敗",
                      message: e.toString(),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("已經有帳號？", style: GoogleFonts.notoSans()),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "返回登入",
                      style: GoogleFonts.notoSans(color: Colors.indigoAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
