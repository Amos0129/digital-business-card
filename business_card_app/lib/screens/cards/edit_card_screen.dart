import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/card_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/card/card_preview.dart';
import '../../models/card.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class EditCardScreen extends StatefulWidget {
  final BusinessCard? card;
  
  EditCardScreen({this.card});

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // 控制器
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _facebookUrlController = TextEditingController();
  final _instagramUrlController = TextEditingController();
  final _lineUrlController = TextEditingController();
  final _threadsUrlController = TextEditingController();
  
  // 狀態
  bool _isLoading = false;
  bool _isPublic = false;
  bool _facebook = false;
  bool _instagram = false;
  bool _line = false;
  bool _threads = false;
  String _selectedStyle = 'default';
  File? _avatarFile;
  String? _avatarUrl;
  int _currentSection = 0;
  
  // 動畫
  late AnimationController _previewController;
  late Animation<double> _previewAnimation;
  
  // 分頁控制器
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _pageController = PageController();
    
    if (widget.card != null) {
      _loadCardData();
    }
  }

  void _initAnimations() {
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _previewAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOut,
    ));
    
    _previewController.forward();
  }

  void _loadCardData() {
    final card = widget.card!;
    _nameController.text = card.name;
    _companyController.text = card.company ?? '';
    _positionController.text = card.position ?? '';
    _phoneController.text = card.phone ?? '';
    _emailController.text = card.email ?? '';
    _addressController.text = card.address ?? '';
    _facebookUrlController.text = card.facebookUrl ?? '';
    _instagramUrlController.text = card.instagramUrl ?? '';
    _lineUrlController.text = card.lineUrl ?? '';
    _threadsUrlController.text = card.threadsUrl ?? '';
    
    setState(() {
      _isPublic = card.isPublic;
      _facebook = card.facebook ?? false;
      _instagram = card.instagram ?? false;
      _line = card.line ?? false;
      _threads = card.threads ?? false;
      _selectedStyle = card.style ?? 'default';
      _avatarUrl = card.avatarUrl;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _facebookUrlController.dispose();
    _instagramUrlController.dispose();
    _lineUrlController.dispose();
    _threadsUrlController.dispose();
    _previewController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final result = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('選擇頭像'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(CupertinoIcons.camera),
                SizedBox(width: 8),
                Text('拍照'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(CupertinoIcons.photo),
                SizedBox(width: 8),
                Text('相簿'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );

    if (result != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: result,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _avatarFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      
      final cardData = {
        'name': _nameController.text.trim(),
        'company': _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        'position': _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'style': _selectedStyle,
        'isPublic': _isPublic,
        'facebook': _facebook,
        'instagram': _instagram,
        'line': _line,
        'threads': _threads,
        'facebookUrl': _facebookUrlController.text.trim().isEmpty ? null : _facebookUrlController.text.trim(),
        'instagramUrl': _instagramUrlController.text.trim().isEmpty ? null : _instagramUrlController.text.trim(),
        'lineUrl': _lineUrlController.text.trim().isEmpty ? null : _lineUrlController.text.trim(),
        'threadsUrl': _threadsUrlController.text.trim().isEmpty ? null : _threadsUrlController.text.trim(),
      };

      BusinessCard savedCard;
      if (widget.card == null) {
        savedCard = await cardProvider.createCard(cardData);
      } else {
        savedCard = await cardProvider.updateCard(widget.card!.id, cardData);
      }

      if (_avatarFile != null) {
        await cardProvider.uploadAvatar(savedCard.id, _avatarFile!);
      }

      IOSSnackBar.showSuccess(context, '名片儲存成功');
      Navigator.pop(context);
    } catch (e) {
      IOSSnackBar.showError(context, '儲存失敗: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToFirstError() {
    // 滾動到第一個錯誤欄位
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
          child: const Text('取消'),
        ),
        middle: Text(
          widget.card == null ? '新增名片' : '編輯名片',
          style: AppTheme.headline.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: _isLoading 
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveCard,
                child: Text(
                  '儲存',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSectionTabs(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentSection = index;
                  });
                },
                children: [
                  _buildBasicInfoSection(),
                  _buildStyleSection(),
                  _buildSocialSection(),
                  _buildPreviewSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTabs() {
    final sections = [
      _SectionTab(icon: CupertinoIcons.person, title: '基本'),
      _SectionTab(icon: CupertinoIcons.paintbrush, title: '樣式'),
      _SectionTab(icon: CupertinoIcons.link, title: '社群'),
      _SectionTab(icon: CupertinoIcons.eye, title: '預覽'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          final isSelected = _currentSection == index;
          
          return Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      section.icon,
                      size: 18,
                      color: isSelected 
                          ? Colors.white 
                          : AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section.title,
                    style: AppTheme.caption1.copyWith(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : AppTheme.secondaryTextColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 32),
            _buildBasicInfoForm(),
            const SizedBox(height: 24),
            _buildPrivacySettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.separatorColor.withOpacity(0.3),
                image: _avatarFile != null
                    ? DecorationImage(
                        image: FileImage(_avatarFile!),
                        fit: BoxFit.cover,
                      )
                    : _avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: _avatarFile == null && _avatarUrl == null
                  ? Icon(
                      CupertinoIcons.camera_fill,
                      size: 40,
                      color: AppTheme.secondaryTextColor,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: const Icon(
                        CupertinoIcons.camera_fill,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '點擊上傳頭像',
            style: AppTheme.footnote.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
      ),
      child: Column(
        children: [
          IOSFormField(
            controller: _nameController,
            label: '姓名',
            placeholder: '請輸入姓名',
            style: IOSTextFieldStyle.grouped,
            prefix: const Icon(CupertinoIcons.person, color: AppTheme.secondaryTextColor, size: 20),
            validator: (value) {
              if (value?.isEmpty ?? true) return '請輸入姓名';
              return null;
            },
          ),
          const SizedBox(height: 16),
          IOSFormField(
            controller: _companyController,
            label: '公司',
            placeholder: '請輸入公司名稱',
            style: IOSTextFieldStyle.grouped,
            prefix: const Icon(CupertinoIcons.building_2_fill, color: AppTheme.secondaryTextColor, size: 20),
          ),
          const SizedBox(height: 16),
          IOSFormField(
            controller: _positionController,
            label: '職位',
            placeholder: '請輸入職位',
            style: IOSTextFieldStyle.grouped,
            prefix: const Icon(CupertinoIcons.briefcase, color: AppTheme.secondaryTextColor, size: 20),
          ),
          const SizedBox(height: 16),
          IOSFormField(
            controller: _phoneController,
            label: '電話',
            placeholder: '請輸入電話號碼',
            keyboardType: TextInputType.phone,
            style: IOSTextFieldStyle.grouped,
            prefix: const Icon(CupertinoIcons.phone, color: AppTheme.secondaryTextColor, size: 20),
          ),
          const SizedBox(height: 16),
          IOSFormField(
            controller: _emailController,
            label: '電子郵件',
            placeholder: '請輸入電子郵件',
            keyboardType: TextInputType.emailAddress,
            style: IOSTextFieldStyle.grouped,
            prefix: const Icon(CupertinoIcons.mail, color: AppTheme.secondaryTextColor, size: 20),
          ),
          const SizedBox(height: 16),
          IOSFormField(
            controller: _addressController,
            label: '地址',
            placeholder: '請輸入地址',
            maxLines: 2,
            style: IOSTextFieldStyle.grouped,
            prefix: const Icon(CupertinoIcons.location, color: AppTheme.secondaryTextColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '隱私設定',
            style: AppTheme.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '公開名片',
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '其他人可以搜尋到這張名片',
                      style: AppTheme.footnote.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                activeColor: AppTheme.successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '名片樣式',
                  style: AppTheme.headline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStyleOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleOptions() {
    final styles = [
      _StyleOption('default', '現代', '漸層藍色主題'),
      _StyleOption('minimal', '簡約', '純白簡潔設計'),
      _StyleOption('pink_card', '粉色', '溫暖粉色漸層'),
      _StyleOption('mint_card', '薄荷', '清新綠色漸層'),
    ];

    return Column(
      children: styles.map((style) {
        final isSelected = _selectedStyle == style.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _selectedStyle = style.value;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.separatorColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: _getStyleGradient(style.value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style.title,
                          style: AppTheme.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                          ),
                        ),
                        Text(
                          style.description,
                          style: AppTheme.footnote.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSocialSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '社群媒體',
              style: AppTheme.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSocialMediaOption(
              icon: CupertinoIcons.logo_facebook,
              title: 'Facebook',
              isEnabled: _facebook,
              controller: _facebookUrlController,
              onToggle: (value) => setState(() => _facebook = value),
              color: const Color(0xFF1877F2),
            ),
            _buildSocialMediaOption(
              icon: CupertinoIcons.camera,
              title: 'Instagram',
              isEnabled: _instagram,
              controller: _instagramUrlController,
              onToggle: (value) => setState(() => _instagram = value),
              color: const Color(0xFFE4405F),
            ),
            _buildSocialMediaOption(
              icon: CupertinoIcons.chat_bubble,
              title: 'Line',
              isEnabled: _line,
              controller: _lineUrlController,
              onToggle: (value) => setState(() => _line = value),
              color: const Color(0xFF00C300),
            ),
            _buildSocialMediaOption(
              icon: CupertinoIcons.at,
              title: 'Threads',
              isEnabled: _threads,
              controller: _threadsUrlController,
              onToggle: (value) => setState(() => _threads = value),
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaOption({
    required IconData icon,
    required String title,
    required bool isEnabled,
    required TextEditingController controller,
    required Function(bool) onToggle,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTheme.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CupertinoSwitch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: color,
            ),
          ],
        ),
        if (isEnabled) ...[
          const SizedBox(height: 12),
          AppTextField(
            controller: controller,
            placeholder: '請輸入 $title 連結',
            style: IOSTextFieldStyle.grouped,
            prefix: Icon(CupertinoIcons.link, color: color, size: 20),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPreviewSection() {
    final previewCard = BusinessCard(
      id: widget.card?.id ?? 0,
      name: _nameController.text.isNotEmpty ? _nameController.text : '姓名',
      company: _companyController.text.isNotEmpty ? _companyController.text : null,
      position: _positionController.text.isNotEmpty ? _positionController.text : null,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      style: _selectedStyle,
      isPublic: _isPublic,
      facebook: _facebook,
      instagram: _instagram,
      line: _line,
      threads: _threads,
      facebookUrl: _facebookUrlController.text.isNotEmpty ? _facebookUrlController.text : null,
      instagramUrl: _instagramUrlController.text.isNotEmpty ? _instagramUrlController.text : null,
      lineUrl: _lineUrlController.text.isNotEmpty ? _lineUrlController.text : null,
      threadsUrl: _threadsUrlController.text.isNotEmpty ? _threadsUrlController.text : null,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _previewAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _previewAnimation.value,
                child: Opacity(
                  opacity: _previewAnimation.value,
                  child: CardPreview(
                    card: previewCard,
                    showQRCode: true,
                    forceStyle: IOSCardPreviewStyle.values.firstWhere(
                      (style) => style.name == _selectedStyle,
                      orElse: () => IOSCardPreviewStyle.modern,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          IOSPrimaryButton(
            text: widget.card == null ? '建立名片' : '更新名片',
            onPressed: _saveCard,
            isLoading: _isLoading,
            icon: Icon(widget.card == null ? CupertinoIcons.add : CupertinoIcons.checkmark),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStyleGradient(String style) {
    switch (style) {
      case 'minimal':
        return const LinearGradient(
          colors: [Colors.white, Colors.grey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pink_card':
        return const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'mint_card':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [AppTheme.primaryColor, const Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

class _SectionTab {
  final IconData icon;
  final String title;

  _SectionTab({required this.icon, required this.title});
}

class _StyleOption {
  final String value;
  final String title;
  final String description;

  _StyleOption(this.value, this.title, this.description);
}