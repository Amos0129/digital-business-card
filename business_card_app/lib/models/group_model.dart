class GroupModel {
  final int id;
  final String name;

  GroupModel({required this.id, required this.name});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(id: json['id'], name: json['name']);
  }
}

class CardGroupModel {
  final int id;
  final int cardId;
  final int groupId;
  final GroupModel group;

  CardGroupModel({
    required this.id,
    required this.cardId,
    required this.groupId,
    required this.group,
  });

  factory CardGroupModel.fromJson(Map<String, dynamic> json) {
    return CardGroupModel(
      id: json['id'],
      cardId: json['cardId'],
      groupId: json['groupId'],
      group: GroupModel.fromJson(json['group']),
    );
  }
}
