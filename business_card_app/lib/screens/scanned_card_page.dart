import 'package:flutter/material.dart';
import '../widgets/scanned_card.dart';
import '../services/card_group_service.dart';

class ScannedCardPage extends StatefulWidget {
  final ScannedCard scannedCard;

  const ScannedCardPage({super.key, required this.scannedCard});

  @override
  State<ScannedCardPage> createState() => _ScannedCardPageState();
}

class _ScannedCardPageState extends State<ScannedCardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _showGroupSelectionSheet(context));
  }

  Future<void> _showGroupSelectionSheet(BuildContext context) async {
    try {
      final service = CardGroupService();
      final groups = await service.getGroupsByUser();

      final validGroups = groups.where((g) => g.name != '全部').toList();

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '選擇要加入的群組',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...validGroups.map(
                (group) => ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(group.name),
                  onTap: () async {
                    Navigator.pop(context); // 關 bottom sheet

                    await service.addCardToGroup(
                      widget.scannedCard.cardId,
                      group.id,
                    );

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已加入 ${group.name}')),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('讀取群組失敗: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('掃描結果'),
        backgroundColor: const Color(0xFF4A6CFF),
      ),
      body: SingleChildScrollView(child: widget.scannedCard),
    );
  }
}
