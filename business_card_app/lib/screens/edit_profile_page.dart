import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/social_field.dart';
import '../widgets/style_selector.dart';
import '../widgets/card_preview.dart';
import '../widgets/app_text_field.dart';

import '../models/card_request.dart';
import '../services/card_service.dart';
import '../constants/style_config.dart';
import '../utils/app_dialog.dart';

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

  bool _hasFacebook = false;
  bool _hasInstagram = false;
  bool _hasLine = false;
  bool _hasThreads = false;

  String _selectedStyleId = 'default';
  String? _avatarUrl;
  int? _cardId;
  bool _isPublic = true;

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
      facebookUrl: _facebookController.text,
      instagramUrl: _instagramController.text,
      lineUrl: _lineController.text,
      threadsUrl: _threadsController.text,
      avatarUrl: _avatarUrl,
      isPublic: _isPublic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStyle = getStyleById(_selectedStyleId);

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

              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '是否公開名片',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '開啟後，其他用戶可透過掃描或搜尋看到你',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: (val) async {
                        setState(() => _isPublic = val);
                        if (_cardId != null) {
                          try {
                            await cardService.updatePublicStatus(_cardId!, val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val ? '名片已設為公開' : '名片已設為私密'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('更新公開狀態失敗: $e')),
                            );
                          }
                        }
                      },
                      activeColor: const Color(0xFF4A6CFF),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('名片樣式'),
              StyleSelector(
                selectedId: _selectedStyleId,
                styles: styles,
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
                styleId: _selectedStyleId,
                name: _nameController.text,
                company: _companyController.text,
                phone: _phoneController.text,
                email: _emailController.text,
                address: _addressController.text,
                fbUrl: _hasFacebook ? _facebookController.text : null,
                igUrl: _hasInstagram ? _instagramController.text : null,
                lineUrl: _hasLine ? _lineController.text : null,
                threadsUrl: _hasThreads ? _threadsController.text : null,
                avatarUrl: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? 'http://192.168.205.54:5566$_avatarUrl'
                    : null,
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

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || _cardId == null) return;

    try {
      final avatarUrl = await cardService.uploadAvatar(_cardId!, pickedFile);

      setState(() {
        _avatarUrl = avatarUrl;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('頭像上傳成功')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('頭像上傳失敗: $e')));
    }
  }

  Future<void> _clearAvatar() async {
    if (_cardId == null) return;

    try {
      await cardService.clearAvatar(_cardId!);
      setState(() {
        _avatarUrl = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('頭像已清除')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('清除頭像失敗: $e')));
    }
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

          _facebookController.text = card.facebookUrl ?? '';
          _instagramController.text = card.instagramUrl ?? '';
          _lineController.text = card.lineUrl ?? '';
          _threadsController.text = card.threadsUrl ?? '';

          _hasFacebook = card.facebookUrl?.isNotEmpty == true;
          _hasInstagram = card.instagramUrl?.isNotEmpty == true;
          _hasLine = card.lineUrl?.isNotEmpty == true;
          _hasThreads = card.threadsUrl?.isNotEmpty == true;

          _avatarUrl = card.avatarUrl;
          _isPublic = card.isPublic;
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
    const serverBaseUrl = 'http://192.168.205.54:5566'; // ✅ 改成你 API 的 IP + Port

    final resolvedAvatarUrl = (_avatarUrl != null && _avatarUrl!.isNotEmpty)
        ? '$serverBaseUrl$_avatarUrl'
        : null;

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: resolvedAvatarUrl != null
                    ? NetworkImage(resolvedAvatarUrl)
                    : null,
                child: resolvedAvatarUrl == null
                    ? const Icon(Icons.person, size: 48, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A6CFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_avatarUrl != null && _avatarUrl!.isNotEmpty)
          TextButton.icon(
            onPressed: () {
              showAppDialog(
                context: context,
                type: AppDialogType.confirm,
                title: '確認清除頭像？',
                message: '這個動作無法復原',
                onConfirm: () async {
                  await _clearAvatar();
                },
              );
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('清除頭像', style: TextStyle(color: Colors.red)),
          ),
      ],
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
