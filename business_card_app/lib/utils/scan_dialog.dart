import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/qr_share_utils.dart';
import '../models/unified_card.dart';
import '../models/card_response.dart';

Future<String?> showScanDialog(BuildContext context, {CardResponse? card}) {
  final controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          // 📷 掃描器
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final value = capture.barcodes.first.rawValue;
              if (value != null) {
                Navigator.pop(context, value); // ✅ 把值傳回去
              }
            },
          ),

          // 🎯 掃描框
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF4A6CFF), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 48, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      '請將名片對準框內進行掃描',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ❌ 關閉按鈕
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 🧭 我的 QR 碼按鈕
          if (card != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text('我的 QR 碼'),
                  onPressed: () {
                    showQrShareDialog(
                      context,
                      UnifiedCard(
                        id: card.id.toString(),
                        name: card.name,
                        phone: card.phone,
                        email: card.email,
                        company: card.company,
                        address: card.address,
                        avatarUrl: null,
                        hasFb: card.facebook,
                        hasIg: card.instagram,
                        hasLine: card.line,
                        hasThreads: card.threads,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
