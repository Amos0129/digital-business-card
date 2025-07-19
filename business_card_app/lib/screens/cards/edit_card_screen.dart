// lib/screens/cards/edit_card_screen.dart
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../models/card.dart';
import '../../widgets/ios_field.dart';
import '../../widgets/ios_button.dart';
import '../../widgets/loading_view.dart';
import '../../services/card_service.dart';

class EditCardScreen extends StatefulWidget {
  final BusinessCard? card;

  const EditCardScreen({super.key, this.card});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  // 基本資訊控制器
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // 社交媒體控制器
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _lineController = TextEditingController();
  final _threadsController = TextEditingController();

  // 狀態變數
  bool _facebook = false;
  bool _instagram = false;
  bool _line = false;
  bool _threads = false;
  bool _isPublic = false;
  bool _loading = false;
  String? _selectedStyle = 'default';
  File? _avatarFile;
  String? _avatarUrl;

  // 驗證錯誤
  String? _nameError;
  String? _emailError;
  String? _phoneError;

  final List<Map<String, dynamic>> _cardStyles = [
    {'id': 'default', 'name': '經典', 'color': AppTheme.primaryColor},
    {'id': 'minimal', 'name': '簡約', 'color': AppTheme.secondaryTextColor},
    {'id': 'pink_card', 'name': '粉紅', 'color': CupertinoColors.systemPink},
    {'id': 'mint_card', 'name': '薄荷', 'color': CupertinoColors.systemGreen},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _populateFields();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _lineController.dispose();
    _threadsController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final card = widget.card!;
    _nameController.text = card.name;
    _companyController.text = card.company ?? '';
    _positionController.text = card.position ?? '';
    _phoneController.text = card.phone ?? '';
    _emailController.text = card.email ?? '';
    _addressController.text = card.address ?? '';
    _facebookController.text = card.facebookUrl ?? '';
    _instagramController.text = card.instagramUrl ?? '';
    _lineController.text = card.lineUrl ?? '';
    _threadsController.text = card.threadsUrl ?? '';
    
    _facebook = card.facebook ?? false;
    _instagram = card.instagram ?? false;
    _line = card.line ?? false;
    _threads = card.threads ?? false;
    _isPublic = card.isPublic ?? false;
    _selectedStyle = card.style ?? 'default';
    _avatarUrl = card.avatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildContactSection(),
                  const SizedBox(height: 24),
                  _buildSocialSection(),
                  const SizedBox(height: 24),
                  _buildStyleSection(),
                  const SizedBox(height: 24),
                  _buildPrivacySection(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: AppTheme.backgroundColor,
      largeTitle: Text(widget.card == null ? '建立名片' : '編輯名片'),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showDiscardDialog(),
        child: const Text('取消'),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _loading ? null : _save,
        child: _loading
            ? const CupertinoActivityIndicator()
            : const Text('儲存'),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: Column(
        children: [
          Text(
            '名片頭像',
            style: AppTheme.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 頭像預覽
          CupertinoButton(
            onPressed: _pickAvatar,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _buildAvatarContent(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IOSButton.secondary(
                text: '選擇照片',
                onPressed: _pickAvatar,
                size: IOSButtonSize.small,
              ),
              
              if (_avatarFile != null || _avatarUrl != null) ...[
                const SizedBox(width: 12),
                IOSButton.plain(
                  text: '移除',
                  onPressed: _removeAvatar,
                  size: IOSButtonSize.small,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_avatarFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Image.file(
          _avatarFile!,
          fit: BoxFit.cover,
          width: 96,
          height: 96,
        ),
      );
    }
    
    if (_avatarUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Image.network(
          _avatarUrl!,
          fit: BoxFit.cover,
          width: 96,
          height: 96,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        ),
      );
    }
    
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      CupertinoIcons.camera_fill,
      size: 40,
      color: AppTheme.primaryColor.withOpacity(0.6),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: '基本資訊',
      children: [
        IOSField(
          label: '姓名',
          placeholder: '請輸入您的姓名',
          controller: _nameController,
          errorText: _nameError,
          required: true,
        ),
        
        const SizedBox(height: 16),
        
        IOSField(
          label: '公司',
          placeholder: '請輸入公司名稱',
          controller: _companyController,
        ),
        
        const SizedBox(height: 16),
        
        IOSField(
          label: '職位',
          placeholder: '請輸入職位',
          controller: _positionController,
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: '聯絡方式',
      children: [
        IOSField.phone(
          label: '電話',
          placeholder: '請輸入電話號碼',
          controller: _phoneController,
          errorText: _phoneError,
        ),
        
        const SizedBox(height: 16),
        
        IOSField.email(
          label: '電子郵件',
          placeholder: '請輸入電子郵件',
          controller: _emailController,
          errorText: _emailError,
        ),
        
        const SizedBox(height: 16),
        
        IOSField.multiline(
          label: '地址',
          placeholder: '請輸入地址',
          controller: _addressController,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return _buildSection(
      title: '社群媒體',
      children: [
        _buildSocialField(
          label: 'Facebook',
          icon: CupertinoIcons.globe,
          controller: _facebookController,
          enabled: _facebook,
          onChanged: (value) => setState(() => _facebook = value),
        ),
        
        const SizedBox(height: 16),
        
        _buildSocialField(
          label: 'Instagram',
          icon: CupertinoIcons.camera,
          controller: _instagramController,
          enabled: _instagram,
          onChanged: (value) => setState(() => _instagram = value),
        ),
        
        const SizedBox(height: 16),
        
        _buildSocialField(
          label: 'LINE',
          icon: CupertinoIcons.chat_bubble,
          controller: _lineController,
          enabled: _line,
          onChanged: (value) => setState(() => _line = value),
        ),
        
        const SizedBox(height: 16),
        
        _buildSocialField(
          label: 'Threads',
          icon: CupertinoIcons.link,
          controller: _threadsController,
          enabled: _threads,
          onChanged: (value) => setState(() => _threads = value),
        ),
      ],
    );
  }

  Widget _buildStyleSection() {
    return _buildSection(
      title: '名片樣式',
      children: [
        Text(
          '選擇您喜歡的名片樣式',
          style: AppTheme.footnote.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _cardStyles.map((style) {
            final isSelected = _selectedStyle == style['id'];
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _selectedStyle = style['id'];
                });
              },
              child: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: style['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? style['color'] 
                        : AppTheme.separatorColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 16,
                      decoration: BoxDecoration(
                        color: style['color'],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      style['name'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected 
                            ? style['color'] 
                            : AppTheme.textColor,
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: '隱私設定',
      children: [
        _buildSwitchTile(
          title: '公開顯示',
          subtitle: '讓其他人可以搜尋到這張名片',
          value: _isPublic,
          onChanged: (value) => setState(() => _isPublic = value),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSocialField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.body,
              ),
            ),
            CupertinoSwitch(
              value: enabled,
              onChanged: onChanged,
            ),
          ],
        ),
        
        if (enabled) ...[
          const SizedBox(height: 12),
          IOSField(
            placeholder: '請輸入 $label 連結',
            controller: controller,
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.body,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.footnote.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return IOSButton.primary(
      text: widget.card == null ? '建立名片' : '儲存變更',
      onPressed: _canSave() ? _save : null,
      loading: _loading,
      fullWidth: true,
      size: IOSButtonSize.large,
    );
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty && !_loading;
  }

  void _pickAvatar() {
    // 實作選擇頭像功能
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('選擇頭像'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作相機拍照
            },
            child: const Text('拍照'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作相簿選擇
            },
            child: const Text('從相簿選擇'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  void _removeAvatar() {
    setState(() {
      _avatarFile = null;
      _avatarUrl = null;
    });
  }

  void _save() async {
    if (!_validateInputs()) return;

    setState(() => _loading = true);

    try {
      final card = BusinessCard(
        id: widget.card?.id,
        name: _nameController.text.trim(),
        company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        style: _selectedStyle,
        facebookUrl: _facebook && _facebookController.text.trim().isNotEmpty ? _facebookController.text.trim() : null,
        instagramUrl: _instagram && _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
        lineUrl: _line && _lineController.text.trim().isNotEmpty ? _lineController.text.trim() : null,
        threadsUrl: _threads && _threadsController.text.trim().isNotEmpty ? _threadsController.text.trim() : null,
        facebook: _facebook,
        instagram: _instagram,
        line: _line,
        threads: _threads,
        isPublic: _isPublic,
        avatarUrl: _avatarUrl,
      );

      if (widget.card == null) {
        await CardService.createCard(card);
      } else {
        await CardService.updateCard(widget.card!.id!, card);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool _validateInputs() {
    bool isValid = true;

    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
    });

    // 驗證姓名
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = '請輸入姓名');
      isValid = false;
    }

    // 驗證Email格式
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      setState(() => _emailError = '請輸入有效的電子郵件格式');
      isValid = false;
    }

    return isValid;
  }

  void _showDiscardDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('放棄變更'),
        content: const Text('確定要放棄目前的變更嗎？'),
        actions: [
          CupertinoDialogAction(
            child: const Text('繼續編輯'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // 關閉對話框
              Navigator.pop(context); // 返回上一頁
            },
            child: const Text('放棄'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('儲存失敗'),
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