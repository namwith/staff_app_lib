import 'package:cloud_firestore/cloud_firestore.dart';

class MenuCategory {
  String id;
  String name;
  int order;
  bool isActive;
  DateTime createdAt;

  MenuCategory({
    required this.id,
    required this.name,
    this.order = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory MenuCategory.fromMap(Map<String, dynamic> map, String docId) {
    return MenuCategory(
      id: docId,
      name: map['name'] ?? '',
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'order': order,
    'isActive': isActive,
    'createdAt': createdAt,
  };
}

class MenuItem {
  String id;
  String categoryId;
  String name;
  String description;
  double price;
  String currency;
  bool isAvailable;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description = '',
    required this.price,
    this.currency = 'VND',
    this.isAvailable = true,
    this.imageUrl = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map, String docId) {
    return MenuItem(
      id: docId,
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'VND',
      isAvailable: map['isAvailable'] ?? true,
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'categoryId': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'currency': currency,
    'isAvailable': isAvailable,
    'imageUrl': imageUrl,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };


}
