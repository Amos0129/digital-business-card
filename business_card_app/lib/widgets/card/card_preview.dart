import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/card.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

enum IOSCardPreviewStyle {
  modern,     // 現代漸層風格
  minimal,    // 簡約風格
  pink,       // 粉色主題
  mint,       // 薄荷主題
  classic,    // 經典深色
  glass,      // 玻璃質感
}

class CardPreview extends StatefulWidget {
  final BusinessCard card;
  final double? width;
  final double? height;
  final bool showQRCode;
  final VoidCallback? onQRCodeTap;
  final IOSCardPreviewStyle? forceStyle;
  final bool enableInteraction;
  final bool showShadow;

  const CardPreview({
    Key? key,
    required this.card,
    this.width,
    this.height,
    this.showQRCode = false,
    this.onQRCodeTap,
    this.forceStyle,
    this.enableInteraction = true,
    this.showShadow = true,
  }) : super(key: key);

  @override
  State<CardPreview> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _flipController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  IOSCardPreviewStyle get _cardStyle {
    if (widget.forceStyle != null) return widget.forceStyle!;
    
    switch (widget.card.style) {
      case 'minimal':
        return IOSCardPreviewStyle.minimal;
      case 'pink_card':
        return IOSCardPreviewStyle.pink;
      case 'mint_card':
        return IOSCardPreviewStyle.mint;
      case 'classic':
        return IOSCardPreviewStyle.classic;
      case 'glass':
        return IOSCardPreviewStyle.glass;
      default:
        return IOSCardPreviewStyle.modern;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      margin: const EdgeInsets.all(16),
      child: widget.enableInteraction ? _buildInteractiveCard() : _buildStaticCard(),
    );
  }

