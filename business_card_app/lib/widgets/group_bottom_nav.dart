import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_nav.dart';
import '../services/card_service.dart';
import '../services/card_group_service.dart';
import '../models/unified_card.dart';
import '../utils/scan_dialog.dart';
import '../viewmodels/card_group_viewmodel.dart';
import '../utils/app_dialog.dart';

class CardGroupBottomNav extends StatelessWidget {
  const CardGroupBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CardGroupViewModel>();
    final cardGroupService = CardGroupService();

    return BottomNav(
      currentIndex: 1,
      onTap: (index) {
        if (index == 1) return;
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case 2:
            showScannerDialog(context, (String result) async {
              final int? cardId = int.tryParse(result);
              if (cardId == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('QR Code 資料無效')));
                return;
              }

              try {
                final cardService = CardService();
                final card = await cardService.getCardById(cardId);

                // 取得使用者的群組（排除 '全部'）
                final groups = await cardGroupService.getGroupsByUser();
                final selectableGroups = groups
                    .where((g) => g.name != '全部')
                    .toList();

                if (selectableGroups.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('請先建立群組')));
                  return;
                }

                // 顯示選單讓使用者選群組
                showAppDialog(
                  context: context,
                  type: AppDialogType.selectList,
                  title: '加入群組',
                  options: selectableGroups.map((g) => g.name).toList(),
                  onOptionSelected: (selectedName) async {
                    final selectedGroup = selectableGroups.firstWhere(
                      (g) => g.name == selectedName,
                    );

                    await cardGroupService.addCardToGroup(
                      cardId,
                      selectedGroup.id,
                    );

                    vm.addCard(
                      UnifiedCard(
                        id: card.id.toString(),
                        name: card.name,
                        phone: card.phone,
                        email: card.email,
                        company: card.company,
                        address: card.address,
                        avatarUrl: null,
                        isScanned: true,
                        isPaperBased: false,
                        group: selectedGroup.name,
                        groupId: selectedGroup.id,
                        hasFb: card.facebook,
                        hasIg: card.instagram,
                        hasLine: card.line,
                        hasThreads: card.threads,
                        fbUrl: "https://facebook.com/${card.name}",
                        igUrl: "https://instagram.com/${card.name}",
                        lineUrl: "https://line.me/ti/p/${card.name}",
                        threadsUrl: "https://threads.net/${card.name}",
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已加入「${selectedGroup.name}」')),
                    );
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('找不到名片資料: $e')));
              }
            });
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
        }
      },
    );
  }
}
