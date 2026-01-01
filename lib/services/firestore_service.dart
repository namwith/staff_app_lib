import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';
import '../models/session_item.dart';
import '../models/table.dart';
import '../models/staff.dart';
import '../models/menu_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Firestore path helpers
  CollectionReference<Map<String, dynamic>> branches(String restaurantId) =>
      _db.collection('restaurants').doc(restaurantId).collection('branches');

  CollectionReference<Map<String, dynamic>> zones(
      String restaurantId, String branchId) =>
      branches(restaurantId).doc(branchId).collection('zones');

  CollectionReference<Map<String, dynamic>> tables(
      String restaurantId, String branchId, String zoneId) =>
      zones(restaurantId, branchId).doc(zoneId).collection('tables');

  CollectionReference<Map<String, dynamic>> sessions(
      String restaurantId, String branchId) =>
      branches(restaurantId).doc(branchId).collection('sessions');

  CollectionReference<Map<String, dynamic>> staff(
      String restaurantId, String branchId) =>
      branches(restaurantId).doc(branchId).collection('staff');

  CollectionReference<Map<String, dynamic>> menuItems(
      String restaurantId, String branchId) =>
      branches(restaurantId).doc(branchId).collection('menu_items');

  CollectionReference<Map<String, dynamic>> menuCategories(
      String restaurantId, String branchId) =>
      branches(restaurantId).doc(branchId).collection('menu_categories');

  // ---------------- Sessions ----------------
  Stream<List<Session>> streamSessions(
      String restaurantId, String branchId) {
    return sessions(restaurantId, branchId).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Session.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> createSession(
      String restaurantId, String branchId, Session session) async {
    await sessions(restaurantId, branchId).add(session.toMap());
  }

  Future<void> updateSession(
      String restaurantId, String branchId, Session session) async {
    await sessions(restaurantId, branchId)
        .doc(session.id)
        .update(session.toMap());
  }

  Future<void> updateSessionStatus(
      String restaurantId,
      String branchId,
      String sessionId,
      SessionStatus status,
      ) async {
    await sessions(restaurantId, branchId)
        .doc(sessionId)
        .update({'status': status.name});
  }

  Future<void> updateSessionItemStatus(
      String restaurantId,
      String branchId,
      String sessionId,
      String itemId,
      ItemStatus status,
      ) async {
    final itemRef = sessions(restaurantId, branchId)
        .doc(sessionId)
        .collection('items')
        .doc(itemId);

    await itemRef.update({'status': status.name});
  }

  // ---------------- Tables ----------------
  Stream<List<TableModel>> streamTables(
      String restaurantId, String branchId, String zoneId) {
    return tables(restaurantId, branchId, zoneId).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => TableModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  /// CREATE table (dùng khi tạo bàn mới từ UI)
  Future<void> createTable(
      String restaurantId,
      String branchId,
      String zoneId,
      TableModel table,
      ) async {
    await tables(restaurantId, branchId, zoneId)
        .add(table.toMap());
  }

  /// UPDATE table (drag / resize / activate / deactivate)
  Future<void> updateTable(
      String restaurantId,
      String branchId,
      String zoneId,
      TableModel table,
      ) async {
    await tables(restaurantId, branchId, zoneId)
        .doc(table.id)
        .update(table.toMap());
  }

  Future<void> openSessionForTable({
    required String restaurantId,
    required String branchId,
    required String tableId,
    required String staffId,
  }) async {
    final now = DateTime.now();

    final sessionData = {
      'tableId': tableId,
      'type': SessionType.dine_in.name,
      'status': SessionStatus.open.name,
      'createdAt': Timestamp.fromDate(now),
      'createdBy': staffId,
      'totalAmount': 0,
    };

    await sessions(restaurantId, branchId).add(sessionData);
  }

  // ---------------- Staff ----------------
  Stream<List<Staff>> streamStaff(
      String restaurantId, String branchId) {
    return staff(restaurantId, branchId).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Staff.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> updateStaff(
      String restaurantId,
      String branchId,
      Staff staffMember,
      ) async {
    await staff(restaurantId, branchId)
        .doc(staffMember.id)
        .update(staffMember.toMap());
  }

  // ---------------- Menu ----------------
  Stream<List<MenuItem>> streamMenuItems(
      String restaurantId, String branchId) {
    return menuItems(restaurantId, branchId).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> updateMenuItem(
      String restaurantId, String branchId, MenuItem item) async {
    await menuItems(restaurantId, branchId)
        .doc(item.id)
        .update(item.toMap());
  }

  Future<void> createMenuItem(
      String restaurantId, String branchId, MenuItem item) async {
    await menuItems(restaurantId, branchId).add(item.toMap());
  }

  Future<void> updateMenuItemAvailability(
      String restaurantId,
      String branchId,
      String itemId,
      bool isAvailable,
      ) async {
    await menuItems(restaurantId, branchId)
        .doc(itemId)
        .update({
      'isAvailable': isAvailable,
      'updatedAt': DateTime.now(),
    });
  }

  Stream<List<MenuCategory>> streamMenuCategories(
      String restaurantId, String branchId) {
    return menuCategories(restaurantId, branchId).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => MenuCategory.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> createMenuCategory(
      String restaurantId,
      String branchId,
      String name,
      ) async {
    await menuCategories(restaurantId, branchId).add({
      'name': name,
      'order': DateTime.now().millisecondsSinceEpoch,
      'isActive': true,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> renameMenuCategory(
      String restaurantId,
      String branchId,
      String categoryId,
      String newName,
      ) async {
    await menuCategories(restaurantId, branchId)
        .doc(categoryId)
        .update({
      'name': newName,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> disableMenuCategory(
      String restaurantId,
      String branchId,
      String categoryId,
      ) async {
    await menuCategories(restaurantId, branchId)
        .doc(categoryId)
        .update({
      'isActive': false,
      'updatedAt': DateTime.now(),
    });
  }
}
