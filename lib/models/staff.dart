import 'package:cloud_firestore/cloud_firestore.dart';

enum StaffRole { admin, waiter, kitchen, cashier, manager }

class Staff {
  String id;
  String uid;
  String name;
  StaffRole role;
  bool isActive;
  Map<String, List<String>> scopes;
  DateTime joinedAt;
  DateTime lastActiveAt;

  Staff({
    required this.id,
    required this.uid,
    required this.name,
    this.role = StaffRole.waiter,
    this.isActive = true,
    this.scopes = const {},
    required this.joinedAt,
    required this.lastActiveAt,
  });

  factory Staff.fromMap(Map<String, dynamic> map, String docId) {
    final rawScopes = map['scopes'] as Map<String, dynamic>? ?? {};
    final Map<String, List<String>> scopes = {};
    rawScopes.forEach((key, value) {
      scopes[key] = (value as List<dynamic>).map((e) => e.toString()).toList();
    });

    return Staff(
      id: docId,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      role: StaffRole.values.firstWhere(
            (e) => e.name == map['role'],
        orElse: () => StaffRole.waiter,
      ),
      isActive: map['isActive'] ?? true,
      scopes: scopes,
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp).toDate(),
    );
  }


  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'role': role.name,
    'isActive': isActive,
    'scopes': scopes,
    'joinedAt': joinedAt,
    'lastActiveAt': lastActiveAt,
  };
}
