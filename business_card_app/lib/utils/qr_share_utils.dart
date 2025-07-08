import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';

import '../models/unified_card.dart';

void showQrShareDialog(BuildContext context, UnifiedCard card) {
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
            QrImageView(
              data: card.id, // <-- 使用 UUID 當 QRCode 內容
              version: QrVersions.auto,
              size: 180,
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
                label: const Text("分享 QRCode 文字"),
                onPressed: () {
                  Share.share(card.id,); // 分享 UUID 字串
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
