// lib/screens/cards/cards_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/card_provider.dart';
import '../../widgets/card_item.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/ios_field.dart';
import '../cards/card_form_screen.dart';
import '../cards/card_detail_screen.dart';
import '../../models/card.dart';

class CardsScreen extends StatefulWidget {
  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    await Future.wait([
      cardProvider.loadMyCards(),
      cardProvider.loadPublicCards(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(),
          _buildSearchBar(),
          _buildTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyCardsTab(),
            _buildPublicCardsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: AppTheme.backgroundColor,
      border: null,
      largeTitle: const Text('名片'),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToCreateCard(),
        child: const Icon(
          CupertinoIcons.add,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: IOSSearchField(
          placeholder: _tabController.index == 0 ? '搜尋我的名片' : '搜尋公開名片',
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
            if (_tabController.index == 1) {
              _searchPublicCards(value);
            }
          },
          onClear: () {
            setState(() {
              _searchQuery = '';
            });
            if (_tabController.index == 1) {
              _searchPublicCards('');
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.separatorColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
        ),
        child: CupertinoSlidingSegmentedControl<int>(
          groupValue: _tabController.index,
          onValueChanged: (value) {
            if (value != null) {
              _tabController.animateTo(value);
              setState(() {});
            }
          },
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '我的名片',
                style: TextStyle(fontSize: 16),
              ),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '公開名片',
                style: TextStyle(fontSize: 16),
              ),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildMyCardsTab() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        final filteredCards = _filterMyCards(cardProvider.myCards);

        if (cardProvider.isLoading) {
          return const LoadingView();
        }

        if (cardProvider.myCards.isEmpty) {
          return EmptyView.noCards(
            onCreateCard: () => _navigateToCreateCard(),
          );
        }

        if (filteredCards.isEmpty && _searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.search,
                  size: 64,
                  color: AppTheme.secondaryTextColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '找不到相關名片',
                  style: AppTheme.title3.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '試試其他關鍵字',
                  style: AppTheme.subheadline.copyWith(
                    color: AppTheme.tertiaryTextColor,
                  ),
                ),
              ],
            ),
          );
        }

        return PullToRefreshLoading(
          isRefreshing: cardProvider.isLoading,
          onRefresh: () => cardProvider.loadMyCards(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCards.length,
            itemBuilder: (context, index) {
              final card = filteredCards[index];
              return CardItem(
                card: card,
                onTap: () => _navigateToCardDetail(card.id!),
                showActions: true,
                onEdit: () => _navigateToEditCard(card),
                onDelete: () => _showDeleteDialog(card.id!),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPublicCardsTab() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        if (cardProvider.isLoading) {
          return const LoadingView();
        }

        if (cardProvider.publicCards.isEmpty) {
          return EmptyView.noSearchResults();
        }

        return PullToRefreshLoading(
          isRefreshing: cardProvider.isLoading,
          onRefresh: () => cardProvider.loadPublicCards(query: _searchQuery),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cardProvider.publicCards.length,
            itemBuilder: (context, index) {
              final card = cardProvider.publicCards[index];
              return CardItem(
                card: card,
                onTap: () => _navigateToCardDetail(card.id!, isPublic: true),
              );
            },
          ),
        );
      },
    );
  }

  List<BusinessCard> _filterMyCards(List<BusinessCard> cards) {
    if (_searchQuery.isEmpty) return cards;

    return cards.where((card) {
      return card.name.toLowerCase().contains(_searchQuery) ||
             (card.company?.toLowerCase().contains(_searchQuery) ?? false) ||
             (card.position?.toLowerCase().contains(_searchQuery) ?? false) ||
             (card.email?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  void _searchPublicCards(String query) {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    cardProvider.loadPublicCards(query: query.isEmpty ? null : query);
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

  void _navigateToCardDetail(int cardId, {bool isPublic = false}) {
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

    if (mounted) {
      if (success) {
        // 顯示成功訊息
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('刪除成功'),
            content: const Text('名片已成功刪除'),
            actions: [
              CupertinoDialogAction(
                child: const Text('確定'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        // 顯示錯誤訊息
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('刪除失敗'),
            content: const Text('無法刪除名片，請稍後再試'),
            actions: [
              CupertinoDialogAction(
                child: const Text('確定'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }
}