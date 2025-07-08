import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/unified_card.dart';
import '../utils/qr_share_utils.dart';
import '../enums/view_mode.dart';

class UnifiedCardItem extends StatelessWidget {
  final UnifiedCard card;
  final ViewMode viewMode;
  final VoidCallback? onDelete;
  final VoidCallback? onAddToGroup;
  final VoidCallback? onShare;
  final VoidCallback? onTap; // ✅ 新增 onTap
  final Widget? dragHandle;

  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelected;

  const UnifiedCardItem({
    super.key,
    required this.card,
    required this.viewMode,
    this.onDelete,
    this.onAddToGroup,
    this.onShare,
    this.onTap, // ✅ 加入建構子
    this.dragHandle,

    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final content = viewMode == ViewMode.card
        ? card.isPaperBased
              ? _buildPaperCardView(context)
              : _buildCardView(context)
        : _buildListView(context);

    return Slidable(
      key: ValueKey(card.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.75,
        children: [
          SlidableAction(
            onPressed: (_) => onAddToGroup?.call(),
            backgroundColor: const Color(0xFF4A6CFF),
            foregroundColor: Colors.white,
            icon: Icons.group_add,
            label: '加入群組',
          ),
          SlidableAction(
            onPressed: (_) => showQrShareDialog(context, card),
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: '分享',
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '刪除',
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildCardView(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: isSelectionMode ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 多選模式顯示 checkbox
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Checkbox(value: isSelected, onChanged: onSelected),
                  ),

                // 頭像
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: card.avatarUrl != null
                      ? NetworkImage(card.avatarUrl!)
                      : null,
                  child: card.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),

                const SizedBox(width: 14),

                // 右邊文字內容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.safeName,
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.safeCompany,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        card.group ?? '',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (card.phone != null)
                        Text(
                          card.safePhone,
                          style: GoogleFonts.notoSans(fontSize: 14),
                        ),
                      if (card.email != null)
                        Text(
                          card.safeEmail,
                          style: GoogleFonts.notoSans(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ QR Code icon
        if (card.isScanned)
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                if (!isSelectionMode) showQrShareDialog(context, card);
              },
              borderRadius: BorderRadius.circular(24),
              child: const Icon(Icons.qr_code, color: Colors.grey),
            ),
          ),

        // ✅ 拖曳 icon（保持不變）
        if (dragHandle != null)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: dragHandle!,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaperCardView(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: isSelectionMode ? null : onTap,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 多選模式時顯示 checkbox
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Checkbox(value: isSelected, onChanged: onSelected),
                  ),

                const Icon(Icons.credit_card, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.safeName,
                        style: GoogleFonts.notoSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.safeCompany,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        card.group ?? '',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (card.phone != null)
                        Text(
                          card.safePhone,
                          style: GoogleFonts.notoSans(fontSize: 14),
                        ),
                      if (card.email != null)
                        Text(
                          card.safeEmail,
                          style: GoogleFonts.notoSans(fontSize: 14),
                        ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '此名片來自紙本掃描',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ QRCode icon：右上角浮動，但多選模式禁用
        if (card.isScanned)
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                if (!isSelectionMode) showQrShareDialog(context, card);
              },
              borderRadius: BorderRadius.circular(24),
              child: const Icon(Icons.qr_code, color: Colors.grey),
            ),
          ),

        // ✅ 拖曳 handle（不變）
        if (dragHandle != null)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: dragHandle!,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListTile(
      onTap: isSelectionMode ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      // ✅ 多選模式下顯示 Checkbox，否則顯示大頭貼
      leading: isSelectionMode
          ? Checkbox(value: isSelected, onChanged: onSelected)
          : CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              backgroundImage: card.avatarUrl != null
                  ? NetworkImage(card.avatarUrl!)
                  : null,
              child: card.avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),

      title: Text(
        card.safeName,
        style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        card.safeCompany,
        style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
      ),

      // ✅ 多選模式下禁用分享按鈕
      trailing: card.isScanned
          ? InkWell(
              onTap: () {
                if (!isSelectionMode) onShare?.call();
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.qr_code_scanner, color: Colors.grey),
              ),
            )
          : null,
    );
  }
}
