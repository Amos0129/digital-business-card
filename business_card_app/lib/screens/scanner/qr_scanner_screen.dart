// lib/screens/scanner/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing) {
        _processQRData(scanData.code);
      }
    });
  }

  Future<void> _processQRData(String? qrData) async {
    if (qrData == null || _isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // 暫停相機
      await controller?.pauseCamera();
      
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
              Text('公司: ${card.company}'),
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
      // 恢復相機
      await controller?.resumeCamera();
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

    final selectedGroup = await showDialog<BusinessGroup>(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('掃描QR碼'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () {
              controller?.toggleFlash();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
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
                    _isProcessing ? '處理中...' : '將QR碼對準掃描框',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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
