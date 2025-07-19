// lib/screens/cards/card_detail_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/card.dart';

class CardDetailScreen extends StatelessWidget {
  final BusinessCard card;
  final bool isPublic;

  const CardDetailScreen({
    super.key,
    required this.card,
    this.isPublic = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('名片詳情'),
        trailing: !isPublic
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showShareOptions(context),
                child: const Icon(CupertinoIcons.share),
              )
            : null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildInfoSection(),
              const SizedBox(height: 24),
              _buildSocialSection(),
              const SizedBox(height: 24),
              _buildContactSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: Column(
        children: [
          // 頭像
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: card.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      card.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
          
          const SizedBox(height: 16),
          
          // 姓名
          Text(
            card.name,
            style: AppTheme.largeTitle.copyWith(fontSize: 24),
          ),
          
          // 公司職位
          if (card.company != null || card.position != null) ...[
            const SizedBox(height: 8),
            Text(
              [card.position, card.company]
                  .where((e) => e != null && e.isNotEmpty)
                  .join(' • '),
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      CupertinoIcons.person_fill,
      size: 50,
      color: AppTheme.primaryColor.withOpacity(0.6),
    );
  }

  Widget _buildInfoSection() {
    final items = <Widget>[];
    
    if (card.email != null && card.email!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: CupertinoIcons.mail,
        title: '電子郵件',
        value: card.email!,
        onTap: () => _launchEmail(card.email!),
      ));
    }
    
    if (card.phone != null && card.phone!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: CupertinoIcons.phone,
        title: '電話',
        value: card.phone!,
        onTap: () => _launchPhone(card.phone!),
      ));
    }
    
    if (card.address != null && card.address!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: CupertinoIcons.location,
        title: '地址',
        value: card.address!,
        onTap: () => _launchMaps(card.address!),
      ));
    }

    if (items.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: Column(children: items),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(16),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.footnote.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.body,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppTheme.tertiaryTextColor,
            ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    final socials = <Map<String, dynamic>>[];
    
    if (card.facebook == true && card.facebookUrl != null) {
      socials.add({
        'name': 'Facebook',
        'icon': CupertinoIcons.globe,
        'color': CupertinoColors.systemBlue,
        'url': card.facebookUrl,
      });
    }
    
    if (card.instagram == true && card.instagramUrl != null) {
      socials.add({
        'name': 'Instagram',
        'icon': CupertinoIcons.camera,
        'color': CupertinoColors.systemPink,
        'url': card.instagramUrl,
      });
    }
    
    if (card.line == true && card.lineUrl != null) {
      socials.add({
        'name': 'LINE',
        'icon': CupertinoIcons.chat_bubble,
        'color': CupertinoColors.systemGreen,
        'url': card.lineUrl,
      });
    }
    
    if (card.threads == true && card.threadsUrl != null) {
      socials.add({
        'name': 'Threads',
        'icon': CupertinoIcons.link,
        'color': CupertinoColors.systemIndigo,
        'url': card.threadsUrl,
      });
    }

    if (socials.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: Column(
        children: socials
            .map((social) => _buildSocialItem(
                  name: social['name'],
                  icon: social['icon'],
                  color: social['color'],
                  url: social['url'],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSocialItem({
    required String name,
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(16),
      onPressed: () => _launchUrl(url),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(name, style: AppTheme.body),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: AppTheme.tertiaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton.filled(
            onPressed: () => _addToContacts(),
            child: const Text('加入聯絡人'),
          ),
        ),
        if (!isPublic) ...[
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoButton(
              color: CupertinoColors.systemGrey5,
              onPressed: () => _generateQRCode(),
              child: Text(
                '生成 QR Code',
                style: TextStyle(color: AppTheme.textColor),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchMaps(String address) async {
    final uri = Uri.parse('https://maps.google.com/?q=$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showShareOptions(BuildContext context) {
    // 實作分享功能
  }

  void _addToContacts() {
    // 實作加入聯絡人功能
  }

  void _generateQRCode() {
    // 實作 QR Code 生成功能
  }
}