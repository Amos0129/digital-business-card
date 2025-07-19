// lib/screens/cards/my_cards_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/card_provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/card_item.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/ios_field.dart';
import '../../widgets/ios_button.dart';
import '../cards/card_form_screen.dart';
import '../cards/card_detail_screen.dart';
import '../../models/card.dart';
import '../../models/group.dart';

class MyCardsScreen extends StatefulWidget {
  @override
  _MyCardsScreenState createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    await Future.wait([
      cardProvider.loadMyCards(),
      groupProvider.loadGroups(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchAndFilter(),
          _buildCardsList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: AppTheme.backgroundColor,
      border: null,
      largeTitle: const Text('我的名片'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showSortOptions(),
            child: const Icon(
              CupertinoIcons.sort_down,
              size: 24,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _navigateToCreateCard(),
            child: const Icon(
              CupertinoIcons.add,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 搜尋列
            IOSSearchField(
              placeholder: '搜尋名片...',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // 群組篩選
            _buildGroupFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupFilter() {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        if (groupProvider.groups.isEmpty) {
          return const SizedBox();
        }

        return Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: groupProvider.groups.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFilterChip(
                  label: '全部',
                  isSelected: _selectedGroupId == null,
                  onTap: () {
                    setState(() {
                      _selectedGroupId = null;
                    });
                  },
                );
              }

              final group = groupProvider.groups[index - 1];
              return _buildFilterChip(
                label: group.name,
                isSelected: _selectedGroupId == group.id,
                onTap: () {
                  setState(() {
                    _selectedGroupId = group.id;
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.separatorColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected 
                  ? CupertinoColors.white 
                  : AppTheme.textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        if (cardProvider.isLoading) {
          return const SliverToBoxAdapter(
            child: LoadingView(),
          );
        }

        final filteredCards = _filterCards(cardProvider.myCards);

        if (cardProvider.myCards.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyView.noCards(
              onCreateCard: () => _navigateToCreateCard(),
            ),
          );
        }

        if (filteredCards.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildNoResultsView(),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildResultsHeader(filteredCards.length),
                );
              }

              final card = filteredCards[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CardItem(
                  card: card,
                  onTap: () => _navigateToCardDetail(card.id!),
                  showActions: true,
                  onEdit: () => _navigateToEditCard(card),
                  onDelete: () => _showDeleteDialog(card.id!),
                ),
              );
            },
            childCount: filteredCards.length + 1,
          ),
        );
      },
    );
  }

  Widget _buildResultsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$count 張名片',
        style: AppTheme.footnote.copyWith(
          color: AppTheme.secondaryTextColor,
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.search,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? '找不到相關名片' : '此群組沒有名片',
              style: AppTheme.title3.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty 
                  ? '試試其他關鍵字' 
                  : '將名片加入此群組來整理',
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.tertiaryTextColor,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              IOSButton.primary(
                text: '建立名片',
                onPressed: () => _navigateToCreateCard(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<BusinessCard> _filterCards(List<BusinessCard> cards) {
    var filteredCards = cards;

    // 按群組篩選
    if (_selectedGroupId != null) {
      // 這裡需要實作群組篩選邏輯
      // 實際實作時需要查詢 CardGroup 關聯
    }

    // 按搜尋關鍵字篩選
    if (_searchQuery.isNotEmpty) {
      filteredCards = filteredCards.where((card) {
        return card.name.toLowerCase().contains(_searchQuery) ||
               (card.company?.toLowerCase().contains(_searchQuery) ?? false) ||
               (card.position?.toLowerCase().contains(_searchQuery) ?? false) ||
               (card.email?.toLowerCase().contains(_searchQuery) ?? false) ||
               (card.phone?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    return filteredCards;
  }

  void _showSortOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('排序方式'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作按名稱排序
            },
            child: const Text('按姓名排序'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作按公司排序
            },
            child: const Text('按公司排序'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作按建立時間排序
            },
            child: const Text('按建立時間排序'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作按最近使用排序
            },
            child: const Text('按最近使用排序'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  void _navigateToCreateCard() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const CardFormScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  void _navigateToEditCard(BusinessCard card) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => CardFormScreen(card: card),
      ),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  void _navigateToCardDetail(int cardId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => CardDetailScreen(cardId: cardId),
      ),
    );
  }

  void _showDeleteDialog(int cardId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('刪除名片'),
        content: const Text('確定要刪除這張名片嗎？此操作無法復原。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => _deleteCard(cardId),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _deleteCard(int cardId) async {
    Navigator.pop(context); // 關閉對話框

    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final success = await cardProvider.deleteCard(cardId);

    if (mounted && success) {
      _loadData();
    }
  }
}