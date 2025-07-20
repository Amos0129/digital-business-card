// lib/screens/auth/login_screen.dart - 修正版本
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              
              const SizedBox(height: 16),
              
              // 忘記密碼連結
              CupertinoButton(
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => ForgotPasswordScreen()),
                ),
                child: Text(
                  '忘記密碼？',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
              
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
          keyboardType: TextInputType.emailAddress,
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
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
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
    // 基本驗證
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('請填寫完整資訊');
      return;
    }

    // 簡單的 Email 格式驗證
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailController.text)) {
      _showError('請輸入有效的電子郵件格式');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          print('Login successful, auth state will trigger navigation'); // 調試用
          // 不需要手動導航，AuthProvider 狀態變化會自動觸發 app.dart 中的 Consumer 重建
        } else {
          // 顯示 AuthProvider 中的錯誤訊息
          final errorMessage = authProvider.errorMessage ?? '登入失敗，請檢查帳號密碼';
          _showError(errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('登入時發生錯誤：$e');
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('登入失敗'),
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