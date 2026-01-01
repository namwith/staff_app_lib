import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../widgets/session_card.dart';

class SessionScreen extends StatelessWidget {
  final VoidCallback onBack;
  final String restaurantId;
  final String branchId;

  const SessionScreen({
    super.key,
    required this.onBack,
    required this.restaurantId,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Tạo map tableId -> TableModel
    final tableMap = {for (var t in appState.tables) t.id: t};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
      ),
      body: ListView.builder(
        itemCount: appState.sessions.length,
        itemBuilder: (context, index) {
          final session = appState.sessions[index];
          return SessionCard(
            session: session,
            restaurantId: restaurantId,
            branchId: branchId,
            tableMap: tableMap, // truyền vào SessionCard
          );
        },
      ),
    );
  }
}
