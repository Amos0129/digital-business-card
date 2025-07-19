// lib/screens/groups/group_detail_screen.dart
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
import '../cards/card_detail_screen.dart';
import '../cards/card_form_screen.dart';
import '../../models/card.dart';
import '../../models/group.dart';
import '../../services/group_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isEditingName = false;
  final _groupNameController = TextEditingController();
  
  CardGroup? _group;
  List<BusinessCard> _groupCards = [];
  List<BusinessCard> _availableCards = [];
  bool _showAvailableCards = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final groupService = GroupService();
      
      // 載入群組資訊
      _group = await groupService.getGroupById(widget.groupId);
      _groupNameController.text = _group?.name ?? '';
      
      // 載入群組中的名片
      _groupCards = await groupService.getCardsInGroup(widget.groupId);
      
      // 載入可新增的名片（我的名片中不在此群組的）
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      await cardProvider.loadMyCards();
      
      _availableCards = cardProvider.myCards.where((card) {
        return !_groupCards.any((groupCard) => groupCard.id == card.id);
      }).toList();
      
    } catch (e) {
      _showError('載入失敗: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_isLoading)
            const SliverToBoxAdapter(child: LoadingView())
          else ...[
            _buildGroupHeader(),
            _buildSearchAndActions(),
            _buildCardsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: AppTheme.backgroundColor,
      border: null,
      largeTitle: Text(_group?.name ?? '群組'),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.pop(context),
        child: const Icon(CupertinoIcons.back),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showGroupOptions(),
        child: const Icon(CupertinoIcons.ellipsis_circle),
      ),
    );
  }

  Widget _buildGroupHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
          boxShadow: AppTheme.iosCardShadow,
        ),
        child: Column(
          children: [
            // 群組圖示
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                CupertinoIcons.folder_fill,
                color: AppTheme.primaryColor,
                size: 30,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 群組名稱
            if (_isEditingName)
              _buildEditableGroupName()
            else
              _buildGroupName(),
            
            const SizedBox(height: 8),
            
            // 群組統計
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat('名片數量', _groupCards.length.toString()),
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppTheme.separatorColor,
                ),
                _buildStat('建立時間', _formatDate(_group?.createdAt)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupName() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _isEditingName = true;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _group?.name ?? '',
            style: AppTheme.title2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            CupertinoIcons.pencil,
            size: 16,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableGroupName() {
    return Row(
      children: [
        Expanded(
          child: IOSField(
            controller: _groupNameController,
            placeholder: '群組名稱',
          ),
        ),
        const SizedBox(width: 8),
        IOSButton.primary(
          text: '確定',
          onPressed: _saveGroupName,
          size: IOSButtonSize.small,
        ),
        const SizedBox(width: 8),
        IOSButton.plain(
          text: '取消',
          onPressed: () {
            setState(() {
              _isEditingName = false;
              _groupNameController.text = _group?.name ?? '';
            });
          },
          size: IOSButtonSize.small,
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.title3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.caption1.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // 搜尋列
            IOSSearchField(
              placeholder: '搜尋群組內的名片...',
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
            
            const SizedBox(height: 16),
            
            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: IOSButton.primary(
                    text: '新增名片',
                    icon: CupertinoIcons.add,
                    onPressed: () => _showAddCardOptions(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IOSButton.secondary(
                    text: '管理名片',
                    icon: CupertinoIcons.settings,
                    onPressed: () => _toggleAvailableCards(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsList() {
    final filteredCards = _filterCards();

    if (_showAvailableCards) {
      return _buildAvailableCardsList();
    }

    if (filteredCards.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final card = filteredCards[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CardItem(
              card: card,
              onTap: () => _navigateToCardDetail(card.id!),
              showActions: true,
              onEdit: () => _navigateToEditCard(card),
              onDelete: () => _removeCardFromGroup(card.id!),
            ),
          );
        },
        childCount: filteredCards.length,
      ),
    );
  }

  Widget _buildAvailableCardsList() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
          boxShadow: AppTheme.iosCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '可新增的名片',
                  style: AppTheme.headline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IOSButton.plain(
                  text: '完成',
                  onPressed: () => _toggleAvailableCards(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_availableCards.isEmpty)
              Center(
                child: Text(
                  '所有名片都已在群組中',
                  style: AppTheme.subheadline.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              )
            else
              Column(
                children: _availableCards.map((card) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _addCardToGroup(card.id!),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.add_circled,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                card.name,
                                style: AppTheme.body,
                              ),
                            ),
                            if (card.company != null)
                              Text(
                                card.company!,
                                style: AppTheme.footnote.copyWith(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
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
        ),
      );
    }

    return EmptyView(
      icon: CupertinoIcons.folder,
      title: '群組是空的',
      message: '將名片加入此群組來開始整理',
      buttonText: '新增名片',
      onButtonPressed: () => _showAddCardOptions(),
      iconColor: AppTheme.primaryColor,
    );
  }

  List<BusinessCard> _filterCards() {
    if (_searchQuery.isEmpty) return _groupCards;

    return _groupCards.where((card) {
      return card.name.toLowerCase().contains(_searchQuery) ||
             (card.company?.toLowerCase().contains(_searchQuery) ?? false) ||
             (card.position?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _showGroupOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(_group?.name ?? '群組選項'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isEditingName = true;
              });
            },
            child: const Text('重新命名群組'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _shareGroup();
            },
            child: const Text('分享群組'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteGroupDialog();
            },
            isDestructiveAction: true,
            child: const Text('刪除群組'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  void _showAddCardOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('新增名片'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateCard();
            },
            child: const Text('建立新名片'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _toggleAvailableCards();
            },
            child: const Text('從現有名片選擇'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  void _toggleAvailableCards() {
    setState(() {
      _showAvailableCards = !_showAvailableCards;
    });
  }

  void _saveGroupName() async {
    final newName = _groupNameController.text.trim();
    if (newName.isEmpty || newName == _group?.name) {
      setState(() {
        _isEditingName = false;
      });
      return;
    }

    try {
      final groupService = GroupService();
      await groupService.renameGroup(widget.groupId, newName);
      
      setState(() {
        _isEditingName = false;
        if (_group != null) {
          _group = CardGroup(
            id: _group!.id,
            name: newName,
            createdAt: _group!.createdAt,
          );
        }
      });
    } catch (e) {
      _showError('重新命名失敗: $e');
    }
  }

  void _addCardToGroup(int cardId) async {
    try {
      final groupService = GroupService();
      await groupService.addCardToGroup(cardId, widget.groupId);
      _loadData();
    } catch (e) {
      _showError('新增名片失敗: $e');
    }
  }

  void _removeCardFromGroup(int cardId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('移除名片'),
        content: const Text('確定要將此名片從群組中移除嗎？'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              try {
                final groupService = GroupService();
                await groupService.removeCardFromGroup(cardId, widget.groupId);
                _loadData();
              } catch (e) {
                _showError('移除名片失敗: $e');
              }
            },
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('刪除群組'),
        content: Text('確定要刪除「${_group?.name}」群組嗎？\n群組內的名片不會被刪除。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              try {
                final groupService = GroupService();
                await groupService.deleteGroup(widget.groupId);
                Navigator.pop(context, true); // 返回上一頁
              } catch (e) {
                _showError('刪除群組失敗: $e');
              }
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _shareGroup() {
    // 實作分享群組功能
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('分享群組'),
        content: const Text('群組分享功能開發中...'),
        actions: [
          CupertinoDialogAction(
            child: const Text('確定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('錯誤'),
        content: Text(message),
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