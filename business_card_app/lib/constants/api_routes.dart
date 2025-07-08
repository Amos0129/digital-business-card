class ApiRoutes {
  static const String base = 'http://192.168.205.54:5566';

  // User APIs =================================================================
  static Uri getMe() => Uri.parse('$base/api/user/me');

  static Uri findByEmail(String email) =>
      Uri.parse('$base/api/user/by-email?email=$email');

  static Uri existsByEmail(String email) =>
      Uri.parse('$base/api/user/exists?email=$email');

  static Uri login() => Uri.parse('$base/api/user/login');

  static Uri register() => Uri.parse('$base/api/user/register');

  static Uri updateDisplayName(String name) =>
      Uri.parse('$base/api/user/display-name?name=$name');

  static Uri changePassword(String oldPw, String newPw) => Uri.parse(
    '$base/api/user/password?oldPassword=$oldPw&newPassword=$newPw',
  );

  // Card APIs ================================================================
  static Uri getCardById(int cardId) => Uri.parse('$base/api/cards/$cardId');

  static Uri updateCard(int cardId) => Uri.parse('$base/api/cards/$cardId');

  static Uri getMyCards() => Uri.parse('$base/api/cards/my');

  static Uri createCard() => Uri.parse('$base/api/cards');

  static Uri getPublicCardsByUser(int userId) =>
      Uri.parse('$base/api/cards/user/$userId/public');

  // Group APIs ================================================================
  static Uri createGroup(String name) =>
      Uri.parse('$base/api/group/create?name=$name');

  static Uri getUncategorizedGroup() =>
      Uri.parse('$base/api/group/uncategorized');

  static Uri renameGroup(int groupId, String newName) =>
      Uri.parse('$base/api/group/rename/$groupId?newName=$newName');

  static Uri deleteGroup(int groupId) => Uri.parse('$base/api/group/$groupId');

  // CardGroup APIs ============================================================
  static Uri getGroupsByUser() => Uri.parse('$base/api/group/by-user');

  static Uri getGroupOfCard(int cardId) =>
      Uri.parse('$base/api/card-group/user-group-of-card?cardId=$cardId');

  static Uri getCardsByGroup(int groupId) =>
      Uri.parse('$base/api/card-group/by-group/$groupId');

  static Uri changeCardGroup(int cardId, int groupId) =>
      Uri.parse('$base/api/card-group/change?cardId=$cardId&groupId=$groupId');

  static Uri addCardToGroup(int cardId, int groupId) =>
      Uri.parse('$base/api/card-group/add?cardId=$cardId&groupId=$groupId');

  static Uri removeCardFromGroup(int cardId, int groupId) =>
      Uri.parse('$base/api/card-group/remove?cardId=$cardId&groupId=$groupId');

  static Uri getMyCardGroups() => Uri.parse('$base/api/card-group/by-user');
}
