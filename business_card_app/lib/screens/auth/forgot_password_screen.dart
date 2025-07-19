// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import '../../core/storage.dart';
import '../../core/api.dart';
import '../../core/constants.dart';
import '../../widgets/ios_field.dart';
import '../../widgets/ios_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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
              largeTitle: const Text('重設密碼'),
              backgroundColor: AppTheme.backgroundColor,
            ),
            
            // 內容
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _emailSent ? _buildSuccessView() : _buildFormView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 40),
        _buildForm(),
        const SizedBox(height: 32),
        _buildSubmitButton(),
        const SizedBox(height: 24),
        _buildBackToLoginLink(),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        
        // 成功圖示
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            CupertinoIcons.mail_solid,
            size: 50,
            color: AppTheme.successColor,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 標題
        Text(
          '重設連結已發送',
          style: AppTheme.title2.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // 描述
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTheme.body.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            children: [
              const TextSpan(text: '我們已將密碼重設連結發送至\n'),
              TextSpan(
                text: _emailController.text.trim(),
                style: AppTheme.body.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n\n請檢查您的信箱並點擊連結來重設密碼'),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // 提示訊息
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
            border: Border.all(
              color: AppTheme.warningColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: AppTheme.warningColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '沒有收到信件？請檢查垃圾信件匣，或等待幾分鐘後重新嘗試。',
                  style: AppTheme.footnote.copyWith(
                    color: AppTheme.warningColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 重新發送按鈕
        IOSButton.secondary(
          text: '重新發送',
          onPressed: _resendEmail,
          fullWidth: true,
        ),
        
        const SizedBox(height: 16),
        
        // 返回登入
        IOSButton.plain(
          text: '返回登入',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 圖示
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            CupertinoIcons.lock_rotation,
            size: 30,
            color: AppTheme.primaryColor,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          '忘記密碼了嗎？',
          style: AppTheme.title2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '輸入您註冊時使用的電子郵件，我們將發送重設密碼的連結給您',
          style: AppTheme.subheadline.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return IOSField.email(
      label: '電子郵件',
      placeholder: '請輸入您的電子郵件',
      controller: _emailController,
      errorText: _emailError,
      required: true,
    );
  }

  Widget _buildSubmitButton() {
    return IOSButton.primary(
      text: '發送重設連結',
      onPressed: _canSubmit() ? _sendResetEmail : null,
      loading: _isLoading,
      fullWidth: true,
      size: IOSButtonSize.large,
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: IOSButton.plain(
        text: '返回登入',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  bool _canSubmit() {
    return _emailController.text.trim().isNotEmpty && !_isLoading;
  }

  void _sendResetEmail() async {
    if (!_validateEmail()) return;

    setState(() => _isLoading = true);

    try {
      await ApiClient.post(
        ApiEndpoints.forgotPassword,
        {'email': _emailController.text.trim()},
      );

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(_getErrorMessage(e.toString()));
      }
    }
  }

  void _resendEmail() async {
    setState(() => _isLoading = true);

    try {
      await ApiClient.post(
        ApiEndpoints.forgotPassword,
        {'email': _emailController.text.trim()},
      );

      if (mounted) {
        setState(() => _isLoading = false);
        AppUtils.showSnackBar(context, '重設連結已重新發送');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(_getErrorMessage(e.toString()));
      }
    }
  }

  bool _validateEmail() {
    final email = _emailController.text.trim();
    
    setState(() => _emailError = null);

    if (email.isEmpty) {
      setState(() => _emailError = '請輸入電子郵件');
      return false;
    }

    if (!AppUtils.isValidEmail(email)) {
      setState(() => _emailError = '請輸入有效的電子郵件格式');
      return false;
    }

    return true;
  }

  String _getErrorMessage(String error) {
    if (error.contains('找不到該帳號')) {
      return '此電子郵件尚未註冊，請確認輸入是否正確';
    }
    if (error.contains('網路')) {
      return AppConstants.errorNetwork;
    }
    return '發送失敗，請稍後再試';
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('發送失敗'),
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