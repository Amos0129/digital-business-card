import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../providers/group_provider.dart';
import '../../models/card.dart';
import '../../models/group.dart';
import '../../core/constants.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  Future<void> _processQRData(String? qrData) async {
    if (qrData == null || _isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // 嘗試解析QR碼數據 (假設是名片ID)
      final cardId = int.tryParse(qrData);
      if (cardId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無效的QR碼')),
        );
        return;
      }

      // 取得名片資訊
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final card = await cardProvider.getCardById(cardId);
      
      if (card == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('找不到對應的名片')),
        );
        return;
      }

      // 顯示名片資訊並詢問是否要添加到群組
      final shouldAddToGroup = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('找到名片'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('姓名: ${card.name}'),
              if (card.company?.isNotEmpty == true)
                Text('公司: ${card.company}'),
              if (card.phone?.isNotEmpty == true)
                Text('電話: ${card.phone}'),
              SizedBox(height: 16),
              Text('要將此名片添加到群組嗎？'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('添加到群組'),
            ),
          ],
        ),
      );

      if (shouldAddToGroup == true) {
        await _selectGroupAndAddCard(card);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('處理QR碼失敗: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _selectGroupAndAddCard(BusinessCard card) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.loadGroups();
    
    if (groupProvider.groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請先建立群組')),
      );
      return;
    }

    final selectedGroup = await showDialog<CardGroup>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('選擇群組'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: groupProvider.groups.length,
            itemBuilder: (context, index) {
              final group = groupProvider.groups[index];
              return ListTile(
                title: Text(group.name),
                onTap: () => Navigator.pop(context, group),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
        ],
      ),
    );

    if (selectedGroup != null) {
      try {
        final cardProvider = Provider.of<CardProvider>(context, listen: false);
        await cardProvider.addCardToGroup(card.id, selectedGroup.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('名片已添加到「${selectedGroup.name}」')),
        );
        
        // 跳轉到群組詳情頁面
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.groupDetail,
          arguments: selectedGroup.id,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失敗: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showManualInputDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('手動輸入名片ID'),
        content: TextField(
          controller: _manualInputController,
          decoration: InputDecoration(
            labelText: '名片ID',
            hintText: '請輸入名片ID',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, _manualInputController.text);
            },
            child: Text('確定'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _processQRData(result);
      _manualInputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('掃描QR碼'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.keyboard),
            onPressed: _showManualInputDialog,
            tooltip: '手動輸入',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '模擬QR碼掃描器',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '請使用右上角的手動輸入功能',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing)
                    CircularProgressIndicator()
                  else
                    Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                  SizedBox(height: 16),
                  Text(
                    _isProcessing ? '處理中...' : '點擊右上角按鈕手動輸入名片ID',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.keyboard),
                    label: Text('手動輸入名片ID'),
                    onPressed: _showManualInputDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}