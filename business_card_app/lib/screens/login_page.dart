import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../screens/forgot_password_page.dart';
import '../screens/register_page.dart';
import '../screens/home_page.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

import '../constants/app_colors.dart';

import '../utils/app_dialog.dart';
import '../services/user_service.dart';

import '../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 檢查是否剛登出
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final justLoggedOut = prefs.getBool('just_logged_out') ?? false;

      if (justLoggedOut) {
        await prefs.remove('just_logged_out');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('您已成功登出')));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: 'auth-title',
            child: Text(
              "登入",
              style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
        ),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "歡迎回來",
                    style: GoogleFonts.notoSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "請輸入您的帳號密碼繼續",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppTextFormField(label: "Email", controller: emailController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                    label: "密碼",
                    controller: passwordController,
                    obscure: true,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        "忘記密碼？",
                        style: GoogleFonts.notoSans(color: Colors.blueGrey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    text: "登入",
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      //print('✉️ email: $email, 🔐 password: $password');
                      if (email.isEmpty || password.isEmpty) {
                        showAppDialog(
                          context: context,
                          type: AppDialogType.error,
                          title: "錯誤",
                          message: "請填寫帳號與密碼",
                        );
                        return;
                      }

                      try {
                        final userService = UserService(); // ✅ 建立實例
                        final user = await userService.login(
                          email,
                          password,
                        ); // ✅ 呼叫登入
                        Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).setUser(user);

                        showAppDialog(
                          context: context,
                          type: AppDialogType.success,
                          title: "登入成功",
                          message: "歡迎 ${user.name}",
                          onClose: () {
                            Navigator.pushReplacementNamed(context, '/profile');
                          },
                        );
                      } catch (e) {
                        showAppDialog(
                          context: context,
                          type: AppDialogType.error,
                          title: "登入失敗",
                          message: e.toString(),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("或"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: "以 Google 登入",
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    onPressed: () {},
                    filled: false,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    text: "以 Apple 登入",
                    icon: const Icon(Icons.apple),
                    onPressed: () {},
                    filled: false,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("還沒有帳號？", style: GoogleFonts.notoSans()),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RegisterPage()),
                          );
                        },
                        child: Text(
                          "立即註冊",
                          style: GoogleFonts.notoSans(
                            color: Colors.indigoAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
