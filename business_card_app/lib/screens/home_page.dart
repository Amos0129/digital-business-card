import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../widgets/profile_card.dart';
import '../widgets/social_buttons.dart';
import '../widgets/qr_section.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/scanned_card.dart';
import '../utils/scan_dialog.dart';
import '../screens/edit_profile_page.dart';
import '../models/user.dart';
import '../models/card_response.dart';
import '../services/card_service.dart';
import '../providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CardService cardService;
  late UserModel user;
  CardResponse? _card;
  CardResponse? _scannedCard; // ✅ 掃描結果

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
                  QRSection(hasProfile: hasProfile, card: _card),
                  if (_scannedCard != null)
                    ScannedCard(
                      cardId: _scannedCard!.id,
                      name: _scannedCard!.name,
                      phone: _scannedCard!.phone,
                      email: _scannedCard!.email,
                      company: _scannedCard!.company,
                      address: _scannedCard!.address,
                      avatarUrl: null,
                      hasFb: _scannedCard!.facebook,
                      hasIg: _scannedCard!.instagram,
                      hasLine: _scannedCard!.line,
                      hasThreads: _scannedCard!.threads,
                      fbUrl: "https://facebook.com/${_scannedCard!.name}",
                      igUrl: "https://instagram.com/${_scannedCard!.name}",
                      lineUrl: "https://line.me/ti/p/${_scannedCard!.name}",
                      threadsUrl: "https://threads.net/${_scannedCard!.name}",
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
              showScannerDialog(context, (String result) async {
                final int? cardId = int.tryParse(result);
                if (cardId == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('QR Code 資料無效')));
                  return;
                }

                try {
                  final card = await cardService.getCardById(cardId);
                  if (!context.mounted) return;

                  setState(() {
                    _scannedCard = card;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('找不到名片資料: $e')));
                }
              });
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
