// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../widgets/card/card_item.dart';
import '../../widgets/common/app_text_field.dart';
import '../../models/card.dart';
import '../../core/constants.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<BusinessCard> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final results = await cardProvider.searchPublicCards(_searchController.text.trim());
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜尋失敗: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadAllPublicCards() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final results = await cardProvider.searchPublicCards('');
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入失敗: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜尋公開名片'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜尋欄
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchController,
                    label: '搜尋名稱或公司',
                    onSubmitted: (_) => _search(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: Text('搜尋'),
                ),
              ],
            ),
          ),
          
          // 顯示全部按鈕
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                TextButton.icon(
                  icon: Icon(Icons.list),
                  label: Text('顯示全部公開名片'),
                  onPressed: _loadAllPublicCards,
                ),
              ],
            ),
          ),
          
          // 搜尋結果
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '搜尋公開名片',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '輸入名稱或公司名稱來搜尋',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '沒有找到結果',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '請嘗試其他關鍵字',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final card = _searchResults[index];
                              return CardItem(
                                card: card,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.cardDetail,
                                    arguments: card.id,
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}