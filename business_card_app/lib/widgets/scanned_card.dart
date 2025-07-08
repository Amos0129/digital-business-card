import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';

import '../widgets/app_button.dart';
import '../widgets/info_row.dart';
import '../widgets/social_icon_button.dart';

class ScannedCard extends StatefulWidget {

  final int cardId;
  final String name;
  final String phone;
  final String email;
  final String company;
  final String address;
  final String? avatarUrl;
  final String initialRemark;
  final bool hasFb;
  final bool hasIg;
  final bool hasLine;
  final bool hasThreads;
  final String? fbUrl;
  final String? igUrl;
  final String? lineUrl;
  final String? threadsUrl;

  const ScannedCard({
    super.key,
    required this.cardId,
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.address,
    this.avatarUrl,
    this.initialRemark = "",
    this.hasFb = false,
    this.hasIg = false,
    this.hasLine = false,
    this.hasThreads = false,
    this.fbUrl,
    this.igUrl,
    this.lineUrl,
    this.threadsUrl,
  });

  @override
  State<ScannedCard> createState() => _ScannedCardState();
}

class _ScannedCardState extends State<ScannedCard> {
  late TextEditingController _remarkController;
  final FocusNode _remarkFocus = FocusNode();
  bool showQr = false;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.initialRemark);
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _remarkFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socialItems = <Widget>[];
    if (widget.hasFb && widget.fbUrl != null) {
      socialItems.add(
        SocialIconButton(
          icon: FontAwesomeIcons.facebookF,
          label: 'Facebook',
          url: widget.fbUrl!,
        ),
      );
    }
    if (widget.hasIg && widget.igUrl != null) {
      socialItems.add(
        SocialIconButton(
          icon: FontAwesomeIcons.instagram,
          label: 'Instagram',
          url: widget.igUrl!,
        ),
      );
    }
    if (widget.hasLine && widget.lineUrl != null) {
      socialItems.add(
        SocialIconButton(
          icon: FontAwesomeIcons.line,
          label: 'LINE',
          url: widget.lineUrl!,
        ),
      );
    }
    if (widget.hasThreads && widget.threadsUrl != null) {
      socialItems.add(
        SocialIconButton(
          icon: FontAwesomeIcons.threads,
          label: 'Threads',
          url: widget.threadsUrl!,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.avatarUrl != null
                    ? NetworkImage(widget.avatarUrl!)
                    : null,
                child: widget.avatarUrl == null
                    ? const Icon(Icons.person, size: 30, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      icon: Icons.business,
                      label: '公司',
                      value: widget.company,
                    ),
                    InfoRow(
                      icon: Icons.location_on,
                      label: '地址',
                      value: widget.address,
                    ),
                    InfoRow(
                      icon: Icons.phone,
                      label: '電話',
                      value: widget.phone,
                    ),
                    InfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: widget.email,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(showQr ? Icons.close : Icons.qr_code),
                onPressed: () => setState(() => showQr = !showQr),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _remarkInput(),
          if (socialItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: socialItems,
            ),
          ],
          if (showQr) ...[
            const SizedBox(height: 20),
            QrImageView(
              data: widget.cardId.toString(),
              version: QrVersions.auto,
              size: 140.0,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: "分享",
                icon: const Icon(CupertinoIcons.share_up),
                onPressed: _shareContactInfo,
              ),
            ),
          ],
        ],
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
        focusNode: _remarkFocus,
        onFieldSubmitted: (val) {
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("備註已更新")));
        },
        decoration: const InputDecoration(
          hintText: "輸入備註（例如：朋友介紹）",
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _shareContactInfo() {
    final info =
        '''
${widget.name}
${widget.company}
${widget.address}
${widget.phone}
${widget.email}
''';
    Share.share(info);
  }
}
