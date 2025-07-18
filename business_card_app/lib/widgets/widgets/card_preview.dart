import 'package:flutter/material.dart';
import '../../models/card.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class CardPreview extends StatelessWidget {
  final BusinessCard card;
  final double? width;
  final double? height;
  final bool showQRCode;
  final VoidCallback? onQRCodeTap;

  const CardPreview({
    Key? key,
    required this.card,
    this.width,
    this.height,
    this.showQRCode = false,
    this.onQRCodeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 200,
      margin: const EdgeInsets.all(16),
      child: _buildCardByStyle(),
    );
  }

  Widget _buildCardByStyle() {
    switch (card.style) {
      case 'minimal':
        return _buildMinimalCard();
      case 'pink_card':
        return _buildPinkCard();
      case 'mint_card':
        return _buildMintCard();
      case 'classic':
        return _buildClassicCard();
      default:
        return _buildModernCard();
    }
  }

  Widget _buildModernCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildCardContent(Colors.white, Colors.white.withOpacity(0.8)),
    );
  }

  Widget _buildMinimalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildCardContent(Colors.black87, Colors.grey.shade600),
    );
  }

  Widget _buildPinkCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildCardContent(Colors.white, Colors.white.withOpacity(0.8)),
    );
  }

  Widget _buildMintCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildCardContent(Colors.white, Colors.white.withOpacity(0.8)),
    );
  }

  Widget _buildClassicCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildCardContent(Colors.white, Colors.grey.shade300),
    );
  }

  Widget _buildCardContent(Color primaryTextColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 頭像
              _buildAvatar(primaryTextColor),
              const SizedBox(width: 16),
              
              // 基本資訊
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.company?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        card.company!,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (card.position?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        card.position!,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // QR Code
              if (showQRCode)
                GestureDetector(
                  onTap: onQRCodeTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.qr_code,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          
          const Spacer(),
          
          // 聯絡資訊
          Column(
            children: [
              if (card.phone?.isNotEmpty == true)
                _buildContactRow(
                  Icons.phone,
                  card.phone!,
                  secondaryTextColor,
                ),
              if (card.email?.isNotEmpty == true)
                _buildContactRow(
                  Icons.email,
                  card.email!,
                  secondaryTextColor,
                ),
              if (card.address?.isNotEmpty == true)
                _buildContactRow(
                  Icons.location_on,
                  AppUtils.truncateText(card.address!, 30),
                  secondaryTextColor,
                ),
            ],
          ),
          
          // 社交媒體
          if (card.hasSocialMedia) ...[
            const SizedBox(height: 8),
            _buildSocialMediaRow(primaryTextColor),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(Color borderColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor.withOpacity(0.3), width: 2),
        image: card.avatarUrl?.isNotEmpty == true
            ? DecorationImage(
                image: NetworkImage(AppUtils.getFullAvatarUrl(card.avatarUrl!)!),
                fit: BoxFit.cover,
              )
            : null,
        color: card.avatarUrl?.isEmpty != false 
            ? borderColor.withOpacity(0.1) 
            : null,
      ),
      child: card.avatarUrl?.isEmpty != false
          ? Icon(
              Icons.person,
              size: 30,
              color: borderColor.withOpacity(0.6),
            )
          : null,
    );
  }

  Widget _buildContactRow(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaRow(Color iconColor) {
    final socialList = card.socialMediaList;
    if (socialList.isEmpty) return const SizedBox.shrink();

    return Row(
      children: socialList.take(4).map((social) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              AppUtils.getSocialIcon(social.platform),
              size: 16,
              color: iconColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}