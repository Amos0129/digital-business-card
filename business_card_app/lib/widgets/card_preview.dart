import 'package:flutter/material.dart';
import 'package:business_card_app/constants/style_config.dart' as style_utils;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CardPreview extends StatelessWidget {
  final String styleId;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String address;
  final String group;
  final String note;

  final String? fbUrl;
  final String? igUrl;
  final String? lineUrl;
  final String? threadsUrl;
  final String? avatarUrl;

  const CardPreview({
    super.key,
    required this.styleId,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.address,
    this.group = '',
    this.note = '',
    this.fbUrl,
    this.igUrl,
    this.lineUrl,
    this.threadsUrl,
    this.avatarUrl,
  });

  static const Color lineColor = Color(0xFF00C300);
  static const Color threadsColor = Color(0xFF000000);
  static const Color facebookColor = Color(0xFF1877F2);
  static const Color instagramColor = Color(0xFFE1306C);

  @override
  Widget build(BuildContext context) {
    final style = style_utils.getStyleById(styleId);
    final Color textColor = style['text'] as Color? ?? Colors.black;
    final Color bgColor = style['bg'] as Color? ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 個人資訊卡片區塊
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null || avatarUrl!.isEmpty
                      ? Icon(Icons.person, size: 48, color: Colors.grey[700])
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                if (company.isNotEmpty || address.isNotEmpty)
                  Column(
                    children: [
                      if (company.isNotEmpty)
                        GestureDetector(
                          onTap: () => _launch(
                            'https://www.google.com/search?q=${Uri.encodeComponent(company)}',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.business,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '公司：',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  company,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (address.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: GestureDetector(
                            onTap: () => _launch(
                              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '地址：',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _circleButton(
                      FontAwesomeIcons.phone,
                      phone.isNotEmpty ? () => _launchTel(phone) : null,
                    ),
                    _circleButton(
                      FontAwesomeIcons.envelope,
                      email.isNotEmpty ? () => _launchMail(email) : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🌐 社交平台區標題
          if (_hasAnySocial())
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.public, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '社交平台',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // 🌐 社交與通訊平台（統一樣式呈現）
          Column(
            children: [
              _socialTile(
                icon: FontAwesomeIcons.line,
                label: 'LINE',
                subLabel: '加入好友或發送訊息',
                url: lineUrl,
                color: lineColor,
              ),
              _socialTile(
                icon: FontAwesomeIcons.threads,
                label: 'Threads',
                subLabel: '瀏覽 Threads 個人頁',
                url: threadsUrl,
                color: threadsColor,
              ),
              _socialTile(
                icon: FontAwesomeIcons.facebookF,
                label: 'Facebook',
                subLabel: '前往 Facebook 頁面',
                url: fbUrl,
                color: facebookColor,
              ),
              _socialTile(
                icon: FontAwesomeIcons.instagram,
                label: 'Instagram',
                subLabel: '查看 IG 帳號',
                url: igUrl,
                color: instagramColor,
              ),
            ],
          ),

          // 📌 群組與備註
          if (group.isNotEmpty || note.isNotEmpty) ...[
            const SizedBox(height: 24),
            if (group.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.group, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text('群組：$group', style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            if (note.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  note,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 18,
            color: onTap != null ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _socialTile({
    required IconData icon,
    required String label,
    required Color color,
    String? url,
    String? subLabel,
  }) {
    final bool clickable = _isValidUrl(url);
    return GestureDetector(
      onTap: clickable ? () => _launch(_formatUrl(url!)) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            FaIcon(icon, size: 20, color: clickable ? color : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Text(
                    clickable ? (subLabel ?? '') : '尚未提供',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: clickable ? Colors.black : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidUrl(String? url) => url != null && url.trim().isNotEmpty;

  bool _hasAnySocial() =>
      _isValidUrl(lineUrl) ||
      _isValidUrl(threadsUrl) ||
      _isValidUrl(fbUrl) ||
      _isValidUrl(igUrl);

  String _formatUrl(String url) =>
      url.startsWith('http') ? url : 'https://$url';

  Future<void> _launch(String url) async {
    try {
      final uri = Uri.parse(url);

      if (!await canLaunchUrl(uri)) {
        debugPrint('❌ 無法開啟：$url');
        return;
      }

      final success = await launchUrl(uri, mode: LaunchMode.platformDefault);

      if (!success) {
        debugPrint('❌ Launch 失敗：$url');
      }
    } catch (e) {
      debugPrint('🚨 錯誤開啟網址 $url：$e');
    }
  }

  _launchTel(String phoneNumber) {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  _launchMail(String email) {
    final uri = Uri(scheme: 'mailto', path: email);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
