import 'package:flutter/material.dart';
import '../../models/card.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class CardItem extends StatelessWidget {
  final BusinessCard card;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onRemove;
  final bool showActions;
  final bool showGroupInfo;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 頭像
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  
                  // 基本資訊
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                card.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (card.isPublic)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '公開',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (card.company?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            card.company!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey, // 修正：直接使用 Colors.grey
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (card.position?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            card.position!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey, // 修正：直接使用 Colors.grey
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // 動作按鈕
                  if (showActions) _buildActionButton(context),
                ],
              ),
              
              // 聯絡資訊
              const SizedBox(height: 12),
              _buildContactInfo(),
              
              // 社交媒體
              if (card.hasSocialMedia) ...[
                const SizedBox(height: 8),
                _buildSocialMedia(),
              ],
              
              // 群組資訊（如果需要顯示）
              if (showGroupInfo && card is CardWithGroup) ...[
                const SizedBox(height: 8),
                _buildGroupInfo(card as CardWithGroup),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppUtils.getStyleColor(card.style),
        image: card.avatarUrl?.isNotEmpty == true
            ? DecorationImage(
                image: NetworkImage(AppUtils.getFullAvatarUrl(card.avatarUrl!)!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: card.avatarUrl?.isEmpty != false
          ? Icon(
              Icons.person,
              size: 24,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'share':
            onShare?.call();
            break;
          case 'remove':
            onRemove?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('編輯'),
              ],
            ),
          ),
        if (onShare != null)
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share),
                SizedBox(width: 8),
                Text('分享'),
              ],
            ),
          ),
        if (onRemove != null)
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.remove_circle_outline),
                SizedBox(width: 8),
                Text('移除'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('刪除', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        if (card.phone?.isNotEmpty == true)
          _buildContactRow(Icons.phone, card.phone!),
        if (card.email?.isNotEmpty == true)
          _buildContactRow(Icons.email, card.email!),
        if (card.address?.isNotEmpty == true)
          _buildContactRow(Icons.location_on, card.address!),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey, // 修正：直接使用 Colors.grey
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMedia() {
    final socialList = card.socialMediaList;
    if (socialList.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(
          Icons.link,
          size: 16,
          color: Colors.grey, // 修正：直接使用 Colors.grey
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: socialList.take(4).map((social) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppUtils.getSocialColor(social.platform).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    AppUtils.getSocialIcon(social.platform),
                    size: 16,
                    color: AppUtils.getSocialColor(social.platform),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (socialList.length > 4)
          Text(
            '+${socialList.length - 4}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey, // 修正：直接使用 Colors.grey
            ),
          ),
      ],
    );
  }

  Widget _buildGroupInfo(CardWithGroup cardWithGroup) {
    if (cardWithGroup.groupName?.isEmpty != false) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder,
            size: 14,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            cardWithGroup.groupName!,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}