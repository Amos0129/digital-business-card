class CardGroupDto {
  final int groupId;
  final String groupName;
  final String? avatarUrl;

  CardGroupDto({
    required this.groupId,
    required this.groupName,
    this.avatarUrl,
  });

  factory CardGroupDto.fromJson(Map<String, dynamic> json) {
    return CardGroupDto(
      groupId: json['groupId'],
      groupName: json['groupName'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
