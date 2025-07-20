// lib/core/utils/validators.dart
import '../constants/app_constants.dart';

/// 驗證工具類
/// 
/// 提供各種資料驗證功能
/// 包括表單驗證、格式驗證等
class Validators {
  // 防止實例化
  Validators._();

  // ========== 基礎驗證 ==========
  
  /// 檢查是否為空
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '此欄位'}不可為空';
    }
    return null;
  }
  
  /// 檢查最小長度
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? '此欄位'}至少需要 $minLength 個字符';
    }
    return null;
  }
  
  /// 檢查最大長度
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? '此欄位'}不可超過 $maxLength 個字符';
    }
    return null;
  }
  
  /// 檢查長度範圍
  static String? lengthRange(String? value, int minLength, int maxLength, [String? fieldName]) {
    if (value == null || value.length < minLength || value.length > maxLength) {
      return '${fieldName ?? '此欄位'}長度需要在 $minLength-$maxLength 個字符之間';
    }
    return null;
  }

  // ========== 電子郵件驗證 ==========
  
  /// 驗證電子郵件格式
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電子郵件';
    }
    
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return '請輸入有效的電子郵件格式';
    }
    
    if (value.length > AppConstants.maxEmailLength) {
      return '電子郵件長度不可超過 ${AppConstants.maxEmailLength} 個字符';
    }
    
    return null;
  }
  
  /// 驗證電子郵件（可選）
  static String? optionalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 允許為空
    }
    return email(value);
  }

  // ========== 密碼驗證 ==========
  
  /// 驗證密碼
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return '密碼至少需要 ${AppConstants.minPasswordLength} 個字符';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return '密碼不可超過 ${AppConstants.maxPasswordLength} 個字符';
    }
    
    return null;
  }
  
  /// 驗證強密碼
  static String? strongPassword(String? value) {
    final basicValidation = password(value);
    if (basicValidation != null) return basicValidation;
    
    if (value == null) return null;
    
    // 檢查是否包含大寫字母
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return '密碼需要包含至少一個大寫字母';
    }
    
    // 檢查是否包含小寫字母
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return '密碼需要包含至少一個小寫字母';
    }
    
    // 檢查是否包含數字
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return '密碼需要包含至少一個數字';
    }
    
    // 檢查是否包含特殊字符
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return '密碼需要包含至少一個特殊字符';
    }
    
    return null;
  }
  
  /// 確認密碼驗證
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return '請確認密碼';
    }
    
    if (value != originalPassword) {
      return '密碼不一致';
    }
    
    return null;
  }

  // ========== 電話號碼驗證 ==========
  
  /// 驗證電話號碼
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電話號碼';
    }
    
    // 移除空格和特殊字符
    final cleanedPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (!RegExp(AppConstants.phoneRegex).hasMatch(cleanedPhone)) {
      return '請輸入有效的電話號碼';
    }
    
    if (cleanedPhone.length > AppConstants.maxPhoneLength) {
      return '電話號碼過長';
    }
    
    return null;
  }
  
  /// 驗證台灣手機號碼
  static String? taiwanMobile(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入手機號碼';
    }
    
    final cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (!RegExp(r'^09\d{8}$').hasMatch(cleanedPhone)) {
      return '請輸入有效的台灣手機號碼（09xxxxxxxx）';
    }
    
    return null;
  }
  
  /// 驗證電話號碼（可選）
  static String? optionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return phone(value);
  }

  // ========== URL 驗證 ==========
  
  /// 驗證 URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入網址';
    }
    
    if (!RegExp(AppConstants.urlRegex).hasMatch(value)) {
      return '請輸入有效的網址格式';
    }
    
    return null;
  }
  
  /// 驗證 URL（可選）
  static String? optionalUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return url(value);
  }

  // ========== 姓名驗證 ==========
  
  /// 驗證姓名
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '請輸入姓名';
    }
    
    if (value.trim().length > AppConstants.maxCardNameLength) {
      return '姓名不可超過 ${AppConstants.maxCardNameLength} 個字符';
    }
    
    // 檢查是否只包含字母、中文字符和空格
    if (!RegExp(r'^[a-zA-Z\u4e00-\u9fa5\s]+$').hasMatch(value.trim())) {
      return '姓名只能包含中文、英文字母和空格';
    }
    
    return null;
  }

  // ========== 公司相關驗證 ==========
  
  /// 驗證公司名稱
  static String? companyName(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > AppConstants.maxCompanyNameLength) {
        return '公司名稱不可超過 ${AppConstants.maxCompanyNameLength} 個字符';
      }
    }
    return null;
  }
  
  /// 驗證職位
  static String? position(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > AppConstants.maxPositionLength) {
        return '職位不可超過 ${AppConstants.maxPositionLength} 個字符';
      }
    }
    return null;
  }

  // ========== 地址驗證 ==========
  
  /// 驗證地址
  static String? address(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > AppConstants.maxAddressLength) {
        return '地址不可超過 ${AppConstants.maxAddressLength} 個字符';
      }
    }
    return null;
  }

  // ========== 數字驗證 ==========
  
  /// 驗證整數
  static String? integer(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '請輸入${fieldName ?? '數字'}';
    }
    
    if (int.tryParse(value) == null) {
      return '請輸入有效的整數';
    }
    
    return null;
  }
  
  /// 驗證正整數
  static String? positiveInteger(String? value, [String? fieldName]) {
    final basicValidation = integer(value, fieldName);
    if (basicValidation != null) return basicValidation;
    
    final number = int.parse(value!);
    if (number <= 0) {
      return '${fieldName ?? '數字'}必須大於 0';
    }
    
    return null;
  }
  
  /// 驗證數字範圍
  static String? numberRange(String? value, int min, int max, [String? fieldName]) {
    final basicValidation = integer(value, fieldName);
    if (basicValidation != null) return basicValidation;
    
    final number = int.parse(value!);
    if (number < min || number > max) {
      return '${fieldName ?? '數字'}需要在 $min-$max 之間';
    }
    
    return null;
  }

  // ========== 身份證驗證 ==========
  
  /// 驗證台灣身份證號
  static String? taiwanId(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入身份證號';
    }
    
    final cleanedId = value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (!RegExp(r'^[A-Z][1-2]\d{8}$').hasMatch(cleanedId)) {
      return '請輸入有效的台灣身份證號';
    }
    
    // 驗證身份證號檢查碼
    if (!_validateTaiwanIdChecksum(cleanedId)) {
      return '身份證號格式錯誤';
    }
    
    return null;
  }
  
  /// 驗證台灣身份證號檢查碼
  static bool _validateTaiwanIdChecksum(String id) {
    const letterMap = {
      'A': 10, 'B': 11, 'C': 12, 'D': 13, 'E': 14, 'F': 15, 'G': 16,
      'H': 17, 'I': 34, 'J': 18, 'K': 19, 'L': 20, 'M': 21, 'N': 22,
      'O': 35, 'P': 23, 'Q': 24, 'R': 25, 'S': 26, 'T': 27, 'U': 28,
      'V': 29, 'W': 32, 'X': 30, 'Y': 31, 'Z': 33
    };
    
    final firstLetter = letterMap[id[0]];
    if (firstLetter == null) return false;
    
    var sum = (firstLetter ~/ 10) + (firstLetter % 10) * 9;
    
    for (int i = 1; i < 9; i++) {
      sum += int.parse(id[i]) * (9 - i);
    }
    
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(id[9]);
  }

  // ========== 組合驗證器 ==========
  
  /// 名片姓名驗證
  static String? cardName(String? value) {
    return compose([
      (v) => required(v, '姓名'),
      (v) => maxLength(v, AppConstants.maxCardNameLength, '姓名'),
      name,
    ])(value);
  }
  
  /// 名片電話驗證
  static String? cardPhone(String? value) {
    return compose([
      optionalPhone,
    ])(value);
  }
  
  /// 名片電子郵件驗證
  static String? cardEmail(String? value) {
    return compose([
      optionalEmail,
    ])(value);
  }
  
  /// 群組名稱驗證
  static String? groupName(String? value) {
    return compose([
      (v) => required(v, '群組名稱'),
      (v) => maxLength(v, AppConstants.maxGroupNameLength, '群組名稱'),
    ])(value);
  }
  
  /// 搜尋關鍵字驗證
  static String? searchKeyword(String? value) {
    return compose([
      (v) => required(v, '搜尋關鍵字'),
      (v) => maxLength(v, AppConstants.maxSearchKeywordLength, '搜尋關鍵字'),
    ])(value);
  }

  // ========== 工具方法 ==========
  
  /// 組合多個驗證器
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
  
  /// 檢查值是否在列表中
  static String? isInList(String? value, List<String> validValues, [String? fieldName]) {
    if (value == null || !validValues.contains(value)) {
      return '${fieldName ?? '此欄位'}的值無效';
    }
    return null;
  }
  
  /// 檢查兩個值是否相等
  static String? equals(String? value, String? compareValue, [String? fieldName]) {
    if (value != compareValue) {
      return '${fieldName ?? '此欄位'}不匹配';
    }
    return null;
  }
  
  /// 自定義正則表達式驗證
  static String? pattern(String? value, String pattern, String errorMessage) {
    if (value == null || !RegExp(pattern).hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }
  
  /// 條件驗證（只有當條件為真時才驗證）
  static String? Function(String?) conditional(
    bool condition,
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (condition) {
        return validator(value);
      }
      return null;
    };
  }
}

