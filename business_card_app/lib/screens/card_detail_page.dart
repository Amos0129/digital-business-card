import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/social_icon_button.dart';

import '../models/unified_card.dart';

import '../utils/qr_share_utils.dart';
import '../widgets/card_preview.dart';

class CardDetailPage extends StatefulWidget {
  final UnifiedCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(
      text: widget.card.initialRemark ?? '',
    );
    _remarkController.addListener(() => setState(() {})); // ✅ 寫入就重建畫面
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    debugPrint('Facebook URL: ${card.fbUrl}');
    debugPrint('Instagram URL: ${card.igUrl}');
    debugPrint('LINE URL: ${card.lineUrl}');
    debugPrint('Threads URL: ${card.threadsUrl}');

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
            onPressed: () => showQrShareDialog(context, card),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardPreview(
                  styleId: card.style ?? 'default',
                  name: card.name,
                  company: card.company ?? '',
                  phone: card.phone ?? '',
                  email: card.email ?? '',
                  address: card.address ?? '',
                  group: card.group ?? '',
                  note: _remarkController.text,
                  fbUrl: card.fbUrl,
                  igUrl: card.igUrl,
                  lineUrl: card.lineUrl,
                  threadsUrl: card.threadsUrl,
                  avatarUrl: card.avatarUrl,
                ),

                const SizedBox(height: 32),

                Text(
                  '備註',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _remarkInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _remarkInput() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      ),
    );
  }
}
