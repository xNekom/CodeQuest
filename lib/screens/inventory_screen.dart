import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/tutorial_service.dart';
import '../services/item_service.dart';
import '../models/item_model.dart';

import '../widgets/pixel_widgets.dart';
import '../widgets/pixel_art_background.dart';
import '../widgets/pixel_app_bar.dart';
import '../widgets/tutorial_floating_button.dart';
import '../utils/overflow_utils.dart';
import '../theme/pixel_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final ItemService _itemService = ItemService();
  late User? _currentUser;
  bool _isLoading = true;
  List<Map<String, dynamic>> _inventoryItems = [];
  Map<String, ItemModel> _itemsDatabase = {};

  
  // GlobalKeys para el sistema de tutoriales
  final GlobalKey _inventoryListKey = GlobalKey();
  final GlobalKey _itemCardKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _backButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
    _checkAndStartTutorial();
  }
  
  /// Inicia el tutorial si es necesario
  Future<void> _checkAndStartTutorial() async {
    // Esperar a que la UI se construya completamente
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      TutorialService.startTutorialIfNeeded(
        context,
        TutorialService.inventoryTutorial,
        TutorialService.getInventoryTutorial(
          inventoryGridKey: _inventoryListKey,
          categoryFilterKey: _itemCardKey,
          itemDetailKey: _statsKey,
          backButtonKey: _backButtonKey,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos solo cuando la ruta se vuelve activa
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      // Usar Future.microtask en lugar de addPostFrameCallback para evitar bucles infinitos
      Future.microtask(() {
        if (mounted) {
          _loadInventoryData();
        }
      });
    }
  }

  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
    });

    _currentUser = _authService.currentUser;
    if (_currentUser == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
      return;
    }

    try {
      // Primero cargar la base de datos de items
      final items = await _itemService.getItems();
      _itemsDatabase = {for (var item in items) item.itemId: item};
      
      final userData = await _userService.getUserData(_currentUser!.uid);
      if (mounted) {
        setState(() {
          _inventoryItems = _extractAndEnrichInventoryItems(userData);
          _isLoading = false;
        });
      }
    } catch (e) {
      // debugPrint('Error al cargar inventario: $e'); // REMOVIDO PARA PRODUCCIÓN
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _extractInventoryItems(
    Map<String, dynamic>? userData,
  ) {
    if (userData == null) return [];

    final inventory = userData['inventory'] as Map<String, dynamic>?;
    if (inventory == null) return [];

    final items = inventory['items'] as List<dynamic>?;
    if (items == null) return [];

    return items.map((item) => item as Map<String, dynamic>).toList();
  }

  List<Map<String, dynamic>> _extractAndEnrichInventoryItems(
    Map<String, dynamic>? userData,
  ) {
    final baseItems = _extractInventoryItems(userData);
    
    return baseItems.map((item) {
      final itemId = item['itemId'] as String?;
      if (itemId != null && _itemsDatabase.containsKey(itemId)) {
        final itemData = _itemsDatabase[itemId]!;
        return {
          ...item,
          'name': itemData.name,
          'description': itemData.description,
          'type': itemData.type,
          'rarity': itemData.rarity,
        };
      }
      return item;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PixelAppBar(
        title: 'INVENTARIO',
        leading: IconButton(
          key: _backButtonKey,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PixelArtBackground(
        child:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                )
                : _buildInventoryContent(),
      ),
      floatingActionButton: TutorialFloatingButton(
        tutorialKey: TutorialService.inventoryTutorial,
        tutorialSteps: TutorialService.getInventoryTutorial(
          inventoryGridKey: _inventoryListKey,
          categoryFilterKey: _itemCardKey,
          itemDetailKey: _statsKey,
          backButtonKey: _backButtonKey,
        ),
      ),
    );
  }

  Widget _buildInventoryContent() {
    if (_inventoryItems.isEmpty) {
      return _buildEmptyInventory();
    }

    return Column(
      children: [
        _buildInventoryHeader(),
        Expanded(child: _buildInventoryGrid()),
      ],
    );
  }

  Widget _buildInventoryHeader() {
    return Container(
      key: _statsKey,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(204),
        borderRadius: BorderRadius.circular(PixelTheme.borderRadiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Tus Items',
            style: TextStyle(
              fontFamily: 'PixelFont',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_inventoryItems.length} items en tu inventario',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid() {
    return Padding(
      key: _inventoryListKey,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _inventoryItems.length,
        itemBuilder: (context, index) {
          final item = _inventoryItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInventoryItemCard(item, index == 0 ? _itemCardKey : null),
          );
        },
      ),
    );
  }

  Widget _buildInventoryItemCard(Map<String, dynamic> item, [GlobalKey? key]) {
    final String itemName = item['name'] ?? 'Item Desconocido';
    final String itemDescription = item['description'] ?? 'Sin descripción disponible';
    final int quantity = item['quantity'] ?? 1;
    final String rarity = item['rarity'] ?? 'common';

    Color rarityColor = _getRarityColor(rarity);

    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: Container(
        key: key,
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(PixelTheme.borderRadiusMedium),
          border: Border.all(color: rarityColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withAlpha(77),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono del item
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: rarityColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(PixelTheme.borderRadiusSmall),
                ),
                child: Icon(
                  _getItemIcon(item),
                  size: 32,
                  color: rarityColor,
                ),
              ),
              const SizedBox(width: 12),
              // Información del item
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nombre del item
                    OverflowUtils.safeText(
                      itemName,
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    // Descripción del item
                    OverflowUtils.safeText(
                      itemDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              // Información lateral (cantidad y rareza)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cantidad
                  if (quantity > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'x$quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Rareza
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: rarityColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getRarityDisplayName(rarity),
                      style: TextStyle(
                        fontSize: 10,
                        color: rarityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyInventory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Inventario Vacío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa misiones y compra items en la tienda\npara llenar tu inventario',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PixelButton(
            onPressed: () {
              Navigator.pushNamed(context, '/shop');
            },
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.store, size: 20),
                SizedBox(width: 8),
                Text('IR A LA TIENDA'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    final String itemName = item['name'] ?? 'Item Desconocido';
    final String itemDescription = item['description'] ?? 'Sin descripción disponible';
    final int quantity = item['quantity'] ?? 1;
    final String rarity = item['rarity'] ?? 'common';
    final String type = item['type'] ?? 'misc';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              itemName,
              style: TextStyle(
                fontFamily: 'PixelFont',
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(
                maxHeight: 400, // Altura máxima fija para todo el contenido
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _getRarityColor(rarity).withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getRarityColor(rarity),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getItemIcon(item),
                          size: 50,
                          color: _getRarityColor(rarity),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Descripción del item
                    Text(
                      'Descripción:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      itemDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Cantidad', 'x$quantity'),
                    _buildDetailRow('Rareza', _getRarityDisplayName(rarity)),
                    _buildDetailRow('Tipo', _getTypeDisplayName(type)),
                    const SizedBox(height: 16), // Espacio adicional al final
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CERRAR'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PixelTheme.spacingXSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'uncommon':
        return Colors.green;
      case 'common':
      default:
        return Colors.grey;
    }
  }

  String _getRarityDisplayName(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return 'Legendario';
      case 'epic':
        return 'Épico';
      case 'rare':
        return 'Raro';
      case 'uncommon':
        return 'Poco común';
      case 'common':
      default:
        return 'Común';
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'weapon':
        return 'Arma';
      case 'armor':
        return 'Armadura';
      case 'consumable':
        return 'Consumible';
      case 'material':
        return 'Material';
      case 'quest':
        return 'Misión';
      case 'misc':
      default:
        return 'Varios';
    }
  }

  IconData _getItemIcon(Map<String, dynamic> item) {
    final String type = item['type'] ?? 'misc';
    final String itemId = item['itemId'] ?? '';

    // Iconos específicos por ID de item
    if (itemId.contains('pocion')) return Icons.local_drink;
    if (itemId.contains('espada')) return Icons.sports_kabaddi;
    if (itemId.contains('escudo')) return Icons.shield;
    if (itemId.contains('gema')) return Icons.diamond;
    if (itemId.contains('fragmento')) return Icons.auto_fix_high;

    // Iconos por tipo
    switch (type.toLowerCase()) {
      case 'weapon':
        return Icons.sports_kabaddi;
      case 'armor':
        return Icons.shield;
      case 'consumable':
        return Icons.local_drink;
      case 'material':
        return Icons.build;
      case 'quest':
        return Icons.assignment;
      case 'misc':
      default:
        return Icons.inventory_2;
    }
  }
}
