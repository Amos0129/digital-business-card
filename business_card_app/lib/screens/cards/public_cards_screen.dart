// lib/screens/cards/public_cards_screen.dart
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
import '../../models/card.dart';

class PublicCardsScreen extends StatefulWidget {
  @override
  _PublicCardsScreenState createState() => _PublicCardsScreenState();
}

class _PublicCardsScreenState extends State<PublicCardsScreen>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '全部';
  
  final List<String> _categories = [
    '全部',
    '科技業',
    '金融業',
    '教育業',
    '醫療業',
    '服務業',
    '創意業',
    '其他',
  ];

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
          _buildCategoryFilter(),
          _buildCardsList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: AppTheme.backgroundColor,
      border: null,
      largeTitle: const Text('探索名片'),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showFilterOptions(),
        child: const Icon(
          CupertinoIcons.slider_horizontal_3,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜尋標題
            Text(
              '發現有趣的人脈',
              style: AppTheme.title3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '搜尋公開的數位名片，拓展您的人脈網絡',
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 搜尋列
            IOSSearchField(
              placeholder: '搜尋姓名、公司或職位...',
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
                _performSearch('');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryChip(
              label: category,
              isSelected: _selectedCategory == category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                _filterByCategory(category);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(25),
            border: isSelected 
                ? null 
                : Border.all(color: AppTheme.separatorColor),
            boxShadow: isSelected 
                ? AppTheme.iosCardShadow 
                : null,
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

        if (cardProvider.publicCards.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return _buildResultsHeader(cardProvider.publicCards.length);
                }

                final card = cardProvider.publicCards[index - 1];
                return _buildPublicCardItem(card);
              },
              childCount: cardProvider.publicCards.length + 1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '找到 $count 張名片',
            style: AppTheme.footnote.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          
          if (_searchQuery.isNotEmpty || _selectedCategory != '全部')
            IOSButton.plain(
              text: '清除篩選',
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = '全部';
                });
                _searchController.clear();
                _loadData();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPublicCardItem(BusinessCard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToCardDetail(card.id!),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
            boxShadow: AppTheme.iosCardShadow,
          ),
          child: Row(
            children: [
              // 頭像
              _buildAvatar(card),
              
              const SizedBox(width: 16),
              
              // 名片資訊
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: AppTheme.headline,
                    ),
                    
                    if (card.company != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.building_2_fill,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              card.company!,
                              style: AppTheme.subheadline.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (card.position != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        card.position!,
                        style: AppTheme.footnote.copyWith(
                          color: AppTheme.tertiaryTextColor,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // 社交媒體圖示
                    _buildSocialIcons(card),
                  ],
                ),
              ),
              
              // 操作按鈕
              Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 32,
                    onPressed: () => _saveCard(card),
                    child: Icon(
                      CupertinoIcons.heart,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 32,
                    onPressed: () => _shareCard(card),
                    child: Icon(
                      CupertinoIcons.share,
                      color: AppTheme.secondaryTextColor,
                      size: 20,
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

  Widget _buildAvatar(BusinessCard card) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: card.avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                card.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      CupertinoIcons.person_fill,
      size: 30,
      color: AppTheme.primaryColor.withOpacity(0.6),
    );
  }

  Widget _buildSocialIcons(BusinessCard card) {
    final socials = <Widget>[];
    
    if (card.facebook == true) {
      socials.add(_buildSocialIcon('FB', CupertinoColors.systemBlue));
    }
    if (card.instagram == true) {
      socials.add(_buildSocialIcon('IG', CupertinoColors.systemPink));
    }
    if (card.line == true) {
      socials.add(_buildSocialIcon('LINE', CupertinoColors.systemGreen));
    }
    if (card.threads == true) {
      socials.add(_buildSocialIcon('THD', CupertinoColors.systemIndigo));
    }

    if (socials.isEmpty) {
      return Text(
        '無社交媒體',
        style: AppTheme.caption2.copyWith(
          color: AppTheme.tertiaryTextColor,
        ),
      );
    }

    return Row(children: socials);
  }

  Widget _buildSocialIcon(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return EmptyView.noSearchResults();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                CupertinoIcons.globe,
                size: 40,
                color: AppTheme.primaryColor.withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '還沒有公開名片',
              style: AppTheme.title3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '成為第一個分享名片的人，\n讓其他人能找到您',
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    cardProvider.loadPublicCards(query: query.isEmpty ? null : query);
  }

  void _filterByCategory(String category) {
    // 實作分類篩選邏輯
    // 這裡可以根據需求實作不同的篩選方式
  }

  void _showFilterOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('篩選選項'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作最新排序
            },
            child: const Text('最新建立'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作熱門排序
            },
            child: const Text('最受歡迎'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作附近排序
            },
            child: const Text('附近的人'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
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

  void _saveCard(BusinessCard card) {
    // 實作收藏功能
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('收藏名片'),
        content: Text('已收藏 ${card.name} 的名片'),
        actions: [
          CupertinoDialogAction(
            child: const Text('確定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _shareCard(BusinessCard card) {
    // 實作分享功能
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('分享 ${card.name} 的名片'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作複製連結
            },
            child: const Text('複製分享連結'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作系統分享
            },
            child: const Text('透過其他App分享'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }
}