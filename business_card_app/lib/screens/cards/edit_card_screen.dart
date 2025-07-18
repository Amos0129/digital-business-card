import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/card_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../models/card.dart';

class EditCardScreen extends StatefulWidget {
  final BusinessCard? card;
  
  EditCardScreen({this.card});

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
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
  
  bool _isLoading = false;
  bool _isPublic = false;
  bool _facebook = false;
  bool _instagram = false;
  bool _line = false;
  bool _threads = false;
  String _selectedStyle = 'default';
  File? _avatarFile;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _loadCardData();
    }
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
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
    );
    
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      
      final cardData = {
        'name': _nameController.text,
        'company': _companyController.text.isEmpty ? null : _companyController.text,
        'position': _positionController.text.isEmpty ? null : _positionController.text,
        'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
        'email': _emailController.text.isEmpty ? null : _emailController.text,
        'address': _addressController.text.isEmpty ? null : _addressController.text,
        'style': _selectedStyle,
        'isPublic': _isPublic,
        'facebook': _facebook,
        'instagram': _instagram,
        'line': _line,
        'threads': _threads,
        'facebookUrl': _facebookUrlController.text.isEmpty ? null : _facebookUrlController.text,
        'instagramUrl': _instagramUrlController.text.isEmpty ? null : _instagramUrlController.text,
        'lineUrl': _lineUrlController.text.isEmpty ? null : _lineUrlController.text,
        'threadsUrl': _threadsUrlController.text.isEmpty ? null : _threadsUrlController.text,
      };

      BusinessCard savedCard;
      if (widget.card == null) {
        // 建立新名片
        savedCard = await cardProvider.createCard(cardData);
      } else {
        // 更新現有名片
        savedCard = await cardProvider.updateCard(widget.card!.id, cardData);
      }

      // 如果有選擇頭像，上傳頭像
      if (_avatarFile != null) {
        await cardProvider.uploadAvatar(savedCard.id, _avatarFile!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('名片儲存成功')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('儲存失敗: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? '新增名片' : '編輯名片'),
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveCard,
              child: Text('儲存', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: LoadingWidget())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 頭像
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
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
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey[600],
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // 基本資訊
                    Text(
                      '基本資訊',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: _nameController,
                      label: '姓名',
                      validator: (value) {
                        if (value?.isEmpty ?? true) return '請輸入姓名';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: _companyController,
                      label: '公司',
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: _positionController,
                      label: '職位',
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: _phoneController,
                      label: '電話',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: '電子郵件',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: _addressController,
                      label: '地址',
                      maxLines: 2,
                    ),
                    SizedBox(height: 20),
                    
                    // 樣式選擇
                    Text(
                      '名片樣式',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: Text('預設'),
                          value: 'default',
                          groupValue: _selectedStyle,
                          onChanged: (value) {
                            setState(() => _selectedStyle = value!);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('簡約'),
                          value: 'minimal',
                          groupValue: _selectedStyle,
                          onChanged: (value) {
                            setState(() => _selectedStyle = value!);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('粉色'),
                          value: 'pink_card',
                          groupValue: _selectedStyle,
                          onChanged: (value) {
                            setState(() => _selectedStyle = value!);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('薄荷'),
                          value: 'mint_card',
                          groupValue: _selectedStyle,
                          onChanged: (value) {
                            setState(() => _selectedStyle = value!);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    // 社群媒體
                    Text(
                      '社群媒體',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Facebook'),
                      value: _facebook,
                      onChanged: (value) {
                        setState(() => _facebook = value!);
                      },
                    ),
                    if (_facebook) ...[
                      AppTextField(
                        controller: _facebookUrlController,
                        label: 'Facebook URL',
                      ),
                      SizedBox(height: 8),
                    ],
                    CheckboxListTile(
                      title: Text('Instagram'),
                      value: _instagram,
                      onChanged: (value) {
                        setState(() => _instagram = value!);
                      },
                    ),
                    if (_instagram) ...[
                      AppTextField(
                        controller: _instagramUrlController,
                        label: 'Instagram URL',
                      ),
                      SizedBox(height: 8),
                    ],
                    CheckboxListTile(
                      title: Text('Line'),
                      value: _line,
                      onChanged: (value) {
                        setState(() => _line = value!);
                      },
                    ),
                    if (_line) ...[
                      AppTextField(
                        controller: _lineUrlController,
                        label: 'Line URL',
                      ),
                      SizedBox(height: 8),
                    ],
                    CheckboxListTile(
                      title: Text('Threads'),
                      value: _threads,
                      onChanged: (value) {
                        setState(() => _threads = value!);
                      },
                    ),
                    if (_threads) ...[
                      AppTextField(
                        controller: _threadsUrlController,
                        label: 'Threads URL',
                      ),
                      SizedBox(height: 8),
                    ],
                    SizedBox(height: 20),
                    
                    // 隱私設定
                    Text(
                      '隱私設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('公開名片'),
                      subtitle: Text('其他人可以搜尋到這張名片'),
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() => _isPublic = value);
                      },
                    ),
                    SizedBox(height: 40),
                    
                    // 儲存按鈕
                    AppButton(
                      text: widget.card == null ? '建立名片' : '更新名片',
                      onPressed: _saveCard,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}