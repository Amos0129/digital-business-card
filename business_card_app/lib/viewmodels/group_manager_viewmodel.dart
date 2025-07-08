import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupManagerViewModel extends ChangeNotifier {
  final GroupService _groupService;
  final List<GroupModel> _groups = [];
  final List<String> _protected = ['客戶', '朋友', '家人'];
  final TextEditingController controller = TextEditingController();

  GroupManagerViewModel({GroupService? groupService})
    : _groupService = groupService ?? GroupService();

  List<GroupModel> get groups => _groups;

  List<GroupModel> get sortedGroups => [
    ..._groups.where((g) => _protected.contains(g.name)),
    ..._groups.where((g) => !_protected.contains(g.name)),
  ];

  Future<void> loadGroups() async {
    final fetched = await _groupService.getGroupsByUser();
    _groups
      ..clear()
      ..addAll(fetched);
    notifyListeners();
  }

  Future<void> addGroup(String name) async {
    if (name.trim().isEmpty ||
        _protected.contains(name) ||
        _groups.any((g) => g.name == name)) {
      throw Exception('無效或重複的群組名稱');
    }
    final newGroup = await _groupService.createGroup(name);
    _groups.add(newGroup);
    notifyListeners();
  }

  Future<void> renameGroup(GroupModel group, String newName) async {
    await _groupService.renameGroup(group.id, newName);
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = GroupModel(id: group.id, name: newName);
      notifyListeners();
    }
  }

  Future<void> deleteGroup(GroupModel group) async {
    await _groupService.deleteGroup(group.id);
    _groups.removeWhere((g) => g.id == group.id);
    notifyListeners();
  }

  bool isProtected(String name) => _protected.contains(name);
}
