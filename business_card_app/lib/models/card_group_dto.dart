class CardGroupDto {
  final int groupId;
  final String groupName;

  CardGroupDto({required this.groupId, required this.groupName});

  factory CardGroupDto.fromJson(Map<String, dynamic> json) {
    return CardGroupDto(groupId: json['groupId'], groupName: json['groupName']);
  }
}
