import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/card.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

enum IOSCardStyle {
  list,        // iOS 列表樣式
  card,        // iOS 卡片樣式  
  compact,     // iOS 緊湊樣式
}

class CardItem extends StatefulWidget {
  final BusinessCard card;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onRemove;
  final bool showActions;
  final bool showGroupInfo;
  final IOSCardStyle style;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  const CardItem({
    Key? key,
    required this.card,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onRemove,
    this.showActions = false,
    this.showGroupInfo = false,
    this.style = IOSCardStyle.list,
    this.showDivider = true,
    this.padding,
  }) : super(key: key);

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _backgroundColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppTheme.separatorColor.withOpacity(0.3),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetAnimation();
  }

  void _handleTapCancel() {
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case IOSCardStyle.list:
        return _buildListStyle();
      case IOSCardStyle.card:
        return _buildCardStyle();
      case IOSCardStyle.compact:
        return _buildCompactStyle();
    }
  }

  Widget _buildListStyle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColorAnimation.value,
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: widget.padding ?? IOSConstants.cellPadding,
                    child: Row(
                      children: [
                        // 頭像
                        _buildAvatar(),
                        const SizedBox(width: 12),
                        
                        // 內容區域
                        Expanded(child: _buildContent()),
                        
                        // 右側區域
                        _buildTrailing(),
                      ],
                    ),
                  ),
                  if (widget.showDivider) _buildDivider(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardStyle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildAvatar(),
                          const SizedBox(width: 12),
                          Expanded(child: _buildContent()),
                          _buildTrailing(),
                        ],
                      ),
                      if (_hasAdditionalInfo()) ...[
                        const SizedBox(height: 12),
                        _buildAdditionalInfo(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactStyle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _backgroundColorAnimation.value,
              ),
              child: Row(
                children: [
                  _buildSmallAvatar(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.card.name,
                          style: AppTheme.callout.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.card.company?.isNotEmpty == true)
                          Text(
                            widget.card.company!,
                            style: AppTheme.caption1.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  _buildStatusIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppUtils.getStyleColor(widget.card.style),
        image: widget.card.avatarUrl?.isNotEmpty == true
            ? DecorationImage(
                image: NetworkImage(AppUtils.getFullAvatarUrl(widget.card.avatarUrl!)!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.card.avatarUrl?.isEmpty != false
          ? Icon(
              CupertinoIcons.person_fill,
              size: 24,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildSmallAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppUtils.getStyleColor(widget.card.style),
        image: widget.card.avatarUrl?.isNotEmpty == true
            ? DecorationImage(
                image: NetworkImage(AppUtils.getFullAvatarUrl(widget.card.avatarUrl!)!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.card.avatarUrl?.isEmpty != false
          ? Icon(
              CupertinoIcons.person_fill,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 姓名和狀態
        Row(
          children: [
            Expanded(
              child: Text(
                widget.card.name,
                style: AppTheme.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.card.isPublic) _buildPublicBadge(),
          ],
        ),
        
        // 公司
        if (widget.card.company?.isNotEmpty == true) ...[
          const SizedBox(height: 2),
          Text(
            widget.card.company!,
            style: AppTheme.subheadline.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        
        // 職位
        if (widget.card.position?.isNotEmpty == true) ...[
          const SizedBox(height: 1),
          Text(
            widget.card.position!,
            style: AppTheme.footnote.copyWith(
              color: AppTheme.tertiaryTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        
        // 群組資訊（緊湊模式下）
        if (widget.showGroupInfo && 
            widget.card is CardWithGroup && 
            widget.style == IOSCardStyle.list) ...[
          const SizedBox(height: 4),
          _buildGroupInfo(widget.card as CardWithGroup),
        ],
      ],
    );
  }

  Widget _buildTrailing() {
    List<Widget> trailingWidgets = [];
    
    // 社交媒體指示器
    if (widget.card.hasSocialMedia && widget.style != IOSCardStyle.compact) {
      trailingWidgets.add(_buildSocialIndicator());
    }
    
    // 動作按鈕
    if (widget.showActions) {
      trailingWidgets.add(_buildActionButton());
    } else {
      // iOS 風格的箭頭
      trailingWidgets.add(
        Icon(
          CupertinoIcons.chevron_forward,
          size: 16,
          color: AppTheme.tertiaryTextColor,
        ),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: trailingWidgets,
    );
  }

  Widget _buildActionButton() {
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      minSize: 0,
      onPressed: () => _showActionSheet(),
      child: Icon(
        CupertinoIcons.ellipsis,
        size: 20,
        color: AppTheme.secondaryTextColor,
      ),
    );
  }

  Widget _buildPublicBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.successColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '公開',
        style: AppTheme.caption2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSocialIndicator() {
    final socialList = widget.card.socialMediaList;
    if (socialList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.link,
            size: 12,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${socialList.length}',
            style: AppTheme.caption2.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.card.isPublic) {
      return Icon(
        CupertinoIcons.globe,
        size: 16,
        color: AppTheme.successColor,
      );
    }
    return Icon(
      CupertinoIcons.lock_fill,
      size: 16,
      color: AppTheme.tertiaryTextColor,
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 74), // 對齊內容
      height: 0.5,
      color: AppTheme.separatorColor,
    );
  }

  Widget _buildGroupInfo(CardWithGroup cardWithGroup) {
    if (cardWithGroup.groupName?.isEmpty != false) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.folder_fill,
            size: 10,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            cardWithGroup.groupName!,
            style: AppTheme.caption2.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAdditionalInfo() {
    return widget.card.phone?.isNotEmpty == true ||
           widget.card.email?.isNotEmpty == true ||
           widget.card.address?.isNotEmpty == true ||
           widget.card.hasSocialMedia;
  }

  Widget _buildAdditionalInfo() {
    List<Widget> infoWidgets = [];
    
    // 聯絡資訊
    if (widget.card.phone?.isNotEmpty == true) {
      infoWidgets.add(_buildContactRow(CupertinoIcons.phone, widget.card.phone!));
    }
    
    if (widget.card.email?.isNotEmpty == true) {
      infoWidgets.add(_buildContactRow(CupertinoIcons.mail, widget.card.email!));
    }
    
    if (widget.card.address?.isNotEmpty == true) {
      infoWidgets.add(_buildContactRow(
        CupertinoIcons.location, 
        AppUtils.truncateText(widget.card.address!, 40)
      ));
    }
    
    // 社交媒體
    if (widget.card.hasSocialMedia) {
      infoWidgets.add(_buildSocialMediaRow());
    }
    
    return Column(
      children: infoWidgets
          .map((widget) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: widget,
              ))
          .toList(),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.secondaryTextColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.footnote.copyWith(
              color: AppTheme.textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaRow() {
    final socialList = widget.card.socialMediaList;
    if (socialList.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          CupertinoIcons.link,
          size: 14,
          color: AppTheme.secondaryTextColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 6,
            children: socialList.take(4).map((social) {
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppUtils.getSocialColor(social.platform).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  AppUtils.getSocialIcon(social.platform),
                  size: 12,
                  color: AppUtils.getSocialColor(social.platform),
                ),
              );
            }).toList(),
          ),
        ),
        if (socialList.length > 4)
          Text(
            '+${socialList.length - 4}',
            style: AppTheme.caption2.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
      ],
    );
  }

  void _showActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          if (widget.onEdit != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                widget.onEdit!();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.pencil, size: 18),
                  SizedBox(width: 8),
                  Text('編輯'),
                ],
              ),
            ),
          if (widget.onShare != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                widget.onShare!();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.share, size: 18),
                  SizedBox(width: 8),
                  Text('分享'),
                ],
              ),
            ),
          if (widget.onRemove != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                widget.onRemove!();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.minus_circle, size: 18),
                  SizedBox(width: 8),
                  Text('移除'),
                ],
              ),
            ),
          if (widget.onDelete != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete!();
              },
              isDestructiveAction: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.delete, size: 18),
                  SizedBox(width: 8),
                  Text('刪除'),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('取消'),
        ),
      ),
    );
  }
}

