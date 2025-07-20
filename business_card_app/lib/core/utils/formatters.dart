// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

/// 格式化工具類
/// 
/// 提供各種資料格式化功能
/// 包括數字、日期、電話、文字等格式化
class Formatters {
  // 防止實例化
  Formatters._();

  // ========== 日期時間格式化器 ==========
  
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _chineseDateFormat = DateFormat('yyyy年MM月dd日');
  static final DateFormat _chineseTimeFormat = DateFormat('HH時mm分');
  static final DateFormat _birthdayFormat = DateFormat('MM月dd日');

  /// 格式化日期為 yyyy-MM-dd
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  /// 格式化時間為 HH:mm
  static String formatTime(DateTime? time) {
    if (time == null) return '';
    return _timeFormat.format(time);
  }

  /// 格式化日期時間為 yyyy-MM-dd HH:mm
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime);
  }

  /// 格式化為中文日期
  static String formatChineseDate(DateTime? date) {
    if (date == null) return '';
    return _chineseDateFormat.format(date);
  }

  /// 格式化為中文時間
  static String formatChineseTime(DateTime? time) {
    if (time == null) return '';
    return _chineseTimeFormat.format(time);
  }

  /// 格式化生日（不顯示年份）
  static String formatBirthday(DateTime? birthday) {
    if (birthday == null) return '';
    return _birthdayFormat.format(birthday);
  }

  /// 格式化相對時間（多久之前）
  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) return '昨天';
      if (difference.inDays < 7) return '${difference.inDays} 天前';
      if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} 週前';
      if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} 個月前';
      return '${(difference.inDays / 365).floor()} 年前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} 小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} 分鐘前';
    } else {
      return '剛剛';
    }
  }

  // ========== 數字格式化器 ==========
  
  static final NumberFormat _numberFormat = NumberFormat('#,##0');
  static final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'zh_TW', symbol: 'NT\);
  static final NumberFormat _percentFormat = NumberFormat.percentPattern();

  /// 格式化數字（加上千分位符號）
  static String formatNumber(num? number) {
    if (number == null) return '0';
    return _numberFormat.format(number);
  }

  /// 格式化金額
  static String formatCurrency(num? amount) {
    if (amount == null) return 'NT\$0';
    return _currencyFormat.format(amount);
  }

  /// 格式化百分比
  static String formatPercentage(double? value, {int decimalPlaces = 1}) {
    if (value == null) return '0%';
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }

  /// 格式化文件大小
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// 格式化評分（星級）
  static String formatRating(double? rating, {int maxStars = 5}) {
    if (rating == null) return '☆' * maxStars;
    
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final emptyStars = maxStars - fullStars - (hasHalfStar ? 1 : 0);
    
    return '★' * fullStars + 
           (hasHalfStar ? '☆' : '') + 
           '☆' * emptyStars;
  }

  // ========== 電話號碼格式化器 ==========
  
  /// 格式化台灣手機號碼
  static String formatTaiwanMobile(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    
    // 移除所有非數字字符
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // 台灣手機號碼格式：09xx-xxx-xxx
    if (cleaned.length == 10 && cleaned.startsWith('09')) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    
    return phone; // 如果不符合格式，返回原始字串
  }

  /// 格式化台灣市話號碼
  static String formatTaiwanLandline(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // 台北、新北、基隆、桃園：(02) xxxx-xxxx
    if (cleaned.length == 10 && cleaned.startsWith('02')) {
      return '(02) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    }
    
    // 其他地區：(0x) xxx-xxxx
    if (cleaned.length == 9 && cleaned.startsWith('0')) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    
    return phone;
  }

  /// 遮罩電話號碼
  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 8) return phone;
    
    return '${cleaned.substring(0, 3)}****${cleaned.substring(cleaned.length - 3)}';
  }

  // ========== 身份證號格式化器 ==========
  
  /// 格式化台灣身份證號
  static String formatTaiwanId(String? id) {
    if (id == null || id.isEmpty) return '';
    
    final cleaned = id.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 1)}${cleaned.substring(1, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    
    return id;
  }

  /// 遮罩身份證號
  static String maskId(String? id) {
    if (id == null || id.isEmpty) return '';
    
    final cleaned = id.replaceAll(RegExp(r'[^\w]'), '');
    if (cleaned.length < 6) return id;
    
    return '${cleaned.substring(0, 2)}****${cleaned.substring(cleaned.length - 2)}';
  }

  // ========== 地址格式化器 ==========
  
  /// 格式化台灣地址
  static String formatTaiwanAddress(String? address) {
    if (address == null || address.isEmpty) return '';
    
    // 簡單的地址格式化，去除多餘空格
    return address.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// 縮短地址顯示
  static String shortenAddress(String? address, {int maxLength = 30}) {
    if (address == null || address.isEmpty) return '';
    
    if (address.length <= maxLength) return address;
    return '${address.substring(0, maxLength - 3)}...';
  }

  // ========== 文字格式化器 ==========
  
  /// 格式化名稱（首字母大寫）
  static String formatName(String? name) {
    if (name == null || name.isEmpty) return '';
    
    return name.split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }

  /// 遮罩姓名
  static String maskName(String? name) {
    if (name == null || name.isEmpty) return '';
    
    if (name.length <= 1) return name;
    if (name.length == 2) return '${name[0]}*';
    
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
  }

  /// 截斷文字並添加省略號
  static String truncateText(String? text, int maxLength, {String ellipsis = '...'}) {
    if (text == null || text.isEmpty) return '';
    
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$ellipsis';
  }

  /// 格式化Email
  static String formatEmail(String? email) {
    if (email == null || email.isEmpty) return '';
    return email.toLowerCase().trim();
  }

  /// 遮罩Email
  static String maskEmail(String? email) {
    if (email == null || email.isEmpty) return '';
    
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final localPart = parts[0];
    final domainPart = parts[1];
    
    if (localPart.length <= 2) return email;
    
    return '${localPart.substring(0, 2)}****@$domainPart';
  }

  // ========== URL格式化器 ==========
  
  /// 格式化URL（添加http協議）
  static String formatUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    
    return 'https://$trimmed';
  }

  /// 縮短URL顯示
  static String shortenUrl(String? url, {int maxLength = 50}) {
    if (url == null || url.isEmpty) return '';
    
    if (url.length <= maxLength) return url;
    
    // 保留協議和域名部分
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.isNotEmpty) {
      final domain = '${uri.scheme}://${uri.host}';
      if (domain.length < maxLength - 3) {
        return '$domain...';
      }
    }
    
    return '${url.substring(0, maxLength - 3)}...';
  }

  // ========== 統計格式化器 ==========
  
  /// 格式化計數（如點讚數、瀏覽數）
  static String formatCount(int? count) {
    if (count == null || count == 0) return '0';
    
    if (count < 1000) return count.toString();
    if (count < 10000) return '${(count / 1000).toStringAsFixed(1)}K';
    if (count < 100000) return '${(count / 10000).toStringAsFixed(1)}萬';
    
    return '${(count / 10000).toStringAsFixed(0)}萬';
  }

  /// 格式化持續時間
  static String formatDuration(Duration? duration) {
    if (duration == null) return '0秒';
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (days > 0) {
      return '${days}天${hours}小時';
    } else if (hours > 0) {
      return '${hours}小時${minutes}分鐘';
    } else if (minutes > 0) {
      return '${minutes}分鐘';
    } else {
      return '${seconds}秒';
    }
  }
}

// ========== 輸入格式化器（用於TextFormField） ==========

/// 手機號碼輸入格式化器
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.length <= 4) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 7) {
      return newValue.copyWith(
        text: '${text.substring(0, 4)}-${text.substring(4)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else if (text.length <= 10) {
      return newValue.copyWith(
        text: '${text.substring(0, 4)}-${text.substring(4, 7)}-${text.substring(7)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    }
    
    return oldValue;
  }
}

/// 身份證號輸入格式化器
class IdCardInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (text.length <= 10) {
      return newValue.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    
    return oldValue;
  }
}

/// 數字輸入格式化器（千分位）
class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final number = int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) {
      return oldValue;
    }
    
    final formatter = NumberFormat('#,##0');
    final formattedText = formatter.format(number);
    
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}