import 'package:flutter/material.dart';
import '../utils/qr_share_utils.dart';
import '../models/unified_card.dart';
import '../models/card_response.dart';
import '../services/scan_service.dart';

class QRSection extends StatelessWidget {
  final bool hasProfile;
  final CardResponse? card;

  const QRSection({super.key, required this.hasProfile, required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // 🧾 左：顯示自己的 QR Code
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (!hasProfile) return;

                  final myCard = UnifiedCard(
                    id: card!.id.toString(), // 🔥 這裡放 ID 給掃描用
                    name: card!.name,
                    phone: card!.phone,
                    email: card!.email,
                    company: card!.company,
                    address: card!.address,
                    style: card!.style,
                    hasFb: card!.facebook,
                    hasIg: card!.instagram,
                    hasLine: card!.line,
                    hasThreads: card!.threads,
                  );

                  showQrShareDialog(context, myCard);
                },
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: hasProfile
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.qr_code_2,
                                size: 60,
                                color: Colors.black87,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "我的 QR 碼",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_circle_outline,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "新增名片",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 📷 右：掃描名片
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => ScanService.scanAndNavigate(context),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 48,
                        color: Colors.black54,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "掃描名片",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