  Widget _buildInteractiveCard() {
    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) => _hoverController.reverse(),
      onTapCancel: () => _hoverController.reverse(),
      onDoubleTap: _flipCard,
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: _buildCardContainer(),
          );
        },
      ),
    );
  }

  Widget _buildStaticCard() {
    return _buildCardContainer();
  }

  Widget _buildCardContainer() {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isShowingFront = _flipAnimation.value < 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_flipAnimation.value * 3.14159),
          child: isShowingFront ? _buildFrontCard() : _buildBackCard(),
        );
      },
    );
  }

  Widget _buildFrontCard() {
    return Container(
      decoration: _getCardDecoration(),
      child: _buildCardContent(),
    );
  }

  Widget _buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        decoration: _getCardDecoration(),
        child: _buildBackContent(),
      ),
    );
  }

  BoxDecoration _getCardDecoration() {
    final baseRadius = BorderRadius.circular(20);
    
    switch (_cardStyle) {
      case IOSCardPreviewStyle.modern:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: baseRadius,
          boxShadow: widget.showShadow ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : null,
        );
        
      case IOSCardPreviewStyle.minimal:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: baseRadius,
          border: Border.all(
            color: AppTheme.separatorColor,
            width: 1,
          ),
          boxShadow: widget.showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
        
      case IOSCardPreviewStyle.pink:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEC4899), Color(0xFFF97316)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: baseRadius,
          boxShadow: widget.showShadow ? [
            BoxShadow(
              color: const Color(0xFFEC4899).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : null,
        );
        
      case IOSCardPreviewStyle.mint:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: baseRadius,
          boxShadow: widget.showShadow ? [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : null,
        );
        
      case IOSCardPreviewStyle.classic:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F2937), Color(0xFF374151)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: baseRadius,
          boxShadow: widget.showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : null,
        );
        
      case IOSCardPreviewStyle.glass:
        return BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: baseRadius,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: widget.showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ] : null,
        );
    }
  }

  Widget _buildCardContent() {
    final colors = _getTextColors();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // 背景圖案
          _buildBackgroundPattern(),
          
          // 內容
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 頭部區域
                Row(
                  children: [
                    _buildAvatar(colors.primary),
                    const SizedBox(width: 16),
                    Expanded(child: _buildNameSection(colors)),
                    if (widget.showQRCode) _buildQRCode(),
                  ],
                ),
                
                const Spacer(),
                
                // 聯絡資訊
                _buildContactInfo(colors),
                
                // 底部區域
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSocialMedia(colors),
                    _buildCompanyLogo(colors),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackContent() {
    final colors = _getTextColors();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.qrcode,
                  color: colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '掃描 QR 碼',
                  style: AppTheme.headline.copyWith(color: colors.primary),
                ),
              ],
            ),
            
            const Spacer(),
            
            // QR 碼區域
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.qrcode_viewfinder,
                        size: 60,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${widget.card.id}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            Text(
              '點擊兩次翻轉名片',
              style: AppTheme.footnote.copyWith(
                color: colors.secondary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CardPatternPainter(_cardStyle),
      ),
    );
  }

  Widget _buildAvatar(Color borderColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor.withOpacity(0.3),
          width: 2,
        ),
        image: widget.card.avatarUrl?.isNotEmpty == true
            ? DecorationImage(
                image: NetworkImage(AppUtils.getFullAvatarUrl(widget.card.avatarUrl!)!),
                fit: BoxFit.cover,
              )
            : null,
        color: widget.card.avatarUrl?.isEmpty != false
            ? borderColor.withOpacity(0.2)
            : null,
      ),
      child: widget.card.avatarUrl?.isEmpty != false
          ? Icon(
              CupertinoIcons.person_fill,
              size: 30,
              color: borderColor,
            )
          : null,
    );
  }

  Widget _buildNameSection(_CardColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.card.name,
          style: AppTheme.title3.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.card.position?.isNotEmpty == true) ...[
          const SizedBox(height: 2),
          Text(
            widget.card.position!,
            style: AppTheme.subheadline.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (widget.card.company?.isNotEmpty == true) ...[
          const SizedBox(height: 1),
          Text(
            widget.card.company!,
            style: AppTheme.footnote.copyWith(
              color: colors.secondary.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildQRCode() {
    return GestureDetector(
      onTap: widget.onQRCodeTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          CupertinoIcons.qrcode,
          color: Colors.black87,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildContactInfo(_CardColors colors) {
    final contacts = <Widget>[];
    
    if (widget.card.phone?.isNotEmpty == true) {
      contacts.add(_buildContactRow(
        CupertinoIcons.phone_fill,
        widget.card.phone!,
        colors.secondary,
      ));
    }
    
    if (widget.card.email?.isNotEmpty == true) {
      contacts.add(_buildContactRow(
        CupertinoIcons.mail_solid,
        widget.card.email!,
        colors.secondary,
      ));
    }
    
    if (widget.card.address?.isNotEmpty == true) {
      contacts.add(_buildContactRow(
        CupertinoIcons.location_solid,
        AppUtils.truncateText(widget.card.address!, 25),
        colors.secondary,
      ));
    }
    
    return Column(children: contacts);
  }

  Widget _buildContactRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.footnote.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMedia(_CardColors colors) {
    final socialList = widget.card.socialMediaList;
    if (socialList.isEmpty) return const SizedBox.shrink();

    return Row(
      children: socialList.take(3).map((social) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            AppUtils.getSocialIcon(social.platform),
            size: 14,
            color: colors.primary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompanyLogo(_CardColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.card.isPublic ? '公開' : '私人',
        style: AppTheme.caption1.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _CardColors _getTextColors() {
    switch (_cardStyle) {
      case IOSCardPreviewStyle.minimal:
        return _CardColors(
          primary: AppTheme.textColor,
          secondary: AppTheme.secondaryTextColor,
        );
      default:
        return _CardColors(
          primary: Colors.white,
          secondary: Colors.white.withOpacity(0.9),
        );
    }
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;
    
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    _isFlipped = !_isFlipped;
  }
}

class _CardColors {
  final Color primary;
  final Color secondary;
  
  _CardColors({required this.primary, required this.secondary});
}

class _CardPatternPainter extends CustomPainter {
  final IOSCardPreviewStyle style;
  
  _CardPatternPainter(this.style);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (style == IOSCardPreviewStyle.minimal) return;
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    
    // 繪製裝飾圖案
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8 + i * 20, size.height * 0.2 + i * 10),
        5 + i * 2,
        paint,
      );
    }
    
    // 繪製線條
    final path = Path();
    path.moveTo(size.width * 0.7, 0);
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width,
      size.height * 0.6,
    );
    
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 名片預覽網格
class CardPreviewGrid extends StatelessWidget {
  final List<BusinessCard> cards;
  final void Function(BusinessCard)? onCardTap;
  final double cardHeight;
  final int crossAxisCount;

  const CardPreviewGrid({
    Key? key,
    required this.cards,
    this.onCardTap,
    this.cardHeight = 180,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return GestureDetector(
          onTap: () => onCardTap?.call(card),
          child: CardPreview(
            card: card,
            height: cardHeight,
            enableInteraction: false,
          ),
        );
      },
    );
  }
}