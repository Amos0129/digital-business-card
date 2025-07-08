import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final VoidCallback? onEdit;

  const ProfileCard({
    super.key,
    required this.name,
    this.photoUrl,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                // 頭像 / logo
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),

                const SizedBox(width: 20),

                // 名稱
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.notoSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 編輯按鈕浮動於右上角
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 20),
              tooltip: '編輯個人資料',
              splashRadius: 20,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}