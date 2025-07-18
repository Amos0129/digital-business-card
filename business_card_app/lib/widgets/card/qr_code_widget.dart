import 'package:flutter/material.dart';
import '../../core/theme.dart';

class QRCodeWidget extends StatelessWidget {
  final String data;
  final double? size;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool showData;
  final EdgeInsetsGeometry? padding;

  const QRCodeWidget({
    Key? key,
    required this.data,
    this.size,
    this.foregroundColor,
    this.backgroundColor,
    this.showData = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQRCode(),
          if (showData) ...[
            const SizedBox(height: 12),
            _buildDataText(),
          ],
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        width: size ?? 200,
        height: size ?? 200,
        decoration: BoxDecoration(
          color: foregroundColor ?? Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code,
                size: (size ?? 200) * 0.4,
                color: backgroundColor ?? Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                'QR Code',
                style: TextStyle(
                  color: backgroundColor ?? Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: $data',
                style: TextStyle(
                  color: (backgroundColor ?? Colors.white).withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        data,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textColor,
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class QRCodeDialog extends StatelessWidget {
  final String data;
  final String? title;
  final String? description;
  final double qrSize;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const QRCodeDialog({
    Key? key,
    required this.data,
    this.title,
    this.description,
    this.qrSize = 250,
    this.onShare,
    this.onSave,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String data,
    String? title,
    String? description,
    double qrSize = 250,
    VoidCallback? onShare,
    VoidCallback? onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => QRCodeDialog(
        data: data,
        title: title,
        description: description,
        qrSize: qrSize,
        onShare: onShare,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            if (description != null) ...[
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            
            // QR Code
            QRCodeWidget(
              data: data,
              size: qrSize,
              padding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 24),
            
            // 動作按鈕
            Row(
              children: [
                if (onSave != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('儲存'),
                      onPressed: onSave,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (onShare != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                      onPressed: onShare,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessCardQR extends StatelessWidget {
  final String cardId;
  final String? cardName;
  final double? size;

  const BusinessCardQR({
    Key? key,
    required this.cardId,
    this.cardName,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QRCodeWidget(
      data: cardId,
      size: size,
      showData: true,
    );
  }

  static Future<void> showDialog(
    BuildContext context, {
    required String cardId,
    String? cardName,
  }) {
    return QRCodeDialog.show(
      context,
      data: cardId,
      title: '名片QR碼',
      description: cardName != null ? '$cardName 的名片' : '掃描此QR碼查看名片',
      onShare: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('分享功能開發中')),
        );
      },
      onSave: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('儲存功能開發中')),
        );
      },
    );
  }
}

class QRCodeCard extends StatelessWidget {
  final String data;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double qrSize;

  const QRCodeCard({
    Key? key,
    required this.data,
    required this.title,
    this.subtitle,
    this.onTap,
    this.qrSize = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              QRCodeWidget(
                data: data,
                size: qrSize,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}