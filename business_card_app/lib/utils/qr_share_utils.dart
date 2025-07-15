import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../models/unified_card.dart';

void showQrShareDialog(BuildContext context, UnifiedCard card) {
  final GlobalKey qrKey = GlobalKey(); // ✅ 全域 Key 放最上面

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ 將 QRCode 包進 RepaintBoundary
            RepaintBoundary(
              key: qrKey,
              child: QrImageView(
                data: card.id,
                version: QrVersions.auto,
                size: 180,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(
                  CupertinoIcons.share_up,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text("分享 QRCode 圖片"),
                onPressed: () async {
                  final file = await _capturePng(qrKey);
                  await Share.shareXFiles([
                    XFile(file.path),
                  ], text: "這是我的名片 QRCode");
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<File> _capturePng(GlobalKey key) async {
  try {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/card_qr.png');
    await file.writeAsBytes(pngBytes);
    return file;
  } catch (e) {
    throw Exception('❌ 產生 QRCode 圖片失敗: $e');
  }
}
