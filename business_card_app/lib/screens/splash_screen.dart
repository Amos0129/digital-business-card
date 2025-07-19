// lib/screens/splash_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // 淡出動畫
    await _controller.reverse();

    if (!mounted) return;

    final destination = authProvider.isLoggedIn ? MainScreen() : LoginScreen();
    
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (_) => destination,
        settings: const RouteSettings(name: '/main'),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.primaryColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withBlue(200),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo區域
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildLogo(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 標題
                      _buildTitle(),
                      
                      const SizedBox(height: 16),
                      
                      // 副標題
                      _buildSubtitle(),
                      
                      const SizedBox(height: 80),
                      
                      // 載入指示器
                      _buildLoadingIndicator(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圓圈
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(45),
            ),
          ),
          
          // 主圖示
          const Icon(
            CupertinoIcons.person_2_fill,
            size: 50,
            color: CupertinoColors.white,
          ),
          
          // 裝飾點
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '數位名片',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.white,
        fontFamily: '.SF Pro Display',
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      '讓名片交換更簡單、更環保',
      style: TextStyle(
        fontSize: 16,
        color: CupertinoColors.white.withOpacity(0.9),
        fontFamily: '.SF Pro Text',
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        const CupertinoActivityIndicator(
          color: CupertinoColors.white,
          radius: 12,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          '正在載入...',
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.white.withOpacity(0.8),
            fontFamily: '.SF Pro Text',
          ),
        ),
      ],
    );
  }
}