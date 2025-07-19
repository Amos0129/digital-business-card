// lib/screens/auth/login_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Logo 區域
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.iosShadow,
                ),
                child: const Icon(
                  CupertinoIcons.person_2_fill,
                  color: CupertinoColors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                '歡迎回來',
                style: AppTheme.largeTitle,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '登入您的數位名片',
                style: AppTheme.subheadline.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // 表單
              _buildForm(),
              
              const Spacer(),
              
              // 註冊按鈕
              CupertinoButton(
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => RegisterScreen()),
                ),
                child: Text(
                  '還沒有帳號？立即註冊',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          placeholder: 'Email',
          icon: CupertinoIcons.mail,
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _passwordController,
          placeholder: '密碼',
          icon: CupertinoIcons.lock,
          obscureText: true,
        ),
        
        const SizedBox(height: 32),
        
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : const Text('登入'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscureText,
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(icon, color: AppTheme.secondaryTextColor),
        ),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(),
      ),
    );
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('請填寫完整資訊');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!success) {
      _showError('登入失敗，請檢查帳號密碼');
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
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