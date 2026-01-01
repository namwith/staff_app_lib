import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/table.dart';
import '../models/staff.dart';
import '../models/menu_item.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final NotificationService _notifier = NotificationService();

  String restaurantId = 'ickJ0BIvEs7QJaHZTdyE';
  String branchId = 't1GJgJlLQXebFyGIBtF8';
  String zoneId = 'ZKu00SLzf3EGk0qfkaVV';

  List<Session> sessions = [];
  List<TableModel> tables = [];
  List<Staff> staffs = [];
  List<MenuItem> menuItems = [];
  List<MenuCategory> menuCategories = [];

  AppState() {
    _initStreams();
  }

  void _initStreams() {
    // Sessions
    _firestore.streamSessions(restaurantId, branchId).listen((data) {
      sessions = data;
      for (var session in data) {
        if (session.status == SessionStatus.open) {
          _notifier.showSessionNotification(session);
        }
      }
      notifyListeners();
    });

    // Tables
    _firestore.streamTables(restaurantId, branchId, zoneId).listen((data) {
      tables = data;
      notifyListeners();
    });

    // Staffs
    _firestore.streamStaff(restaurantId, branchId).listen((data) {
      staffs = data;
      notifyListeners();
    });

    // Menu
    _firestore.streamMenuItems(restaurantId, branchId).listen((data) {
      menuItems = data;
      notifyListeners();
    });
    _firestore.streamMenuCategories(restaurantId, branchId).listen((data) {
      menuCategories = data;
      notifyListeners();
    });
  }
}