// iOS 風格的名片列表
class IOSCardList extends StatelessWidget {
  final List<BusinessCard> cards;
  final void Function(BusinessCard)? onCardTap;
  final void Function(BusinessCard)? onCardEdit;
  final void Function(BusinessCard)? onCardDelete;
  final bool showActions;
  final bool showGroupInfo;
  final IOSCardStyle style;
  final Widget? header;
  final Widget? footer;
  final String? emptyMessage;

  const IOSCardList({
    Key? key,
    required this.cards,
    this.onCardTap,
    this.onCardEdit,
    this.onCardDelete,
    this.showActions = false,
    this.showGroupInfo = false,
    this.style = IOSCardStyle.list,
    this.header,
    this.footer,
    this.emptyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.square_stack_3d_up,
              size: 64,
              color: AppTheme.tertiaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? '沒有名片',
              style: AppTheme.body.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    if (style == IOSCardStyle.card) {
      return Column(
        children: [
          if (header != null) header!,
          ...cards.map((card) => CardItem(
            card: card,
            style: style,
            showActions: showActions,
            showGroupInfo: showGroupInfo,
            onTap: () => onCardTap?.call(card),
            onEdit: () => onCardEdit?.call(card),
            onDelete: () => onCardDelete?.call(card),
          )),
          if (footer != null) footer!,
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
      ),
      child: Column(
        children: [
          if (header != null) header!,
          ...cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            final isLast = index == cards.length - 1;
            
            return CardItem(
              card: card,
              style: style,
              showActions: showActions,
              showGroupInfo: showGroupInfo,
              showDivider: !isLast,
              onTap: () => onCardTap?.call(card),
              onEdit: () => onCardEdit?.call(card),
              onDelete: () => onCardDelete?.call(card),
            );
          }),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}