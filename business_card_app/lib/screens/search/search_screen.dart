// lib/screens/search/search_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/card_provider.dart';
import '../../widgets/card_item.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/ios_field.dart';
import '../../widgets/ios_button.dart';
import '../cards/card_detail_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import '../../models/card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedFilter = '全部';
  
  final List<String> _searchFilters = [
    '全部',
    '姓名',
    '公司',
    '職位',
    '行業',
  ];

  final List<String> _recentSearches = [
    '軟體工程師',
    '設計師',
    '產品經理',
    '業務',
  ];

  final List<String> _hotKeywords = [
    '科技業',
    '新創公司',
    '金融業',
    '醫療',
    '教育',
    '行銷',
    '創意',
    '顧問',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    await cardProvider.loadPublicCards();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchSection(),
          if (_searchQuery.isEmpty) ...[
            _buildQuickActions(),
            _buildRecentSearches(),
            _buildHotKeywords(),
            _buildRecommendations(),
          ] else
            _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: AppTheme.backgroundColor,
      border: null,
      largeTitle: const Text('探索'),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToQRScanner(),
        child: const Icon(
          CupertinoIcons.qrcode_viewfinder,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 搜尋列
            IOSSearchField(
              placeholder: '搜尋名片、公司或職位...',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _performSearch(value);
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
                _loadInitialData();
              },
            ),
            
            const SizedBox(height: 12),
            
            // 搜尋篩選器
            if (_searchQuery.isNotEmpty) _buildSearchFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _searchFilters.length,
        itemBuilder: (context, index) {
          final filter = _searchFilters[index];
          final isSelected = _selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _selectedFilter = filter;
                });
                _performSearch(_searchQuery);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected 
                      ? null 
                      : Border.all(color: AppTheme.separatorColor),
                ),
                child: Text(
                  filter,
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
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
            boxShadow: AppTheme.iosCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '快速動作',
                style: AppTheme.headline.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: CupertinoIcons.qrcode_viewfinder,
                      title: 'QR 掃描',
                      subtitle: '掃描名片',
                      color: AppTheme.primaryColor,
                      onTap: () => _navigateToQRScanner(),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: CupertinoIcons.location,
                      title: '附近的人',
                      subtitle: '探索周邊',
                      color: AppTheme.successColor,
                      onTap: () => _searchNearby(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.footnote.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTheme.caption2.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近搜尋',
                  style: AppTheme.title3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                IOSButton.plain(
                  text: '清除',
                  onPressed: () => _clearRecentSearches(),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return _buildSearchChip(
                  text: search,
                  icon: CupertinoIcons.clock,
                  onTap: () => _performSearchWithQuery(search),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotKeywords() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '熱門關鍵字',
              style: AppTheme.title3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hotKeywords.map((keyword) {
                return _buildSearchChip(
                  text: keyword,
                  icon: CupertinoIcons.flame,
                  onTap: () => _performSearchWithQuery(keyword),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.separatorColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppTheme.footnote,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        if (cardProvider.isLoading) {
          return const SliverToBoxAdapter(child: LoadingView());
        }

        final recommendedCards = cardProvider.publicCards.take(5).toList();

        if (recommendedCards.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '推薦名片',
                  style: AppTheme.title3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Column(
                  children: recommendedCards.map((card) {
                    return CardItem(
                      card: card,
                      onTap: () => _navigateToCardDetail(card.id!),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        if (_isSearching) {
          return const SliverToBoxAdapter(child: LoadingView());
        }

        if (cardProvider.publicCards.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildNoResultsView(),
          );
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 搜尋結果標題
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '找到 ${cardProvider.publicCards.length} 個結果',
                      style: AppTheme.footnote.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    
                    IOSButton.plain(
                      text: '篩選',
                      onPressed: () => _showFilterOptions(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 結果列表
                Column(
                  children: cardProvider.publicCards.map((card) {
                    return CardItem(
                      card: card,
                      onTap: () => _navigateToCardDetail(card.id!),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.secondaryTextColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                CupertinoIcons.search,
                size: 40,
                color: AppTheme.secondaryTextColor.withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '找不到相關結果',
              style: AppTheme.title3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '試試其他關鍵字或調整搜尋條件',
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.tertiaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            IOSButton.secondary(
              text: '瀏覽所有名片',
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
                _loadInitialData();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _loadInitialData();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    cardProvider.loadPublicCards(query: query).then((_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _performSearchWithQuery(String query) {
    _searchController.text = query;
    setState(() {
      _searchQuery = query;
    });
    _performSearch(query);
  }

  void _searchNearby() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('附近的人'),
        content: const Text('此功能需要位置權限，開發中...'),
        actions: [
          CupertinoDialogAction(
            child: const Text('確定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _showFilterOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('搜尋篩選'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作按相關性排序
            },
            child: const Text('按相關性排序'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作按最新排序
            },
            child: const Text('按最新排序'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作按距離排序
            },
            child: const Text('按距離排序'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  void _navigateToQRScanner() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => QRScannerScreen()),
    );
  }

  void _navigateToCardDetail(int cardId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => CardDetailScreen(cardId: cardId),
      ),
    );
  }
}