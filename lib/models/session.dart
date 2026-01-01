import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_item.dart';

enum SessionType { dine_in, takeaway, delivery }
enum SessionStatus { open, paying, closed }

class Session {
  String id;
  String tableId;
  SessionType type;
  SessionStatus status;
  DateTime createdAt;
  DateTime? closedAt;
  String createdBy;
  String? customerId;
  double totalAmount;
  List<SessionItem> items;

  Session({
    required this.id,
    required this.tableId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.closedAt,
    required this.createdBy,
    this.customerId,
    this.totalAmount = 0,
    this.items = const [],
  });

  factory Session.fromMap(Map<String, dynamic> map, String docId) {
    return Session(
      id: docId,
      tableId: map['tableId'] ?? '',
      type: SessionType.values.firstWhere((e) => e.name == map['type']),
      status: SessionStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      closedAt: map['closedAt'] != null
          ? (map['closedAt'] as Timestamp).toDate()
          : null,
      createdBy: map['createdBy'] ?? 'guest',
      customerId: map['customerId'],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      items: map['items'] != null
          ? (map['items'] as List<dynamic>)
          .map((e) => SessionItem.fromMap(e, e['id'] ?? ''))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() => {
    'tableId': tableId,
    'type': type.name,
    'status': status.name,
    'createdAt': createdAt,
    'closedAt': closedAt,
    'createdBy': createdBy,
    'customerId': customerId,
    'totalAmount': totalAmount,
    'items': items.map((e) => e.toMap()).toList(),
  };
}
