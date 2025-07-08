import 'package:flutter/material.dart';
import '../utils/scan_dialog.dart';
import '../utils/qr_share_utils.dart';
import '../models/unified_card.dart';
import '../services/card_service.dart';
import '../models/card_response.dart';
import '../services/card_group_service.dart';
import '../utils/app_dialog.dart';
import '../screens/card_detail_page.dart';

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
                onTap: () {
                  showScannerDialog(context, (scannedData) async {
                    final cardId = int.tryParse(scannedData);
                    final cardGroupService = CardGroupService();
                    if (cardId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('無效的 QRCode')),
                      );
                      return;
                    }

                    try {
                      final cardService = CardService();
                      final card = await cardService.getCardById(cardId);

                      // ✅ 拿到目前使用者的群組列表（排除「全部」）
                      final myGroups = await cardGroupService.getGroupsByUser();
                      final selectableGroups = myGroups
                          .where((g) => g.name != '全部')
                          .toList();

                      if (selectableGroups.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('尚未建立可加入的群組')),
                        );
                        return;
                      }

                      // ✅ 顯示選單讓使用者選一個群組加入
                      showAppDialog(
                        context: context,
                        type: AppDialogType.selectList,
                        title: '選擇加入的群組',
                        options: selectableGroups.map((g) => g.name).toList(),
                        onOptionSelected: (selectedName) async {
                          final selectedGroup = selectableGroups.firstWhere(
                            (g) => g.name == selectedName,
                          );

                          await cardGroupService.addCardToGroup(
                            cardId,
                            selectedGroup.id,
                          );

                          // ✅ 打包 UnifiedCard 後跳轉頁面
                          final unifiedCard = UnifiedCard(
                            id: card.id.toString(),
                            cardId: card.id,
                            name: card.name,
                            phone: card.phone,
                            email: card.email,
                            company: card.company,
                            address: card.address,
                            style: card.style,
                            hasFb: card.facebook,
                            hasIg: card.instagram,
                            hasLine: card.line,
                            hasThreads: card.threads,
                            group: selectedGroup.name,
                            groupId: selectedGroup.id,
                          );

                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardDetailPage(card: unifiedCard),
                            ),
                          );
                        },
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('讀取失敗: $e')));
                    }
                  });
                },
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
