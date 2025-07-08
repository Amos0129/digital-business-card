import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/card_group_viewmodel.dart';
import '../widgets/group_app_bar.dart';
import '../widgets/group_toolbar.dart';
import '../widgets/group_card_list.dart';
import '../widgets/group_bottom_nav.dart';

class CardGroupPage extends StatelessWidget {
  const CardGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CardGroupViewModel()
        ..loadGroups()
        ..loadCards(),
      child: const _CardGroupPageContent(),
    );
  }
}

class _CardGroupPageContent extends StatelessWidget {
  const _CardGroupPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CardGroupAppBar(),
      body: Column(
        children: const [
          CardGroupToolbar(),
          SizedBox(height: 4),
          Expanded(child: CardGroupList()),
        ],
      ),
      bottomNavigationBar: const CardGroupBottomNav(),
    );
  }
}
