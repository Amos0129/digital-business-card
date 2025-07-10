import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_dialog.dart';

import '../widgets/bottom_nav.dart';

import '../viewmodels/app_settings.dart';

import '../screens/edit_account_page.dart';

import '../providers/user_provider.dart';
import '../models/user.dart';
import '../services/logout_service.dart';
import '../services/scan_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final settings = Provider.of<AppSettings>(context);
    final languageLabel = settings.languageCode == 'en' ? 'English' : '中文';

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('帳戶 / 設定')),
        body: const Center(child: Text('尚未登入')),
        bottomNavigationBar: BottomNav(currentIndex: 3, onTap: _onTab),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('帳戶 / 設定'),
        backgroundColor: const Color(0xFF4A6CFF),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserInfo(user),
          const Divider(),
          _buildLanguageSetting(settings, languageLabel),
          const Divider(),
          _buildDataActions(),
          const Divider(),
          _buildAboutSection(),
          const SizedBox(height: 24),
          _buildFooter(),
          _buildSaveButton(),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: 3, onTap: _onTab),
    );
  }

  Widget _buildUserInfo(UserModel user) {
    return ListTile(
      leading: const CircleAvatar(radius: 24, child: Icon(Icons.person)),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: const Icon(Icons.edit),
      onTap: () async {
        final updated = await Navigator.push<UserModel>(
          context,
          MaterialPageRoute(builder: (_) => EditAccountPage()),
        );
        if (updated != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(updated);
        }
      },
    );
  }

  Widget _buildLanguageSetting(AppSettings settings, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '偏好設定',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        ListTile(
          title: const Text('語言'),
          trailing: Text(label),
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '選擇語言',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListTile(
                        leading: const Text(
                          '🇹🇼',
                          style: TextStyle(fontSize: 24),
                        ),
                        title: const Text('中文'),
                        onTap: () {
                          settings.setLanguage('zh');
                          Navigator.pop(context);
                          setState(() {}); // 強制更新畫面
                        },
                      ),
                      ListTile(
                        leading: const Text(
                          '🇺🇸',
                          style: TextStyle(fontSize: 24),
                        ),
                        title: const Text('English'),
                        onTap: () {
                          settings.setLanguage('en');
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '資料操作',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        ListTile(
          title: const Text('匯出名片資料'),
          subtitle: const Text('格式：CSV'),
          leading: const Icon(Icons.download),
          onTap: () => _notImplemented('匯出功能'),
        ),
        ListTile(
          title: const Text('備份至雲端'),
          subtitle: const Text('上次備份時間：今天 12:00'),
          leading: const Icon(Icons.cloud_upload),
          onTap: () => _notImplemented('雲端備份'),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '關於',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        ListTile(title: const Text('App 版本'), trailing: const Text('v1.0.0')),
        ListTile(
          title: const Text('登出'),
          leading: const Icon(Icons.logout),
          onTap: () {
            showAppDialog(
              context: context,
              type: AppDialogType.confirm,
              title: '確定登出？',
              message: '登出後將返回登入畫面',
              onConfirm: () async => await LogoutService.logout(context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: TextButton(
        onPressed: () {}, // TODO: 加隱私政策
        child: const Text('隱私政策 · 使用條款', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('設定已儲存')));
      },
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text('儲存設定', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A6CFF),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _notImplemented(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('尚未實作 $feature')));
  }

  void _onTab(int index) {
    if (index == 3) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/groups');
        break;
      case 2:
        ScanService.scanAndNavigate(context);
        break;
    }
  }
}
