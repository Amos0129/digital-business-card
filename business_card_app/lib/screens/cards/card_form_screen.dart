// lib/screens/cards/card_form_screen.dart
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import '../../models/card.dart';
import '../../services/card_service.dart';

class CardFormScreen extends StatefulWidget {
  final BusinessCard? card;

  const CardFormScreen({super.key, this.card});

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _lineController = TextEditingController();
  final _threadsController = TextEditingController();

  bool _facebook = false;
  bool _instagram = false;
  bool _line = false;
  bool _threads = false;
  bool _isPublic = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _populateFields();
    }
  }

  _populateFields() {
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.card == null ? '新增名片' : '編輯名片'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _loading ? null : _save,
          child: _loading
              ? const CupertinoActivityIndicator()
              : const Text('儲存'),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('基本資訊', [
                _buildTextField('姓名 *', _nameController),
                _buildTextField('公司', _companyController),
                _buildTextField('職位', _positionController),
              ]),
              
              _buildSection('聯絡方式', [
                _buildTextField('電話', _phoneController),
                _buildTextField('電子郵件', _emailController),
                _buildTextField('地址', _addressController),
              ]),
              
              _buildSection('社群媒體', [
                _buildSocialField('Facebook', _facebookController, _facebook, (value) {
                  setState(() => _facebook = value);
                }),
                _buildSocialField('Instagram', _instagramController, _instagram, (value) {
                  setState(() => _instagram = value);
                }),
                _buildSocialField('LINE', _lineController, _line, (value) {
                  setState(() => _line = value);
                }),
                _buildSocialField('Threads', _threadsController, _threads, (value) {
                  setState(() => _threads = value);
                }),
              ]),
              
              _buildSection('隱私設定', [
                _buildSwitchTile('公開顯示', '讓其他人可以搜尋到這張名片', _isPublic, (value) {
                  setState(() => _isPublic = value);
                }),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
            boxShadow: AppTheme.iosCardShadow,
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.separatorColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: controller,
            placeholder: '請輸入$label',
            decoration: const BoxDecoration(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialField(
    String label,
    TextEditingController controller,
    bool enabled,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.separatorColor, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textColor,
                  ),
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
            CupertinoTextField(
              controller: controller,
              placeholder: '請輸入 $label 連結',
              decoration: const BoxDecoration(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
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
      ),
    );
  }

  _save() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('請填寫姓名');
      return;
    }

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
        facebookUrl: _facebook && _facebookController.text.trim().isNotEmpty ? _facebookController.text.trim() : null,
        instagramUrl: _instagram && _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
        lineUrl: _line && _lineController.text.trim().isNotEmpty ? _lineController.text.trim() : null,
        threadsUrl: _threads && _threadsController.text.trim().isNotEmpty ? _threadsController.text.trim() : null,
        facebook: _facebook,
        instagram: _instagram,
        line: _line,
        threads: _threads,
        isPublic: _isPublic,
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
      setState(() => _loading = false);
    }
  }

  _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('錯誤'),
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