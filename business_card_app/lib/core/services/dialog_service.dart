// lib/core/services/dialog_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

/// 對話框服務
/// 
/// 提供統一的對話框顯示功能
/// 包括確認對話框、選擇對話框、自定義對話框等
class DialogService {
  // 單例模式
  static final DialogService _instance = DialogService._internal();
  static DialogService get instance => _instance;
  DialogService._internal();

  /// 顯示確認對話框
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '確定',
    String cancelText = '取消',
    bool barrierDismissible = true,
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    final context = NavigationService.instance.currentContext;
    if (context == null) return null;

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headlineSmall,
        ),
        content: Text(
          content,
          style: AppTypography.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: cancelColor ?? AppColors.neutral,
            ),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 顯示資訊對話框
  Future<void> showInfoDialog({
    required String title,
    required String content,
    String buttonText = '確定',
    Color? buttonColor,
    VoidCallback? onConfirm,
  }) async {
    final context = NavigationService.instance.currentContext;
    if (context == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headlineSmall,
        ),
        content: Text(
          content,
          style: AppTypography.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: buttonColor ?? AppColors.primary,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// 顯示錯誤對話框
  Future<void> showErrorDialog({
    String title = '錯誤',
    required String message,
    String buttonText = '確定',
    VoidCallback? onConfirm,
  }) async {
    await showInfoDialog(
      title: title,
      content: message,
      buttonText: buttonText,
      buttonColor: AppColors.error,
      onConfirm: onConfirm,
    );
  }

  /// 顯示成功對話框
  Future<void> showSuccessDialog({
    String title = '成功',
    required String message,
    String buttonText = '確定',
    VoidCallback? onConfirm,
  }) async {
    await showInfoDialog(
      title: title,
      content: message,
      buttonText: buttonText,
      buttonColor: AppColors.success,
      onConfirm: onConfirm,
    );
  }

  /// 顯示選擇對話框
  Future<int?> showChoiceDialog({
    required String title,
    String? content,
    required List<String> choices,
    int? selectedIndex,
  }) async {
    final context = NavigationService.instance.currentContext;
    if (context == null) return null;

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headlineSmall,
        ),
        content: content != null 
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  ...choices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final choice = entry.value;
                    return RadioListTile<int>(
                      title: Text(choice),
                      value: index,
                      groupValue: selectedIndex,
                      onChanged: (value) {
                        Navigator.of(context).pop(value);
                      },
                    );
                  }),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: choices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final choice = entry.value;
                  return ListTile(
                    title: Text(choice),
                    onTap: () => Navigator.of(context).pop(index),
                  );
                }).toList(),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 顯示載入對話框
  void showLoadingDialog({
    String message = '載入中...',
  }) {
    final context = NavigationService.instance.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Padding(
            padding: AppDimensions.paddingLg,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: AppDimensions.spacingLg),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusLg,
          ),
        ),
      ),
    );
  }

  /// 隱藏載入對話框
  void hideLoadingDialog() {
    final context = NavigationService.instance.currentContext;
    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// 顯示底部表單對話框
  Future<T?> showBottomSheetDialog<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    Color? backgroundColor,
  }) async {
    final context = NavigationService.instance.currentContext;
    if (context == null) return null;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (context) => child,
    );
  }

  /// 顯示自定義對話框
  Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) async {
    final context = NavigationService.instance.currentContext;
    if (context == null) return null;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => child,
    );
  }

  /// 顯示圖片選擇對話框
  Future<ImageSource?> showImageSourceDialog() async {
    final context = NavigationService.instance.currentContext;
    if (context == null) return null;

    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (context) => Container(
        padding: AppDimensions.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題
            Text(
              '選擇圖片來源',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            
            // 相機選項
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('相機'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            
            // 相簿選項
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('相簿'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            
            const SizedBox(height: AppDimensions.spacingSm),
          ],
        ),
      ),
    );
  }
}

/// 圖片來源枚舉
enum ImageSource {
  camera,
  gallery,
}