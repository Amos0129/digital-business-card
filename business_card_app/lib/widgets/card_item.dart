// lib/widgets/card_item.dart
import 'package:flutter/cupertino.dart';
import '../core/theme.dart';
import '../models/card.dart';

class CardItem extends StatelessWidget {
  final BusinessCard card;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const CardItem({
    super.key,
    required this.card,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
          boxShadow: AppTheme.iosCardShadow,
        ),
        child: Row(
          children: [
            // 頭像
            _buildAvatar(),
            
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
                    Text(
                      card.company!,
                      style: AppTheme.subheadline,
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
                  _buildSocialIcons(),
                ],
              ),
            ),
            
            // 操作按鈕
            if (showActions) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: card.avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildSocialIcons() {
    final socials = <Widget>[];
    
    if (card.facebook == true) {
      socials.add(_buildSocialIcon('F', CupertinoColors.systemBlue));
    }
    if (card.instagram == true) {
      socials.add(_buildSocialIcon('IG', CupertinoColors.systemPink));
    }
    if (card.line == true) {
      socials.add(_buildSocialIcon('L', CupertinoColors.systemGreen));
    }
    if (card.threads == true) {
      socials.add(_buildSocialIcon('T', CupertinoColors.systemIndigo));
    }

    if (socials.isEmpty) return const SizedBox();

    return Row(children: socials);
  }

  Widget _buildSocialIcon(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            onPressed: onEdit,
            child: Icon(
              CupertinoIcons.pencil,
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
        if (onDelete != null)
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            onPressed: onDelete,
            child: const Icon(
              CupertinoIcons.trash,
              size: 20,
              color: CupertinoColors.systemRed,
            ),
          ),
      ],
    );
  }
}