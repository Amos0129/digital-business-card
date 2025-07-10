import 'package:flutter/material.dart';
import '../utils/scan_dialog.dart';
import '../services/card_service.dart';
import '../services/card_group_service.dart';
import '../utils/app_dialog.dart';
import '../models/unified_card.dart';
import '../screens/card_detail_page.dart';

class ScanService {
  static Future<void> scanAndNavigate(BuildContext context) async {
    final scannedId = await showScanDialog(context);
    if (scannedId == null || !RegExp(r'^\d+$').hasMatch(scannedId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR Code 資料無效，請掃描正確的名片 ID')));
      return;
    }

    final int cardId = int.parse(scannedId);

    final cardService = CardService();
    final cardGroupService = CardGroupService();

    try {
      final card = await cardService.getCardById(cardId);
      final groups = await cardGroupService.getGroupsByUser();
      final selectableGroups = groups.where((g) => g.name != '全部').toList();

      if (selectableGroups.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('請先建立群組')));
        return;
      }

      showAppDialog(
        context: context,
        type: AppDialogType.selectList,
        title: '加入群組',
        options: selectableGroups.map((g) => g.name).toList(),
        onOptionSelected: (selectedName) async {
          final selectedGroup = selectableGroups.firstWhere(
            (g) => g.name == selectedName,
          );

          final success = await safeAddCardToGroup(
            cardId: cardId,
            groupId: selectedGroup.id,
            context: context,
            cardGroupService: cardGroupService,
          );

          if (!success) return;

          final unifiedCard = card.toUnifiedCard().copyWith(
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
  }

  static Future<bool> safeAddCardToGroup({
    required int cardId,
    required int groupId,
    required BuildContext context,
    required CardGroupService cardGroupService,
  }) async {
    final existingGroup = await cardGroupService.getGroupOfCardForUser(cardId);

    if (existingGroup != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('此名片已在群組「${existingGroup.groupName}」中')),
      );
      return false;
    }

    await cardGroupService.addCardToGroup(cardId, groupId);
    return true;
  }
}
