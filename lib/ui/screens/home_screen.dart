
import 'package:flutter/material.dart';
import 'session_screen.dart';
import 'table_screen.dart';
import 'staff_screen.dart';
import 'menu_adjust_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _currentIndex;

  final List<Widget Function(VoidCallback)> _screens = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = null;
    // khởi tạo _screens với callback reset
    _screens.addAll([
          (VoidCallback back) => SessionScreen(onBack: back, restaurantId: 'ickJ0BIvEs7QJaHZTdyE', branchId: 't1GJgJlLQXebFyGIBtF8',),
          (VoidCallback back) => TableScreen(onBack: back),
          (VoidCallback back) => StaffScreen(onBack: back),
          (VoidCallback back) => AdminScreen(onBack: back),
    ]);
  }

  void _goHome() => setState(() => _currentIndex = null);

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Choose Tab')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final labels = ['Sessions / Orders', 'Tables Map', 'Staff List', 'Menu List'];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => setState(() => _currentIndex = i),
                  child: Text(labels[i]),
                ),
              );
            }),
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex!](_goHome),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex!,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Sessions'),
          BottomNavigationBarItem(icon: Icon(Icons.table_bar), label: 'Tables'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}