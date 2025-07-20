// lib/core/services/navigation_service.dart
import 'package:flutter/material.dart';
import '../constants/route_paths.dart';

/// 全域導航服務
/// 
/// 提供在任何地方進行頁面導航的能力
/// 支援各種導航操作和狀態管理
class NavigationService {
  // 單例模式
  static final NavigationService _instance = NavigationService._internal();
  static NavigationService get instance => _instance;
  NavigationService._internal();

  /// 全域導航鍵
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// 當前上下文
  BuildContext? get currentContext => navigatorKey.currentContext;
  
  /// 當前路由
  String? get currentRoute {
    final route = ModalRoute.of(currentContext!);
    return route?.settings.name;
  }

  /// 導航歷史棧
  final List<String> _navigationHistory = [];
  
  /// 獲取導航歷史
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);

  /// 初始化
  void initialize() {
    // 清空導航歷史
    _navigationHistory.clear();
    _navigationHistory.add(RoutePaths.splash);
  }

  // ========== 基本導航方法 ==========
  
  /// 導航到指定路由
  Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
    bool recordHistory = true,
  }) {
    if (recordHistory) {
      _addToHistory(routeName);
    }
    
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// 替換當前路由
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
    TO? result,
    bool recordHistory = true,
  }) {
    if (recordHistory) {
      _replaceInHistory(routeName);
    }
    
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// 清空路由棧並導航到新路由
  Future<T?> pushNamedAndClearStack<T>(
    String routeName, {
    Object? arguments,
    bool recordHistory = true,
  }) {
    if (recordHistory) {
      _clearHistoryAndAdd(routeName);
    }
    
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// 導航到指定路由並移除直到指定條件
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
    bool recordHistory = true,
  }) {
    if (recordHistory) {
      _addToHistory(routeName);
    }
    
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// 返回上一頁
  void pop<T>([T? result]) {
    if (canPop()) {
      _removeFromHistory();
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// 返回到指定路由
  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(
      (route) => route.settings.name == routeName,
    );
    _removeFromHistoryUntil(routeName);
  }

  /// 返回到根路由
  void popToRoot() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    _clearHistoryToRoot();
  }

  /// 檢查是否可以返回
  bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// 嘗試返回，如果不能返回則執行回調
  bool maybePop<T>([T? result]) {
    if (canPop()) {
      pop<T>(result);
      return true;
    }
    return false;
  }

  // ========== 特殊導航方法 ==========
  
  /// 導航到登入頁面
  Future<void> pushToLogin({bool clearStack = false}) {
    if (clearStack) {
      return pushNamedAndClearStack(RoutePaths.login);
    } else {
      return pushNamed(RoutePaths.login);
    }
  }

  /// 導航到主頁面
  Future<void> pushToMain({bool clearStack = true}) {
    if (clearStack) {
      return pushNamedAndClearStack(RoutePaths.mainNavigation);
    } else {
      return pushNamed(RoutePaths.mainNavigation);
    }
  }

  /// 導航到名片詳情
  Future<void> pushToCardDetail(int cardId, {Object? arguments}) {
    return pushNamed(
      RoutePaths.cardDetailWithId(cardId),
      arguments: arguments,
    );
  }

  /// 導航到編輯名片
  Future<void> pushToEditCard(int cardId, {Object? arguments}) {
    return pushNamed(
      RoutePaths.editCardWithId(cardId),
      arguments: arguments,
    );
  }

  /// 導航到群組詳情
  Future<void> pushToGroupDetail(int groupId, {Object? arguments}) {
    return pushNamed(
      RoutePaths.groupDetailWithId(groupId),
      arguments: arguments,
    );
  }

  /// 導航到搜尋結果
  Future<void> pushToSearchResults(String query, {Object? arguments}) {
    return pushNamed(
      RoutePaths.searchResultsWithQuery(query),
      arguments: arguments,
    );
  }

  // ========== 對話框和底部表單 ==========
  
  /// 顯示對話框
  Future<T?> showDialogWidget<T>(Widget dialog) {
    return showDialog<T>(
      context: currentContext!,
      builder: (context) => dialog,
    );
  }

  /// 顯示確認對話框
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '確定',
    String cancelText = '取消',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: currentContext!,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 顯示底部表單
  Future<T?> showBottomSheetWidget<T>(Widget bottomSheet) {
    return showModalBottomSheet<T>(
      context: currentContext!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => bottomSheet,
    );
  }

  /// 顯示 Snackbar
  void showSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(currentContext!);
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  // ========== 歷史記錄管理 ==========
  
  /// 添加到歷史記錄
  void _addToHistory(String routeName) {
    _navigationHistory.add(routeName);
    
    // 限制歷史記錄數量，避免記憶體洩漏
    if (_navigationHistory.length > 50) {
      _navigationHistory.removeAt(0);
    }
  }

  /// 替換歷史記錄中的最後一項
  void _replaceInHistory(String routeName) {
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.last = routeName;
    } else {
      _navigationHistory.add(routeName);
    }
  }

  /// 清空歷史記錄並添加新項
  void _clearHistoryAndAdd(String routeName) {
    _navigationHistory.clear();
    _navigationHistory.add(routeName);
  }

  /// 從歷史記錄中移除最後一項
  void _removeFromHistory() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
    }
  }

  /// 從歷史記錄中移除直到指定路由
  void _removeFromHistoryUntil(String routeName) {
    while (_navigationHistory.isNotEmpty && 
           _navigationHistory.last != routeName) {
      _navigationHistory.removeLast();
    }
  }

  /// 清空歷史記錄到根路由
  void _clearHistoryToRoot() {
    if (_navigationHistory.isNotEmpty) {
      final firstRoute = _navigationHistory.first;
      _navigationHistory.clear();
      _navigationHistory.add(firstRoute);
    }
  }

  // ========== 路由資訊 ==========
  
  /// 獲取當前路由資訊
  RouteSettings? get currentRouteSettings {
    final route = ModalRoute.of(currentContext!);
    return route?.settings;
  }

  /// 獲取當前路由參數
  Object? get currentRouteArguments {
    return currentRouteSettings?.arguments;
  }

  /// 檢查當前是否在指定路由
  bool isCurrentRoute(String routeName) {
    return currentRoute == routeName;
  }

  /// 檢查是否在認證相關頁面
  bool get isInAuthFlow {
    if (currentRoute == null) return false;
    return RoutePaths.guestOnlyRoutes.any(
      (route) => currentRoute!.startsWith(route),
    );
  }

  /// 檢查是否在需要認證的頁面
  bool get isInProtectedRoute {
    if (currentRoute == null) return false;
    return RoutePaths.requiresAuth(currentRoute!);
  }

  // ========== 工具方法 ==========
  
  /// 重新載入當前頁面
  void reloadCurrentPage() {
    final currentRouteName = currentRoute;
    final currentArguments = currentRouteArguments;
    
    if (currentRouteName != null) {
      pushReplacementNamed(
        currentRouteName,
        arguments: currentArguments,
      );
    }
  }

  /// 獲取路由深度
  int get routeDepth => _navigationHistory.length;

  /// 獲取前一個路由
  String? get previousRoute {
    return _navigationHistory.length > 1 
        ? _navigationHistory[_navigationHistory.length - 2] 
        : null;
  }

  /// 清理資源
  void dispose() {
    _navigationHistory.clear();
  }

  /// 獲取導航統計
  Map<String, dynamic> getNavigationStats() {
    final routeCount = <String, int>{};
    for (final route in _navigationHistory) {
      routeCount[route] = (routeCount[route] ?? 0) + 1;
    }
    
    return {
      'total_navigations': _navigationHistory.length,
      'unique_routes': routeCount.length,
      'current_route': currentRoute,
      'previous_route': previousRoute,
      'route_depth': routeDepth,
      'route_frequency': routeCount,
    };
  }
}