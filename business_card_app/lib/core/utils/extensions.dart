// lib/core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String 擴展方法
extension StringExtensions on String {
  /// 檢查字串是否為空或僅包含空白字符
  bool get isBlank => trim().isEmpty;
  
  /// 檢查字串是否不為空且不僅包含空白字符
  bool get isNotBlank => !isBlank;
  
  /// 首字母大寫
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  /// 每個單字首字母大寫
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  /// 移除所有空白字符
  String get removeSpaces => replaceAll(' ', '');
  
  /// 檢查是否為有效的電子郵件
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }
  
  /// 檢查是否為有效的手機號碼
  bool get isValidPhone {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(removeSpaces);
  }
  
  /// 檢查是否為有效的URL
  bool get isValidUrl {
    return RegExp(r'^https?:\/\/[^\s$.?#].[^\s]*$').hasMatch(this);
  }
  
  /// 遮罩電子郵件（顯示部分字符）
  String get maskedEmail {
    if (!isValidEmail) return this;
    final parts = split('@');
    final localPart = parts[0];
    final domainPart = parts[1];
    
    if (localPart.length <= 2) return this;
    
    final masked = localPart.substring(0, 2) + 
                  '*' * (localPart.length - 2) + 
                  '@$domainPart';
    return masked;
  }
  
  /// 遮罩手機號碼
  String get maskedPhone {
    final cleanPhone = removeSpaces;
    if (cleanPhone.length < 8) return this;
    
    return cleanPhone.substring(0, 3) + 
           '*' * (cleanPhone.length - 6) + 
           cleanPhone.substring(cleanPhone.length - 3);
  }
  
  /// 轉換為顏色
  Color toColor() {
    String hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // 添加完全不透明度
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  
  /// 檢查是否包含任何特殊字符
  bool get hasSpecialCharacters {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(this);
  }
  
  /// 截斷字串並添加省略號
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
  
  /// 反轉字串
  String get reversed => split('').reversed.join('');
}

/// DateTime 擴展方法
extension DateTimeExtensions on DateTime {
  /// 檢查是否為今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// 檢查是否為昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// 檢查是否為明天
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  /// 檢查是否為本週
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  /// 格式化為友好的時間顯示
  String get friendlyFormat {
    final now = DateTime.now();
    final difference = now.difference(this);
    
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
  
  /// 格式化為日期字串
  String get dateString => DateFormat('yyyy-MM-dd').format(this);
  
  /// 格式化為時間字串
  String get timeString => DateFormat('HH:mm').format(this);
  
  /// 格式化為日期時間字串
  String get dateTimeString => DateFormat('yyyy-MM-dd HH:mm').format(this);
  
  /// 格式化為中文日期
  String get chineseDateString => DateFormat('yyyy年MM月dd日').format(this);
  
  /// 獲取週幾的中文名稱
  String get chineseWeekday {
    const weekdays = ['週一', '週二', '週三', '週四', '週五', '週六', '週日'];
    return weekdays[weekday - 1];
  }
  
  /// 獲取月份的中文名稱
  String get chineseMonth {
    const months = [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];
    return months[month - 1];
  }
  
  /// 獲取一天的開始時間
  DateTime get startOfDay => DateTime(year, month, day);
  
  /// 獲取一天的結束時間
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  
  /// 獲取一週的開始時間（週一）
  DateTime get startOfWeek => subtract(Duration(days: weekday - 1));
  
  /// 獲取一個月的開始時間
  DateTime get startOfMonth => DateTime(year, month, 1);
  
  /// 獲取一年的開始時間
  DateTime get startOfYear => DateTime(year, 1, 1);
}

/// List 擴展方法
extension ListExtensions<T> on List<T> {
  /// 安全獲取元素（不會拋出異常）
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// 檢查是否為空或null
  bool get isNullOrEmpty => isEmpty;
  
  /// 檢查是否不為空且不為null
  bool get isNotNullOrEmpty => isNotEmpty;
  
  /// 分組
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final Map<K, List<T>> map = {};
    for (final item in this) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
  
