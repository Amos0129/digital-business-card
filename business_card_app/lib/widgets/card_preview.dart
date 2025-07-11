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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 👤 個人資訊（置中）
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: (avatarUrl == null || avatarUrl!.isEmpty)
                      ? Icon(Icons.person, size: 48, color: Colors.grey[700])
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  name.isNotEmpty ? name : '（未填寫姓名）',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (company.isNotEmpty || address.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  if (company.isNotEmpty)
                    _infoRow(Icons.business, '公司', company, link: true),
                  if (address.isNotEmpty)
                    _infoRow(Icons.location_on, '地址', address, map: true),
                ],
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

          const SizedBox(height: 30),

          // 🌐 社群平台
          if (_hasAnySocial()) ...[
            Row(
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
            const SizedBox(height: 12),
            _socialTile(
              icon: FontAwesomeIcons.line,
              label: 'LINE',
              color: lineColor,
              url: lineUrl,
              subLabel: '加入好友或發送訊息',
            ),
            _socialTile(
              icon: FontAwesomeIcons.threads,
              label: 'Threads',
              color: threadsColor,
              url: threadsUrl,
              subLabel: '瀏覽 Threads 個人頁',
            ),
            _socialTile(
              icon: FontAwesomeIcons.facebookF,
              label: 'Facebook',
              color: facebookColor,
              url: fbUrl,
              subLabel: '前往 Facebook 頁面',
            ),
            _socialTile(
              icon: FontAwesomeIcons.instagram,
              label: 'Instagram',
              color: instagramColor,
              url: igUrl,
              subLabel: '查看 IG 帳號',
            ),
          ],

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

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool link = false,
    bool map = false,
  }) {
    return GestureDetector(
      onTap: link
          ? () => _launch(
              'https://www.google.com/search?q=${Uri.encodeComponent(value)}',
            )
          : map
          ? () => _launch(
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(value)}',
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '$label：',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
