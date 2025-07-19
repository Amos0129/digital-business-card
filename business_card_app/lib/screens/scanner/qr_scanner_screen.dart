// lib/screens/scanner/qr_scanner_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../widgets/ios_button.dart';
import '../cards/card_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  
  bool _isScanning = true;
  bool _flashOn = false;
  bool _hasPermission = false;
  String? _scannedData;
  
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _requestPermission();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scanLineController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  Future<void> _requestPermission() async {
    // 模擬請求相機權限
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _hasPermission = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // 相機預覽區域
          _buildCameraPreview(),
          
          // 覆蓋層UI
          _buildOverlay(),
          
          // 頂部控制列
          _buildTopControls(),
          
          // 底部控制列
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_hasPermission) {
      return _buildPermissionView();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CupertinoColors.systemGrey.withOpacity(0.3),
            CupertinoColors.systemGrey.withOpacity(0.5),
            CupertinoColors.systemGrey.withOpacity(0.3),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          '相機預覽\n(實際使用時會顯示相機畫面)',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPermissionView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: CupertinoColors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.camera_fill,
              size: 80,
              color: CupertinoColors.white.withOpacity(0.8),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '需要相機權限',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '請允許存取相機來掃描 QR Code',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            IOSButton.primary(
              text: '授予權限',
              onPressed: () => _requestPermission(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    if (!_hasPermission) return const SizedBox();

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // 半透明遮罩
          Container(
            color: CupertinoColors.black.withOpacity(0.5),
          ),
          
          // 掃描框
          Center(
            child: _buildScanFrame(),
          ),
          
          // 掃描線
          Center(
            child: _buildScanLine(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanFrame() {
    return Container(
      width: 250,
      height: 250,
      child: Stack(
        children: [
          // 透明中心區域
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.white.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
          ),
          
          // 四角邊框
          ..._buildCornerBorders(),
          
          // 脈衝動畫圓圈
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 220 * _pulseAnimation.value,
                  height: 220 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBorders() {
    return [
      // 左上角
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppTheme.primaryColor, width: 4),
              left: BorderSide(color: AppTheme.primaryColor, width: 4),
            ),
          ),
        ),
      ),
      
      // 右上角
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppTheme.primaryColor, width: 4),
              right: BorderSide(color: AppTheme.primaryColor, width: 4),
            ),
          ),
        ),
      ),
      
      // 左下角
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.primaryColor, width: 4),
              left: BorderSide(color: AppTheme.primaryColor, width: 4),
            ),
          ),
        ),
      ),
      
      // 右下角
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.primaryColor, width: 4),
              right: BorderSide(color: AppTheme.primaryColor, width: 4),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildScanLine() {
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          child: Stack(
            children: [
              Positioned(
                top: 200 * _scanLineAnimation.value - 1,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.0),
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 返回按鈕
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  CupertinoIcons.back,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            
            // 標題
            Text(
              'QR Code 掃描',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
            
            // 手電筒按鈕
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _toggleFlash(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _flashOn 
                      ? AppTheme.primaryColor 
                      : CupertinoColors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  _flashOn ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.black.withOpacity(0.0),
                CupertinoColors.black.withOpacity(0.7),
                CupertinoColors.black.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 提示文字
              Text(
                '將 QR Code 對準框內進行掃描',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // 操作按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomButton(
                    icon: CupertinoIcons.photo,
                    label: '相簿',
                    onTap: () => _pickFromGallery(),
                  ),
                  
                  _buildBottomButton(
                    icon: CupertinoIcons.qrcode,
                    label: '我的 QR',
                    onTap: () => _showMyQR(),
                  ),
                  
                  _buildBottomButton(
                    icon: CupertinoIcons.textformat,
                    label: '手動輸入',
                    onTap: () => _manualInput(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              color: CupertinoColors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
    
    // 模擬手電筒切換
    HapticFeedback.lightImpact();
  }

  void _pickFromGallery() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('從相簿選擇'),
        content: const Text('選擇包含 QR Code 的圖片'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作從相簿選擇功能
              _simulateQRDetection('gallery_qr_code_data');
            },
            child: const Text('選擇'),
          ),
        ],
      ),
    );
  }

  void _showMyQR() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              '我的 QR Code',
              style: AppTheme.title2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // QR Code 預覽
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.separatorColor),
              ),
              child: const Center(
                child: Text(
                  'QR Code\n(我的名片)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: IOSButton.secondary(
                    text: '分享',
                    icon: CupertinoIcons.share,
                    onPressed: () {
                      Navigator.pop(context);
                      // 實作分享功能
                    },
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: IOSButton.primary(
                    text: '儲存',
                    icon: CupertinoIcons.download_circle,
                    onPressed: () {
                      Navigator.pop(context);
                      // 實作儲存功能
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _manualInput() {
    final controller = TextEditingController();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('手動輸入'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            const Text('請輸入 QR Code 內容或名片連結'),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: controller,
              placeholder: '貼上連結或輸入內容',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.trim().isNotEmpty) {
                _processQRData(controller.text.trim());
              }
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _simulateQRDetection(String data) {
    // 模擬QR碼掃描成功
    HapticFeedback.notificationFeedback(NotificationFeedbackType.success);
    
    setState(() {
      _isScanning = false;
      _scannedData = data;
    });

    _processQRData(data);
  }

  void _processQRData(String data) {
    // 判斷QR碼類型並處理
    if (data.contains('card_id=')) {
      // 名片QR碼
      final cardId = _extractCardId(data);
      if (cardId != null) {
        _navigateToCard(cardId);
      }
    } else if (data.startsWith('http')) {
      // 網址
      _showUrlDialog(data);
    } else {
      // 一般文字
      _showTextDialog(data);
    }
  }

  int? _extractCardId(String data) {
    final regex = RegExp(r'card_id=(\d+)');
    final match = regex.firstMatch(data);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  void _navigateToCard(int cardId) {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (_) => CardDetailScreen(cardId: cardId),
      ),
    );
  }

  void _showUrlDialog(String url) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('掃描結果'),
        content: Column(
          children: [
            const Text('偵測到網址：'),
            const SizedBox(height: 8),
            Text(
              url,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('關閉'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作開啟網址功能
            },
            child: const Text('開啟'),
          ),
        ],
      ),
    );
  }

  void _showTextDialog(String text) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('掃描結果'),
        content: Column(
          children: [
            const Text('掃描到的內容：'),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('關閉'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: text));
              // 顯示複製成功提示
            },
            child: const Text('複製'),
          ),
        ],
      ),
    );
  }
}