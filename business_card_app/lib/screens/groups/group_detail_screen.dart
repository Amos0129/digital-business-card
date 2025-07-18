import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/card_provider.dart';
import '../../widgets/card/card_item.dart';
import '../../models/card.dart';
import '../../core/constants.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;
  
  GroupDetailScreen({required this.groupId});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  List<BusinessCard> cards = [];
  String groupName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupCards();
  }

  Future<void> _loadGroupCards() async {
    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      
      // 取得群組資訊
      final group = groupProvider.getGroupById(widget.groupId);
      
      // 取得群組內的名片
      final groupCards = await cardProvider.getCardsByGroup(widget.groupId);
      
      setState(() {
        groupName = group?.name ?? '未知群組';
        cards = groupCards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入失敗: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeCardFromGroup(BusinessCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('移除名片'),
        content: Text('確定要將「${card.name}」從群組中移除嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final cardProvider = Provider.of<CardProvider>(context, listen: false);
        await cardProvider.removeCardFromGroup(card.id, widget.groupId);
        
        setState(() {
          cards.removeWhere((c) => c.id == card.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('名片已移除')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('移除失敗: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '群組中沒有名片',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.qrScanner);
                        },
                        child: Text('掃描QR碼添加名片'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGroupCards,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return CardItem(
                        card: card,
                        showActions: true,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.cardDetail,
                            arguments: card.id,
                          );
                        },
                        onRemove: () => _removeCardFromGroup(card),
                      );
                    },
                  ),
                ),
    );
  }
}