class Category {
  final int? id;
  final String? name;
  final String? icon;
  final String? color;

  Category({
    this.id,
    this.name,
    this.icon,
    this.color,
  });

  // Convert a Category-Object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color':color,
    };
  }

  // Convert a Map into a Category-Object
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
    );
  }
}
