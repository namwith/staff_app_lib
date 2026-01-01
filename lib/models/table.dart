class TableModel {
  String id;
  String name;
  double x;
  double y;
  double width;
  double height;
  String shape;
  bool isActive;

  TableModel({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.shape = 'rectangle',
    this.isActive = true,
  });

  factory TableModel.fromMap(Map<String, dynamic> map, String docId) {
    return TableModel(
      id: docId,
      name: map['name'] ?? '',
      x: (map['x'] ?? 0).toDouble(),
      y: (map['y'] ?? 0).toDouble(),
      width: (map['width'] ?? 60).toDouble(),
      height: (map['height'] ?? 60).toDouble(),
      shape: map['shape'] ?? 'rectangle',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'shape': shape,
    'isActive': isActive,
  };
}
