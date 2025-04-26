class ItemModel {
  final String itemId;
  final String name;
  final String description;
  final String type; // 'estetico', 'consumible', 'equipable', 'material', 'narrativo'
  final Map<String, dynamic>? effect; // Ejemplo: {'type': 'heal', 'value': 50} o {'stat': 'attack', 'value': 5}
  final String? aestheticUrl; // URL o referencia al asset visual

  ItemModel({
    required this.itemId,
    required this.name,
    required this.description,
    required this.type,
    this.effect,
    this.aestheticUrl,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json, String itemId) {
    return ItemModel(
      itemId: itemId,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      effect: json['effect'] as Map<String, dynamic>?,
      aestheticUrl: json['aestheticUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'effect': effect,
      'aestheticUrl': aestheticUrl,
    };
  }
}
