class ItemModel {
  final String itemId;
  final String name;
  final String description;
  final String icon; // Anteriormente aestheticUrl, coincide con 'icon' en JSON
  final String type; // Coincide con 'type' en JSON (ej: 'potion', 'weapon', 'armor')
  final String rarity; // Coincide con 'rareza' en JSON
  final bool? isConsumable; // Coincide con 'es_consumible'
  final bool? isStackable; // Coincide con 'es_apilable'
  final int? maxStack; // Coincide con 'cantidad_max_pila'
  final bool? canBeUsed; // Coincide con 'se_puede_usar'
  final bool? isQuestItem; // Coincide con 'es_para_mision'
  final int? requiredLevel; // Coincide con 'requiere_nivel'
  final Map<String, dynamic> attributes; // Para todos los demás campos específicos

  ItemModel({
    required this.itemId,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    this.isConsumable,
    this.isStackable,
    this.maxStack,
    this.canBeUsed,
    this.isQuestItem,
    this.requiredLevel,
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
    final isConsumable = remainingAttributes.remove('es_consumible') as bool?;
    final isStackable = remainingAttributes.remove('es_apilable') as bool?;
    final maxStack = remainingAttributes.remove('cantidad_max_pila') as int?;
    final canBeUsed = remainingAttributes.remove('se_puede_usar') as bool?;
    final isQuestItem = remainingAttributes.remove('es_para_mision') as bool?;
    final requiredLevel = remainingAttributes.remove('requiere_nivel') as int?;
    
    // 'id' se usa para itemId y no se incluye en attributes ni en toJson
    remainingAttributes.remove('id'); 

    return ItemModel(
      itemId: itemId, // El ID del documento de Firestore
      name: name,
      description: description,
      icon: icon,
      type: type,
      rarity: rarity,
      isConsumable: isConsumable,
      isStackable: isStackable,
      maxStack: maxStack,
      canBeUsed: canBeUsed,
      isQuestItem: isQuestItem,
      requiredLevel: requiredLevel,
      attributes: remainingAttributes, // Todos los demás campos van aquí
    );
  }

  Map<String, dynamic> toJson() {
    // El 'itemId' no se almacena en el JSON de Firestore como un campo, sino como el ID del documento.
    // 'originalId' se podría añadir si se quiere preservar el 'id' del JSON original.
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'type': type,
      'rarity': rarity,
      if (isConsumable != null) 'es_consumible': isConsumable,
      if (isStackable != null) 'es_apilable': isStackable,
      if (maxStack != null) 'cantidad_max_pila': maxStack,
      if (canBeUsed != null) 'se_puede_usar': canBeUsed,
      if (isQuestItem != null) 'es_para_mision': isQuestItem,
      if (requiredLevel != null) 'requiere_nivel': requiredLevel,
      ...attributes, // Expande todos los atributos adicionales
    };
  }
}
