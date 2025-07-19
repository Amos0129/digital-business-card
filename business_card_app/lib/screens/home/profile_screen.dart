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

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isEditingName = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
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
    
    _fadeController.forward();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      IOSSnackBar.showError(context, '請輸入姓名');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateDisplayName(_nameController.text.trim());
      
      if (success) {
        IOSSnackBar.showSuccess(context, '名稱更新成功');
        setState(() => _isEditingName = false);
      } else {
        IOSSnackBar.showError(context, authProvider.errorMessage ?? '更新失敗');
      }
    } catch (e) {
      IOSSnackBar.showError(context, '更新失敗: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty || 
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      IOSSnackBar.showError(context, '請填寫所有欄位');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      IOSSnackBar.showError(context, '新密碼長度至少為6位');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      IOSSnackBar.showError(context, '新密碼與確認密碼不一致');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );
      
      if (success) {
        IOSSnackBar.showSuccess(context, '密碼更新成功');
        setState(() => _isChangingPassword = false);
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        IOSSnackBar.showError(context, authProvider.errorMessage ?? '更新失敗');
      }
    } catch (e) {
      IOSSnackBar.showError(context, '更新失敗: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await IOSAlert.showConfirm(
      context,
      title: '登出',
      message: '確定要登出嗎？',
      confirmText: '登出',
      cancelText: '取消',
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        middle: Text(
          '個人資料',
          style: AppTheme.headline.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.user == null) {
              return const Center(
                child: LoadingWidget(
                  message: '載入中...',
                  style: IOSLoadingStyle.activity,
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildUserHeader(authProvider.user!),
                    const SizedBox(height: 32),
                    _buildSettingSections(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserHeader(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        children: [
          // 頭像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 用戶名
          Text(
            user.name,
            style: AppTheme.title2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // 電子郵件
          Text(
            user.email,
            style: AppTheme.body.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 統計資訊
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('5', '名片', CupertinoIcons.creditcard),
              _buildStatItem('3', '群組', CupertinoIcons.folder),
              _buildStatItem('12', '聯絡人', CupertinoIcons.person_2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: AppTheme.headline.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTheme.caption1.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingSections() {
    return Column(
      children: [
        _buildAccountSection(),
        const SizedBox(height: 16),
        _buildAppSection(),
        const SizedBox(height: 16),
        _buildDangerSection(),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '帳號設定',
              style: AppTheme.footnote.copyWith(
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildEditNameSection(),
          _buildDivider(),
          _buildChangePasswordSection(),
        ],
      ),
    );
  }

  Widget _buildEditNameSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.person_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '修改姓名',
                  style: AppTheme.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () {
                  setState(() {
                    _isEditingName = !_isEditingName;
                    if (!_isEditingName) {
                      _nameController.text = Provider.of<AuthProvider>(context, listen: false).user!.name;
                    }
                  });
                },
                child: Icon(
                  _isEditingName ? CupertinoIcons.xmark : CupertinoIcons.pencil,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
          
          if (_isEditingName) ...[
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              placeholder: '請輸入姓名',
              style: IOSTextFieldStyle.grouped,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: IOSSecondaryButton(
                    text: '取消',
                    onPressed: () {
                      setState(() => _isEditingName = false);
                      _nameController.text = Provider.of<AuthProvider>(context, listen: false).user!.name;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IOSPrimaryButton(
                    text: '儲存',
                    onPressed: _updateName,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.lock_shield,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '修改密碼',
                  style: AppTheme.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () {
                  setState(() {
                    _isChangingPassword = !_isChangingPassword;
                    if (!_isChangingPassword) {
                      _oldPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    }
                  });
                },
                child: Icon(
                  _isChangingPassword ? CupertinoIcons.xmark : CupertinoIcons.lock,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
          
          if (_isChangingPassword) ...[
            const SizedBox(height: 16),
            AppTextField(
              controller: _oldPasswordController,
              placeholder: '請輸入舊密碼',
              obscureText: true,
              style: IOSTextFieldStyle.grouped,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _newPasswordController,
              placeholder: '請輸入新密碼',
              obscureText: true,
              style: IOSTextFieldStyle.grouped,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _confirmPasswordController,
              placeholder: '請確認新密碼',
              obscureText: true,
              style: IOSTextFieldStyle.grouped,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: IOSSecondaryButton(
                    text: '取消',
                    onPressed: () {
                      setState(() => _isChangingPassword = false);
                      _oldPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IOSPrimaryButton(
                    text: '更新密碼',
                    onPressed: _changePassword,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '應用程式',
              style: AppTheme.footnote.copyWith(
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildSettingItem(
            icon: CupertinoIcons.bell,
            title: '通知設定',
            onTap: () {
              IOSSnackBar.show(context, '功能開發中');
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: CupertinoIcons.moon,
            title: '深色模式',
            trailing: CupertinoSwitch(
              value: false,
              onChanged: (value) {
                IOSSnackBar.show(context, '功能開發中');
              },
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: CupertinoIcons.globe,
            title: '語言設定',
            subtitle: '繁體中文',
            onTap: () {
              IOSSnackBar.show(context, '功能開發中');
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: CupertinoIcons.info_circle,
            title: '關於應用程式',
            subtitle: '版本 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: CupertinoIcons.square_arrow_right,
            title: '登出',
            titleColor: AppTheme.errorColor,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ?? AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.footnote.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? 
            Icon(
              CupertinoIcons.chevron_forward,
              color: AppTheme.tertiaryTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 52),
      height: 0.5,
      color: AppTheme.separatorColor,
    );
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Digital Business Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                CupertinoIcons.briefcase_fill,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text('版本 1.0.0'),
            const SizedBox(height: 8),
            const Text(
              '專業的數位名片管理應用程式\n輕鬆管理和分享您的聯絡資訊',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }
}