  /// 去重
  List<T> distinct() {
    return toSet().toList();
  }
  
  /// 根據條件去重
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final Set<K> seen = {};
    return where((item) => seen.add(keySelector(item))).toList();
  }
  
  /// 分頁
  List<T> page(int pageIndex, int pageSize) {
    final startIndex = pageIndex * pageSize;
    if (startIndex >= length) return [];
    final endIndex = (startIndex + pageSize).clamp(0, length);
    return sublist(startIndex, endIndex);
  }
  
  /// 隨機元素
  T? get random {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch) % length];
  }
  
  /// 交換兩個元素的位置
  void swap(int index1, int index2) {
    if (index1 < 0 || index1 >= length || index2 < 0 || index2 >= length) {
      return;
    }
    final temp = this[index1];
    this[index1] = this[index2];
    this[index2] = temp;
  }
}

/// Color 擴展方法
extension ColorExtensions on Color {
  /// 轉換為十六進制字串
  String get hexString {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  /// 獲取亮度調整後的顏色
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final newLightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }
  
  /// 獲取變亮後的顏色
  Color lighten(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final newLightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }
  
  /// 獲取對比色
  Color get contrastColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  /// 檢查是否為深色
  bool get isDark => computeLuminance() < 0.5;
  
  /// 檢查是否為淺色
  bool get isLight => !isDark;
}

/// BuildContext 擴展方法
extension BuildContextExtensions on BuildContext {
  /// 獲取主題
  ThemeData get theme => Theme.of(this);
  
  /// 獲取文字主題
  TextTheme get textTheme => theme.textTheme;
  
  /// 獲取色彩方案
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// 獲取媒體查詢
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// 獲取螢幕尺寸
  Size get screenSize => mediaQuery.size;
  
  /// 獲取螢幕寬度
  double get screenWidth => screenSize.width;
  
  /// 獲取螢幕高度
  double get screenHeight => screenSize.height;
  
  /// 檢查是否為深色模式
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  /// 檢查是否為手機
  bool get isMobile => screenWidth < 600;
  
  /// 檢查是否為平板
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  
  /// 檢查是否為桌面
  bool get isDesktop => screenWidth >= 900;
  
  /// 顯示 SnackBar
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  
  /// 隱藏鍵盤
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
  
  /// 導航到新頁面
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  /// 替換當前頁面
  Future<T?> pushReplacement<T, TO>(Widget page, {TO? result}) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }
  
  /// 返回上一頁
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
  
  /// 檢查是否可以返回
  bool get canPop => Navigator.of(this).canPop();
}

/// double 擴展方法
extension DoubleExtensions on double {
  /// 轉換為像素（根據設備像素比）
  double toPixels(BuildContext context) {
    return this * MediaQuery.of(context).devicePixelRatio;
  }
  
  /// 限制在指定範圍內
  double clampTo(double min, double max) {
    return clamp(min, max);
  }
  
  /// 轉換為百分比字串
  String toPercentage({int decimalPlaces = 1}) {
    return '${(this * 100).toStringAsFixed(decimalPlaces)}%';
  }
  
  /// 檢查是否接近另一個值
  bool isCloseTo(double other, {double tolerance = 0.001}) {
    return (this - other).abs() < tolerance;
  }
}

/// int 擴展方法
extension IntExtensions on int {
  /// 轉換為時長（秒）
  Duration get seconds => Duration(seconds: this);
  
  /// 轉換為時長（分鐘）
  Duration get minutes => Duration(minutes: this);
  
  /// 轉換為時長（小時）
  Duration get hours => Duration(hours: this);
  
  /// 轉換為時長（天）
  Duration get days => Duration(days: this);
  
  /// 檢查是否為偶數
  bool get isEven => this % 2 == 0;
  
  /// 檢查是否為奇數
  bool get isOdd => !isEven;
  
  /// 格式化為文件大小
  String get formatBytes {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// 轉換為序數詞
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1: return '${this}st';
      case 2: return '${this}nd';
      case 3: return '${this}rd';
      default: return '${this}th';
    }
  }
}