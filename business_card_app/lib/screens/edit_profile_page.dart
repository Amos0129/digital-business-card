import 'package:flutter/material.dart';

import '../widgets/social_field.dart';
import '../widgets/style_selector.dart';
import '../widgets/card_preview.dart';
import '../widgets/app_text_field.dart';

import '../models/card_request.dart';
import '../services/card_service.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _profileFormKey = GlobalKey<FormState>();

  late final CardService cardService;

  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _lineController = TextEditingController();
  final _threadsController = TextEditingController();

  bool _hasFacebook = true;
  bool _hasInstagram = true;
  bool _hasLine = true;
  bool _hasThreads = false;

  String _selectedStyleId = 'default';
  String? _avatarUrl;
  int? _cardId;

  final List<Map<String, dynamic>> _styles = [
    {
      'id': 'default',
      'name': '預設樣式',
      'bg': Colors.white,
      'text': Colors.black87,
      'accent': const Color(0xFF4A6CFF),
    },
    {
      'id': 'minimal',
      'name': '極簡風',
      'bg': Colors.grey.shade900,
      'text': Colors.white,
      'accent': Colors.white,
    },
    {
      'id': 'pink_card',
      'name': '卡片風格 A',
      'bg': Colors.pink.shade50,
      'text': Colors.pink.shade900,
      'accent': Colors.pink,
    },
    {
      'id': 'mint_card',
      'name': '卡片風格 B',
      'bg': Colors.green.shade50,
      'text': Colors.green.shade900,
      'accent': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    cardService = CardService();
    _initForm();
    for (final ctrl in [
      _nameController,
      _companyController,
      _phoneController,
      _emailController,
      _addressController,
    ]) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _lineController.dispose();
    _threadsController.dispose();
    super.dispose();
  }

  CardRequest _buildCardRequest() {
    return CardRequest(
      name: _nameController.text,
      company: _companyController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
      style: _selectedStyleId,
      facebook: _hasFacebook,
      instagram: _hasInstagram,
      line: _hasLine,
      threads: _hasThreads,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStyle = _styles.firstWhere(
      (s) => s['id'] == _selectedStyleId,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯個人名片'),
        backgroundColor: const Color(0xFF4A6CFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _profileFormKey,
          child: Column(
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('基本資訊'),
              AppTextFormField(
                label: '姓名',
                controller: _nameController,
                required: true,
              ),
              AppTextFormField(label: '公司', controller: _companyController),
              AppTextFormField(
                label: '電話',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              AppTextFormField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              AppTextFormField(label: '地址', controller: _addressController),

              const SizedBox(height: 24),
              _buildSectionTitle('名片樣式'),
              StyleSelector(
                selectedId: _selectedStyleId,
                styles: _styles,
                onSelect: (id) => setState(() => _selectedStyleId = id),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('社群連結'),
              SocialField(
                label: 'Facebook',
                enabled: _hasFacebook,
                onToggle: (val) => setState(() => _hasFacebook = val),
                controller: _facebookController,
              ),
              SocialField(
                label: 'Instagram',
                enabled: _hasInstagram,
                onToggle: (val) => setState(() => _hasInstagram = val),
                controller: _instagramController,
              ),
              SocialField(
                label: 'LINE',
                enabled: _hasLine,
                onToggle: (val) => setState(() => _hasLine = val),
                controller: _lineController,
              ),
              SocialField(
                label: 'Threads',
                enabled: _hasThreads,
                onToggle: (val) => setState(() => _hasThreads = val),
                controller: _threadsController,
              ),

              const SizedBox(height: 30),
              _buildSectionTitle('電子名片預覽'),
              CardPreview(
                style: selectedStyle,
                name: _nameController.text,
                company: _companyController.text,
                phone: _phoneController.text,
                email: _emailController.text,
                address: _addressController.text,
              ),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('儲存'),
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6CFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initForm() async {
    try {
      final cards = await cardService.getMyCards();
      if (cards.isNotEmpty) {
        final card = cards.first;
        setState(() {
          _cardId = card.id;
          _nameController.text = card.name;
          _companyController.text = card.company;
          _phoneController.text = card.phone;
          _emailController.text = card.email;
          _addressController.text = card.address;
          _selectedStyleId = card.style;
          _hasFacebook = card.facebook;
          _hasInstagram = card.instagram;
          _hasLine = card.line;
          _hasThreads = card.threads;
        });
      }
    } catch (e) {
      debugPrint('載入名片失敗: $e');
    }
  }

  Future<void> _handleSave() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final card = _buildCardRequest();

    try {
      if (_cardId == null) {
        await cardService.createCard(card);
      } else {
        await cardService.updateCard(_cardId!, card);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('儲存成功')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('儲存失敗: $e')));
    }
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person, size: 48, color: Colors.grey),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: 開啟相簿選擇頭像
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF4A6CFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
