import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../widgets/card/card_preview.dart';
import '../../widgets/card/qr_code_widget.dart';
import '../../models/card.dart';
import '../../core/constants.dart';

class CardDetailScreen extends StatefulWidget {
  final int cardId;
  
  CardDetailScreen({required this.cardId});

  @override
  _CardDetailScreenState createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  BusinessCard? card;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final loadedCard = await cardProvider.getCardById(widget.cardId);
      setState(() {
        card = loadedCard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入名片失敗: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('刪除名片'),
        content: Text('確定要刪除這張名片嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final cardProvider = Provider.of<CardProvider>(context, listen: false);
        await cardProvider.deleteCard(widget.cardId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('名片已刪除')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刪除失敗: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _togglePublic() async {
    if (card == null) return;
    
    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      await cardProvider.updatePublicStatus(card!.id, !card!.isPublic);
      
      setState(() {
        card = card!.copyWith(isPublic: !card!.isPublic);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(card!.isPublic ? '名片已設為公開' : '名片已設為私人'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失敗: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('名片詳情'),
        elevation: 0,
        actions: [
          if (card != null) ...[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editCard,
                  arguments: card,
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'public':
                    _togglePublic();
                    break;
                  case 'delete':
                    _deleteCard();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'public',
                  child: Row(
                    children: [
                      Icon(card!.isPublic ? Icons.visibility_off : Icons.visibility),
                      SizedBox(width: 8),
                      Text(card!.isPublic ? '設為私人' : '設為公開'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('刪除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : card == null
              ? Center(child: Text('找不到名片'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // 名片預覽
                      CardPreview(card: card!),
                      
                      // 功能按鈕
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.qr_code),
                                label: Text('顯示QR碼'),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('名片QR碼'),
                                      content: Container(
                                        width: 250,
                                        height: 250,
                                        child: QRCodeWidget(data: card!.id.toString()),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('關閉'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.share),
                                label: Text('分享'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('分享功能開發中')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 名片資訊
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '名片資訊',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow('姓名', card!.name),
                            _buildInfoRow('公司', card!.company),
                            _buildInfoRow('職位', card!.position),
                            _buildInfoRow('電話', card!.phone),
                            _buildInfoRow('信箱', card!.email),
                            _buildInfoRow('地址', card!.address),
                            _buildInfoRow('狀態', card!.isPublic ? '公開' : '私人'),
                            
                            // 社群媒體
                            if ((card!.facebook == true) || 
                                (card!.instagram == true) || 
                                (card!.line == true) || 
                                (card!.threads == true)) ...[
                              SizedBox(height: 16),
                              Text(
                                '社群媒體',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  if (card!.facebook == true) 
                                    _buildSocialIcon(Icons.facebook, 'Facebook'),
                                  if (card!.instagram == true) 
                                    _buildSocialIcon(Icons.camera_alt, 'Instagram'),
                                  if (card!.line == true) 
                                    _buildSocialIcon(Icons.chat, 'Line'),
                                  if (card!.threads == true) 
                                    _buildSocialIcon(Icons.alternate_email, 'Threads'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}