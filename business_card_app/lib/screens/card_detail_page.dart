import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/social_icon_button.dart';
import '../widgets/info_row.dart';

import '../models/unified_card.dart';

import '../utils/qr_share_utils.dart';

class CardDetailPage extends StatefulWidget {
  final UnifiedCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late TextEditingController _remarkController;
  bool showQr = false;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(
      text: widget.card.initialRemark ?? '',
    );
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    final socialItems = <Widget>[
      if (card.hasFb && card.fbUrl != null)
        SocialIconButton(
          icon: FontAwesomeIcons.facebookF,
          label: 'Facebook',
          url: card.fbUrl!,
        ),
      if (card.hasIg && card.igUrl != null)
        SocialIconButton(
          icon: FontAwesomeIcons.instagram,
          label: 'Instagram',
          url: card.igUrl!,
        ),
      if (card.hasLine && card.lineUrl != null)
        SocialIconButton(
          icon: FontAwesomeIcons.line,
          label: 'LINE',
          url: card.lineUrl!,
        ),
      if (card.hasThreads && card.threadsUrl != null)
        SocialIconButton(
          icon: FontAwesomeIcons.threads,
          label: 'Threads',
          url: card.threadsUrl!,
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          card.name,
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF4A6CFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: '分享名片',
            onPressed: () => showQrShareDialog(context, card), // ✅ 呼叫外部共用函式
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: card.avatarUrl != null
                            ? NetworkImage(card.avatarUrl!)
                            : null,
                        child: card.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 34,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              style: GoogleFonts.notoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InfoRow(
                              icon: Icons.business,
                              label: '公司',
                              value: card.company ?? '',
                            ),
                            if (card.address != null)
                              InfoRow(
                                icon: Icons.location_on,
                                label: '地址',
                                value: card.address!,
                              ),
                            InfoRow(
                              icon: Icons.phone,
                              label: '電話',
                              value: card.phone ?? '',
                            ),
                            InfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: card.email ?? '',
                            ),
                            InfoRow(
                              icon: Icons.group,
                              label: '群組',
                              value: card.group ?? '',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _remarkInput(),
                  if (socialItems.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: socialItems,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _remarkInput() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: _remarkController,
        onFieldSubmitted: (_) {
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("備註已更新")));
        },
        decoration: const InputDecoration(
          hintText: "輸入備註（例如：朋友介紹）",
          border: InputBorder.none,
        ),
        style: GoogleFonts.notoSans(fontSize: 14),
      ),
    );
  }

  void _shareContactInfo() {
    final c = widget.card;
    final info =
        '''
${c.name}
${c.company}
${c.address ?? ''}
${c.phone}
${c.email}
''';
    Share.share(info);
  }
}
