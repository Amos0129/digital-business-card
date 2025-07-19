// lib/screens/auth/register_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/storage.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ios_field.dart';
import '../../widgets/ios_button.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 導航列
            CupertinoSliverNavigationBar(
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Icon(CupertinoIcons.back),
              ),
              largeTitle: const Text('註冊帳號'),
              backgroundColor: AppTheme.backgroundColor,
            ),
            
            // 內容
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildForm(),
                    const SizedBox(height: 24),
                    _buildTermsCheckbox(),
                    const SizedBox(height: 32),
                    _buildRegisterButton(),
                    const SizedBox(height: 24),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '建立您的數位名片帳號',
          style: AppTheme.title2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '開始您的數位名片之旅，讓分享聯絡資訊變得更簡單',
          style: AppTheme.subheadline.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Email輸入框
        IOSField.email(
          label: '電子郵件',
          placeholder: '請輸入您的電子郵件',
          controller: _emailController,
          errorText: _emailError,
          required: true,
        ),
        
        const SizedBox(height: 20),
        
        // 密碼輸入框
        IOSField.password(
          label: '密碼',
          placeholder: '請設定密碼（至少6個字元）',
          controller: _passwordController,
          errorText: _passwordError,
          required: true,
        ),
        
        const SizedBox(height: 20),
        
        // 確認密碼輸入框
        IOSField.password(
          label: '確認密碼',
          placeholder: '請再次輸入密碼',
          controller: _confirmPasswordController,
          errorText: _confirmPasswordError,
          required: true,
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 24,
            onPressed: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: Icon(
              _agreeToTerms 
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              color: _agreeToTerms 
                  ? AppTheme.primaryColor 
                  : AppTheme.secondaryTextColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTheme.footnote.copyWith(
                  color: AppTheme.textColor,
                ),
                children: [
                  const TextSpan(text: '我已閱讀並同意'),
                  TextSpan(
                    text: '服務條款',
                    style: AppTheme.footnote.copyWith(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '和'),
                  TextSpan(
                    text: '隱私政策',
                    style: AppTheme.footnote.copyWith(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return IOSButton.primary(
      text: '建立帳號',
      onPressed: _canRegister() ? _register : null,
      loading: _isLoading,
      fullWidth: true,
      size: IOSButtonSize.large,
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: IOSButton.plain(
        text: '已有帳號？立即登入',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  bool _canRegister() {
    return _emailController.text.isNotEmpty &&
           _passwordController.text.isNotEmpty &&
           _confirmPasswordController.text.isNotEmpty &&
           _agreeToTerms &&
           !_isLoading;
  }

  void _register() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessDialog();
      } else {
        _showError('註冊失敗，請稍後再試');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateInputs() {
    bool isValid = true;

    // 清除之前的錯誤
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // 驗證Email
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = '請輸入電子郵件');
      isValid = false;
    } else if (!AppUtils.isValidEmail(email)) {
      setState(() => _emailError = '請輸入有效的電子郵件格式');
      isValid = false;
    }

    // 驗證密碼
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = '請輸入密碼');
      isValid = false;
    } else if (!AppUtils.isValidPassword(password)) {
      setState(() => _passwordError = '密碼長度至少為6個字元');
      isValid = false;
    }

    // 驗證確認密碼
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = '請確認密碼');
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = '兩次輸入的密碼不一致');
      isValid = false;
    }

    // 驗證服務條款
    if (!_agreeToTerms) {
      _showError('請先同意服務條款和隱私政策');
      isValid = false;
    }

    return isValid;
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('註冊成功'),
        content: const Text('您的帳號已建立成功，現在可以登入了'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(); // 關閉對話框
              Navigator.of(context).pop(); // 返回登入頁面
            },
            child: const Text('立即登入'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('註冊失敗'),
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