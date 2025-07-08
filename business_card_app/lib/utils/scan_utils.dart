import '../services/card_group_service.dart';

Future<void> scanAndAddCardToDefaultGroup(int cardId) async {
  final service = CardGroupService();

  // 先檢查這張卡是否已經加入群組
  final existingGroup = await service.getGroupOfCardForUser(cardId);

  if (existingGroup == null) {
    final myGroups = await service.getGroupsByUser();
    final defaultGroup = myGroups.firstWhere((g) => g.name != '全部');
    await service.addCardToGroup(cardId, defaultGroup.id);
  }
}
