// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../core/constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(_emailController.text, _passwordController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('註冊成功！請登入')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('註冊失敗: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('註冊'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 40),
                Text(
                  '建立新帳號',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                AppTextField(
                  controller: _emailController,
                  label: '電子郵件',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '請輸入電子郵件';
                    if (!value!.contains('@')) return '請輸入有效的電子郵件';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                AppTextField(
                  controller: _passwordController,
                  label: '密碼',
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '請輸入密碼';
                    if (value!.length < 6) return '密碼長度至少為6位';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: '確認密碼',
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '請確認密碼';
                    if (value != _passwordController.text) return '密碼不一致';
                    return null;
                  },
                ),
                SizedBox(height: 30),
                _isLoading
                    ? LoadingWidget()
                    : AppButton(
                        text: '註冊',
                        onPressed: _register,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}