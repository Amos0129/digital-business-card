// lib/screens/home/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../core/constants.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isEditingName = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.isEmpty) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateDisplayName(_nameController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('名稱更新成功')),
      );
      setState(() => _isEditingName = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失敗: ${e.toString()}')),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請填寫所有欄位')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('新密碼長度至少為6位')),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('密碼更新成功')),
      );
      setState(() => _isChangingPassword = false);
      _oldPasswordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失敗: ${e.toString()}')),
      );
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('個人資料'),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 使用者資訊
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authProvider.user!.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    authProvider.user!.email,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                // 修改名稱
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '修改名稱',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isEditingName ? Icons.close : Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _isEditingName = !_isEditingName;
                                  if (!_isEditingName) {
                                    _nameController.text = authProvider.user!.name;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        if (_isEditingName) ...[
                          SizedBox(height: 16),
                          AppTextField(
                            controller: _nameController,
                            label: '姓名',
                          ),
                          SizedBox(height: 16),
                          AppButton(
                            text: '更新',
                            onPressed: _updateName,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                // 修改密碼
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '修改密碼',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isChangingPassword ? Icons.close : Icons.lock),
                              onPressed: () {
                                setState(() {
                                  _isChangingPassword = !_isChangingPassword;
                                  if (!_isChangingPassword) {
                                    _oldPasswordController.clear();
                                    _newPasswordController.clear();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        if (_isChangingPassword) ...[
                          SizedBox(height: 16),
                          AppTextField(
                            controller: _oldPasswordController,
                            label: '舊密碼',
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          AppTextField(
                            controller: _newPasswordController,
                            label: '新密碼',
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          AppButton(
                            text: '更新密碼',
                            onPressed: _changePassword,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                
                // 登出按鈕
                AppButton(
                  text: '登出',
                  onPressed: _logout,
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}