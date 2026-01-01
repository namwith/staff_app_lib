import 'package:flutter/material.dart';
import '../../models/staff.dart';

class StaffCard extends StatelessWidget {
  final Staff staff;
  const StaffCard({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(staff.name),
        subtitle: Text('Role: ${staff.role.name}, Active: ${staff.isActive}'),
      ),
    );
  }
}