/// 表單驗證器類
class FormValidator {
  final Map<String, String? Function(String?)> _validators = {};
  final Map<String, String?> _errors = {};

  /// 添加欄位驗證器
  void addField(String field, String? Function(String?) validator) {
    _validators[field] = validator;
  }

  /// 驗證單個欄位
  String? validateField(String field, String? value) {
    final validator = _validators[field];
    if (validator == null) return null;

    final error = validator(value);
    if (error != null) {
      _errors[field] = error;
    } else {
      _errors.remove(field);
    }
    return error;
  }

  /// 驗證所有欄位
  bool validateAll(Map<String, String?> values) {
    _errors.clear();
    
    for (final entry in _validators.entries) {
      final field = entry.key;
      final validator = entry.value;
      final value = values[field];
      
      final error = validator(value);
      if (error != null) {
        _errors[field] = error;
      }
    }
    
    return _errors.isEmpty;
  }

  /// 獲取欄位錯誤
  String? getError(String field) => _errors[field];

  /// 獲取所有錯誤
  Map<String, String?> get errors => Map.unmodifiable(_errors);

  /// 檢查是否有錯誤
  bool get hasErrors => _errors.isNotEmpty;

  /// 清除所有錯誤
  void clearErrors() => _errors.clear();

  /// 清除特定欄位錯誤
  void clearFieldError(String field) => _errors.remove(field);
}