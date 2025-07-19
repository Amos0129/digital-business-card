import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else if (mounted) {
        IOSSnackBar.showError(
          context,
          authProvider.errorMessage ?? '登入失敗',
        );
      }
    } catch (e) {
      if (mounted) {
        IOSSnackBar.showError(
          context,
          '登入失敗: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildLoginForm(),
                  const SizedBox(height: 40),
                  _buildFooter(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.briefcase_fill,
              size: 50,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 標題
          Text(
            'Digital Business Card',
            style: AppTheme.largeTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // 副標題
          Text(
            '管理您的數位名片',
            style: AppTheme.body.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '登入',
                  style: AppTheme.title2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // 電子郵件
                IOSFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: '電子郵件',
                  placeholder: '請輸入電子郵件',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: IOSTextFieldStyle.grouped,
                  prefix: const Icon(
                    CupertinoIcons.mail,
                    color: AppTheme.secondaryTextColor,
                    size: 20,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '請輸入電子郵件';
                    if (!value!.contains('@')) return '請輸入有效的電子郵件';
                    return null;
                  },
                  onSubmitted: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                ),
                
                const SizedBox(height: 20),
                
                // 密碼
                IOSFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: '密碼',
                  placeholder: '請輸入密碼',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  style: IOSTextFieldStyle.grouped,
                  prefix: const Icon(
                    CupertinoIcons.lock,
                    color: AppTheme.secondaryTextColor,
                    size: 20,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '請輸入密碼';
                    if (value!.length < 6) return '密碼長度至少為6位';
                    return null;
                  },
                  onSubmitted: (_) => _login(),
                ),
                
                const SizedBox(height: 32),
                
                // 登入按鈕
                _isLoading
                    ? const Center(
                        child: LoadingWidget(
                          message: null,
                          size: 30,
                          style: IOSLoadingStyle.activity,
                        ),
                      )
                    : IOSPrimaryButton(
                        text: '登入',
                        onPressed: _login,
                        icon: const Icon(CupertinoIcons.arrow_right),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // 忘記密碼
          CupertinoButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.forgotPassword);
            },
            child: Text(
              '忘記密碼？',
              style: AppTheme.body.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 分隔線
          Row(
            children: [
              const Expanded(child: Divider(color: AppTheme.separatorColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '或',
                  style: AppTheme.footnote.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppTheme.separatorColor)),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 註冊按鈕
          IOSSecondaryButton(
            text: '建立新帳號',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.register);
            },
            icon: const Icon(CupertinoIcons.person_add),
          ),
          
          const SizedBox(height: 40),
          
          // 版本資訊
          Text(
            '版本 1.0.0',
            style: AppTheme.caption1.copyWith(
              color: AppTheme.tertiaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

// iOS 風格的登入選項卡片
class _LoginOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _LoginOptionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
          border: Border.all(
            color: AppTheme.separatorColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.headline.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.footnote.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              color: AppTheme.tertiaryTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Face ID / Touch ID 登入組件
class _BiometricLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isAvailable;

  const _BiometricLoginButton({
    Key? key,
    this.onPressed,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) return const SizedBox.shrink();
    
    return CupertinoButton(
      onPressed: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(
          CupertinoIcons.faceid,
          color: AppTheme.primaryColor,
          size: 30,
        ),
      ),
    );
  }
}