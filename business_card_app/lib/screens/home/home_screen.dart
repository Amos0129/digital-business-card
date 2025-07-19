// lib/screens/home/home_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/card_provider.dart';
import '../../widgets/card_item.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/ios_button.dart';
import '../cards/card_form_screen.dart';
import '../search/search_screen.dart';
import '../scanner/qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildQuickActions(),
          _buildMyCardsSection(),
          _buildDiscoverSection(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        
        return CupertinoSliverNavigationBar(
          backgroundColor: AppTheme.backgroundColor,
          border: null,
          largeTitle: Text('嗨，${user?.name ?? '使用者'}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _navigateToSearch(),
                child: const Icon(
                  CupertinoIcons.search,
                  size: 24,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _navigateToQRScanner(),
                child: const Icon(
                  CupertinoIcons.qrcode_viewfinder,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 主要操作按鈕
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: CupertinoIcons.add_circled_solid,
                    title: '建立名片',
                    subtitle: '製作您的數位名片',
                    color: AppTheme.primaryColor,
                    onTap: () => _navigateToCreateCard(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: CupertinoIcons.qrcode,
                    title: 'QR 掃描',
                    subtitle: '掃描他人名片',
                    color: AppTheme.secondaryColor,
                    onTap: () => _navigateToQRScanner(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 次要操作按鈕
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: CupertinoIcons.search_circle,
                    title: '探索名片',
                    subtitle: '發現公開名片',
                    color: AppTheme.successColor,
                    onTap: () => _navigateToSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: CupertinoIcons.share,
                    title: '分享名片',
                    subtitle: '快速分享連結',
                    color: AppTheme.warningColor,
                    onTap: () => _showShareOptions(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
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
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
          boxShadow: AppTheme.iosCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: AppTheme.callout.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 2),
            
            Text(
              subtitle,
              style: AppTheme.caption1.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCardsSection() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  title: '我的名片',
                  action: '查看全部',
                  onAction: () => _navigateToMyCards(),
                ),
                
                const SizedBox(height: 12),
                
                if (cardProvider.isLoading)
                  const LoadingView()
                else if (cardProvider.myCards.isEmpty)
                  EmptyView.noCards(onCreateCard: () => _navigateToCreateCard())
                else
                  Column(
                    children: cardProvider.myCards
                        .take(3)
                        .map((card) => CardItem(
                              card: card,
                              onTap: () => _navigateToCardDetail(card.id!),
                              showActions: true,
                              onEdit: () => _navigateToEditCard(card),
                              onDelete: () => _deleteCard(card.id!),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscoverSection() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  title: '探索名片',
                  action: '查看更多',
                  onAction: () => _navigateToSearch(),
                ),
                
                const SizedBox(height: 12),
                
                if (cardProvider.isLoading)
                  const LoadingView()
                else if (cardProvider.publicCards.isEmpty)
                  EmptyView.noSearchResults()
                else
                  Column(
                    children: cardProvider.publicCards
                        .take(3)
                        .map((card) => CardItem(
                              card: card,
                              onTap: () => _navigateToCardDetail(card.id!),
                            ))
                        .toList(),
                  ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String action,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.title3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onAction,
          child: Text(
            action,
            style: AppTheme.footnote.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // 導航方法
  void _navigateToCreateCard() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const CardFormScreen(),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToEditCard(card) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => CardFormScreen(card: card),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToCardDetail(int cardId) {
    Navigator.pushNamed(
      context,
      '/card-detail',
      arguments: cardId,
    );
  }

  void _navigateToMyCards() {
    // 切換到我的名片分頁
    DefaultTabController.of(context)?.animateTo(0);
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => SearchScreen()),
    );
  }

  void _navigateToQRScanner() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => QRScannerScreen()),
    );
  }

  void _deleteCard(int cardId) {
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
            onPressed: () async {
              Navigator.pop(context);
              final cardProvider = Provider.of<CardProvider>(context, listen: false);
              final success = await cardProvider.deleteCard(cardId);
              if (success && mounted) {
                _loadData();
              }
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _showShareOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('分享名片'),
        message: const Text('選擇您要分享的方式'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作分享功能
            },
            child: const Text('生成分享連結'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 實作QR Code功能
            },
            child: const Text('顯示 QR Code'),
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