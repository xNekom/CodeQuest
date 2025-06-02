// Representa un ítem dentro del juego, como pociones, equipamiento o materiales.
class ItemModel {
  final String itemId; // ID único del ítem.
  final String name; // Nombre del ítem.
  final String description; // Descripción del ítem.
  final String icon; // Ruta al archivo de icono del ítem.
  final String type; // Tipo de ítem (ej. 'potion', 'weapon', 'armor', 'material'). Define su uso o categoría.
  final String rarity; // Rareza del ítem (ej. 'común', 'raro', 'épico'). Puede influir en su valor o poder.
  final Map<String, dynamic> attributes; // Atributos adicionales específicos del ítem (ej. precio, estadísticas de ataque/defensa, efectos).

  // Constructor para crear una instancia de ItemModel.
  ItemModel({
    required this.itemId,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.attributes,
  });
  factory ItemModel.fromJson(Map<String, dynamic> json, String itemId) {
    // Extraer los campos conocidos y poner el resto en 'attributes'
    Map<String, dynamic> remainingAttributes = Map.from(json);
    
    final name = remainingAttributes.remove('name') as String;
    final description = remainingAttributes.remove('description') as String;
    final icon = remainingAttributes.remove('icon') as String;
    final type = remainingAttributes.remove('type') as String;
    final rarity = remainingAttributes.remove('rareza') as String;
    
    // Remove unused fields but keep them in attributes if needed for future use
    remainingAttributes.remove('es_consumible');
    remainingAttributes.remove('es_apilable');
    remainingAttributes.remove('cantidad_max_pila');
    remainingAttributes.remove('se_puede_usar');
    remainingAttributes.remove('es_para_mision');
    remainingAttributes.remove('requiere_nivel');
    
    // 'id' se usa para itemId y no se incluye en attributes ni en toJson
    remainingAttributes.remove('id'); 

    return ItemModel(
      itemId: itemId, // El ID del documento de Firestore
      name: name,
      description: description,
      icon: icon,
      type: type,
      rarity: rarity,
      attributes: remainingAttributes, // Todos los demás campos van aquí
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'type': type,
      'rarity': rarity,
      ...attributes, // Expande todos los atributos adicionales
    };
  }
}
