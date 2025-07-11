import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../widgets/profile_card.dart';
import '../widgets/social_buttons.dart';
import '../widgets/qr_section.dart';
import '../widgets/bottom_nav.dart';
import '../screens/edit_profile_page.dart';
import '../models/user.dart';
import '../models/card_response.dart';
import '../services/card_service.dart';
import '../providers/user_provider.dart';
import '../services/scan_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CardService cardService;
  late UserModel user;
  CardResponse? _card;

  int currentIndex = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    cardService = CardService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = Provider.of<UserProvider>(context, listen: false).user;
      if (u == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      user = u;
      _loadCard();
    });
  }

  Future<void> _loadCard() async {
    setState(() => _loading = true);

    try {
      final cards = await cardService.getMyCards();
      setState(() {
        _card = cards.isNotEmpty ? cards.first : null;
        _loading = false;
      });
    } catch (e) {
      debugPrint('讀取名片失敗: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = _card != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('個人名片'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A6CFF),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  ProfileCard(
                    name: _card?.name ?? '尚未建立名片',
                    photoUrl: _card?.fullAvatarUrl,
                    onEdit: () async {
                      if (user == null) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(userId: user.id),
                        ),
                      );
                      _loadCard();
                    },
                  ),
                  SocialButtons(
                    hasFb: _card?.facebook ?? false,
                    hasIg: _card?.instagram ?? false,
                    hasLine: _card?.line ?? false,
                    hasThreads: _card?.threads ?? false,
                  ),
                  const SizedBox(height: 12),
                  QRSection(
                    hasProfile: hasProfile,
                    card: _card,
                    onCreateCard: () async {
                      if (user == null) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(userId: user.id),
                        ),
                      );
                      _loadCard(); // 回來後自動刷新
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;

          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/groups');
              break;
            case 2:
              ScanService.scanAndNavigate(context);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
