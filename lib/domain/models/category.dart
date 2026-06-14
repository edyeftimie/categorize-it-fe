class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final bool isSystem;

  const Category({required this.id, required this.name, this.icon, this.color, required this.isSystem});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['id'], name: j['name'], icon: j['icon'], color: j['color'], isSystem: j['isSystem'] ?? false,
  );
}