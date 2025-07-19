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
import '../../widgets/common/ios_buttons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _acceptTerms = false;
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
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      IOSSnackBar.showError(context, '請先同意服務條款');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success && mounted) {
        IOSSnackBar.showSuccess(context, '註冊成功！請登入');
        Navigator.pop(context);
      } else if (mounted) {
        IOSSnackBar.showError(
          context,
          authProvider.errorMessage ?? '註冊失敗',
        );
      }
    } catch (e) {
      if (mounted) {
        IOSSnackBar.showError(
          context,
          '註冊失敗: ${e.toString()}',
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
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: AppTheme.primaryColor,
          ),
        ),
        middle: Text(
          '註冊',
          style: AppTheme.headline.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildRegisterForm(),
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
          // 插圖
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.successColor,
                  AppTheme.successColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.successColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.person_add_solid,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 標題
          Text(
            '建立新帳號',
            style: AppTheme.largeTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // 副標題
          Text(
            '加入我們，開始管理您的數位名片',
            style: AppTheme.body.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
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
                  placeholder: '請輸入密碼（至少6位）',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
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
                  onSubmitted: (_) {
                    _confirmPasswordFocusNode.requestFocus();
                  },
                ),
                
                const SizedBox(height: 20),
                
                // 確認密碼
                IOSFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  label: '確認密碼',
                  placeholder: '請再次輸入密碼',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  style: IOSTextFieldStyle.grouped,
                  prefix: const Icon(
                    CupertinoIcons.lock_shield,
                    color: AppTheme.secondaryTextColor,
                    size: 20,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '請確認密碼';
                    if (value != _passwordController.text) return '密碼不一致';
                    return null;
                  },
                  onSubmitted: (_) => _register(),
                ),
                
                const SizedBox(height: 24),
                
                // 密碼強度指示器
                _buildPasswordStrengthIndicator(),
                
                const SizedBox(height: 24),
                
                // 服務條款
                _buildTermsAgreement(),
                
                const SizedBox(height: 32),
                
                // 註冊按鈕
                _isLoading
                    ? const Center(
                        child: LoadingWidget(
                          message: null,
                          size: 30,
                          style: IOSLoadingStyle.activity,
                        ),
                      )
                    : IOSPrimaryButton(
                        text: '建立帳號',
                        onPressed: _register,
                        icon: CupertinoIcons.checkmark,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final strength = _calculatePasswordStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '密碼強度',
          style: AppTheme.footnote.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            Color color;
            if (strength >= index + 1) {
              switch (strength) {
                case 1:
                  color = AppTheme.errorColor;
                  break;
                case 2:
                  color = AppTheme.warningColor;
                  break;
                case 3:
                  color = AppTheme.primaryColor;
                  break;
                case 4:
                  color = AppTheme.successColor;
                  break;
                default:
                  color = AppTheme.separatorColor;
              }
            } else {
              color = AppTheme.separatorColor;
            }
            
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _getPasswordStrengthText(strength),
          style: AppTheme.caption1.copyWith(
            color: AppTheme.tertiaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () {
            setState(() {
              _acceptTerms = !_acceptTerms;
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _acceptTerms ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _acceptTerms ? AppTheme.primaryColor : AppTheme.separatorColor,
                width: 2,
              ),
            ),
            child: _acceptTerms
                ? const Icon(
                    CupertinoIcons.checkmark,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.footnote.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              children: [
                const TextSpan(text: '我同意 '),
                TextSpan(
                  text: '服務條款',
                  style: AppTheme.footnote.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' 和 '),
                TextSpan(
                  text: '隱私政策',
                  style: AppTheme.footnote.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // 已有帳號
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '已經有帳號？',
                style: AppTheme.body.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.only(left: 4),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '立即登入',
                  style: AppTheme.body.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 註冊優勢
          _buildBenefitsSection(),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      _Benefit(
        icon: CupertinoIcons.creditcard,
        title: '數位名片',
        description: '建立和管理您的專業數位名片',
      ),
      _Benefit(
        icon: CupertinoIcons.share,
        title: '輕鬆分享',
        description: '透過 QR 碼快速分享您的聯絡資訊',
      ),
      _Benefit(
        icon: CupertinoIcons.folder,
        title: '智能管理',
        description: '使用群組功能整理您的聯絡人',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
      ),
      child: Column(
        children: [
          Text(
            '加入我們的優勢',
            style: AppTheme.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    benefit.icon,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit.title,
                        style: AppTheme.footnote.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        benefit.description,
                        style: AppTheme.caption1.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    
    // 長度檢查
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    
    // 複雜度檢查
    if (RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password)) {
      strength++;
    }
    if (RegExp(r'[0-9]').hasMatch(password) && RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength++;
    }
    
    return strength.clamp(0, 4);
  }

  String _getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
        return '請輸入密碼';
      case 1:
        return '弱';
      case 2:
        return '一般';
      case 3:
        return '良好';
      case 4:
        return '強';
      default:
        return '';
    }
  }
}

class _Benefit {
  final IconData icon;
  final String title;
  final String description;

  _Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });
}