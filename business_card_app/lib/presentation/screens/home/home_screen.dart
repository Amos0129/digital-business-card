// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/card_provider.dart';
import '../../widgets/cards/card_list_item.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/animations/fade_transition.dart';

/// 首頁畫面
/// 
/// 顯示使用者概覽和快速操作
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cardProvider = context.read<CardProvider>();
    await cardProvider.loadMyCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/card_provider.dart';
import '../../widgets/cards/card_list_item.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/animations/fade_transition.dart';

/// 首頁畫面
/// 
/// 顯示使用者概覽和快速操作
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cardProvider = context.read<CardProvider>();
    await cardProvider.loadMyCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 問候語
                AppFadeTransition(
                  delay: const Duration(milliseconds: 100),
                  child: _buildGreeting(),
                ),
                
                const SizedBox(height: 24),
                
                // 快速操作
                AppFadeTransition(
                  delay: const Duration(milliseconds: 200),
                  child: _buildQuickActions(),
                ),
                
                const SizedBox(height: 24),
                
                // 統計卡片
                AppFadeTransition(
                  delay: const Duration(milliseconds: 300),
                  child: _buildStatsCards(),
                ),
                
                const SizedBox(height: 24),
                
                // 最近的名片
                AppFadeTransition(
                  delay: const Duration(milliseconds: 400),
                  child: _buildRecentCards(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final name = user?.displayName ?? '使用者';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速操作',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  label: '建立名片',
                  onTap: () => context.push('/home/card/create'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.qr_code_scanner,
                  label: '掃描 QR',
                  onTap: () => context.push('/home/scanner'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.public,
                  label: '瀏覽公開',
                  onTap: () => context.push('/home/public-cards'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2196F3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        final totalCards = cardProvider.myCards.length;
        final publicCards = cardProvider.myCards.where((card) => card.isPublic).length;
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '總名片數',
                value: totalCards.toString(),
                icon: Icons.credit_card,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '公開名片',
                value: publicCards.toString(),
                icon: Icons.public,
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCards() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        if (cardProvider.isLoading) {
          return const AppLoading();
        }
        
        final recentCards = cardProvider.myCards.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '最近的名片',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 切換到名片頁面
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentCards.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.credit_card_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '還沒有名片',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '建立您的第一張數位名片',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recentCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CardListItem(
                  card: card,
                  onTap: () => context.push('/home/card/${card.id}/detail'),
                ),
              )),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '早安！';
    } else if (hour < 18) {
      return '午安！';
    } else {
      return '晚安！';
    }
  }
}