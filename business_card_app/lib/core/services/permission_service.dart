// lib/core/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../services/dialog_service.dart';

/// 權限服務
/// 
/// 統一管理應用程式所需的各種權限
/// 包括相機、儲存、定位等權限的請求和檢查
class PermissionService {
  // 單例模式
  static final PermissionService _instance = PermissionService._internal();
  static PermissionService get instance => _instance;
  PermissionService._internal();

  /// 請求相機權限
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        '相機權限',
        '請在設定中開啟相機權限以使用此功能',
      );
    }
    
    return false;
  }

  /// 請求照片庫權限
  Future<bool> requestPhotosPermission() async {
    Permission permission;
    
    // 根據平台選擇適當的權限
    if (Theme.of(NavigationService.instance.currentContext!).platform == TargetPlatform.iOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }
    
    final status = await permission.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        '照片權限',
        '請在設定中開啟照片存取權限以使用此功能',
      );
    }
    
    return false;
  }

  /// 請求儲存權限
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        '儲存權限',
        '請在設定中開啟儲存權限以保存檔案',
      );
    }
    
    return false;
  }

  /// 請求通知權限
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        '通知權限',
        '請在設定中開啟通知權限以接收重要訊息',
      );
    }
    
    return false;
  }

  /// 請求定位權限
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        '定位權限',
        '請在設定中開啟定位權限以使用位置功能',
      );
    }
    
    return false;
  }

  /// 請求麥克風權限
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        '麥克風權限',
        '請在設定中開啟麥克風權限以使用錄音功能',
      );
    }
    
    return false;
  }

  /// 檢查相機權限狀態
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// 檢查照片庫權限狀態
  Future<bool> hasPhotosPermission() async {
    Permission permission;
    
    if (Theme.of(NavigationService.instance.currentContext!).platform == TargetPlatform.iOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }
    
    final status = await permission.status;
    return status.isGranted;
  }

  /// 檢查儲存權限狀態
  Future<bool> hasStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  /// 檢查通知權限狀態
  Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// 檢查定位權限狀態
  Future<bool> hasLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  /// 檢查麥克風權限狀態
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// 批次請求多個權限
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// 檢查是否需要顯示權限說明
  Future<bool> shouldShowPermissionRationale(Permission permission) async {
    return await permission.shouldShowRequestRationale;
  }

  /// 開啟應用程式設定頁面
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// 顯示權限被拒絕的對話框
  Future<void> _showPermissionDeniedDialog(
    String permissionName,
    String message,
  ) async {
    final result = await DialogService.instance.showConfirmDialog(
      title: '需要$permissionName',
      content: '$message\n\n是否前往設定開啟？',
      confirmText: '前往設定',
      cancelText: '取消',
    );

    if (result == true) {
      await openAppSettings();
    }
  }

  /// 請求必要權限（用於應用啟動時）
  Future<void> requestEssentialPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.notification,
    ];

    final statuses = await requestMultiplePermissions(permissions);
    
    // 記錄權限狀態
    statuses.forEach((permission, status) {
      debugPrint('Permission ${permission.toString()}: ${status.toString()}');
    });
  }

  /// 檢查所有必要權限是否已授予
  Future<bool> hasAllEssentialPermissions() async {
    final cameraGranted = await hasCameraPermission();
    final storageGranted = await hasStoragePermission();
    final notificationGranted = await hasNotificationPermission();
    
    return cameraGranted && storageGranted && notificationGranted;
  }

  /// 獲取權限狀態摘要
  Future<Map<String, bool>> getPermissionsSummary() async {
    return {
      'camera': await hasCameraPermission(),
      'photos': await hasPhotosPermission(),
      'storage': await hasStoragePermission(),
      'notification': await hasNotificationPermission(),
      'location': await hasLocationPermission(),
      'microphone': await hasMicrophonePermission(),
    };
  }

  /// 權限狀態變更監聽器
  void startPermissionListener() {
    // 可以在這裡實現權限狀態監聽邏輯
    // 例如定期檢查權限狀態變化
  }

  /// 停止權限狀態監聽器
  void stopPermissionListener() {
    // 停止權限狀態監聽
  }
}