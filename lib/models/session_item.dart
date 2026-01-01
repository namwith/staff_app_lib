enum ItemStatus { pending, preparing, ready, served }

class SessionItem {
  String id;
  String menuItemId;
  String nameSnapshot;
  double priceSnapshot;
  int quantity;
  String note;
  ItemStatus status;

  SessionItem({
    required this.id,
    required this.menuItemId,
    required this.nameSnapshot,
    required this.priceSnapshot,
    required this.quantity,
    this.note = '',
    this.status = ItemStatus.pending,
  });

  factory SessionItem.fromMap(Map<String, dynamic> map, String docId) {
    return SessionItem(
      id: docId,
      menuItemId: map['menuItemId'],
      nameSnapshot: map['nameSnapshot'],
      priceSnapshot: (map['priceSnapshot'] ?? 0).toDouble(),
      quantity: map['quantity'],
      note: map['note'] ?? '',
      status: ItemStatus.values.firstWhere(
              (e) => e.name == (map['status'] ?? 'pending')),
    );
  }

  Map<String, dynamic> toMap() => {
    'menuItemId': menuItemId,
    'nameSnapshot': nameSnapshot,
    'priceSnapshot': priceSnapshot,
    'quantity': quantity,
    'note': note,
    'status': status.name,
  };
}
