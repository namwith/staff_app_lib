import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../widgets/staff_card.dart';

class StaffScreen extends StatelessWidget {
  final VoidCallback onBack;
  const StaffScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
      ),
      body: ListView.builder(
        itemCount: appState.staffs.length,
        itemBuilder: (context, index) {
          final staff = appState.staffs[index];
          return StaffCard(staff: staff);
        },
      ),
    );
  }
}
