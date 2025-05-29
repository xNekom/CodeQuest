// filepath: lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import '../services/item_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/item_model.dart';
import '../widgets/pixel_widgets.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  late Future<List<ItemModel>> _itemsFuture;
  int _coins = 0;
  bool _isLoading = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  String _selectedType = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    _itemsFuture = _itemService.getItems();
    final user = _authService.currentUser;
    if (user != null) {
      final data = await _userService.getUserData(user.uid) ?? {};
      _coins = data['coins'] ?? 0;
    }
    setState(() { _isLoading = false; });
  }

  Future<void> _buyItem(ItemModel item) async {
    final user = _authService.currentUser;
    if (user == null) return;
    final price = item.attributes['valor_monetario'] as int? ?? 0;
    if (_coins < price) return;
    setState(() { _coins -= price; });
    await _userService.updateUserData(user.uid, {'coins': _coins});
    await _userService.addItemToInventory(user.uid, {'itemId': item.itemId, 'quantity': 1});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Has comprado: ${item.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIENDA'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Monedas: $_coins', style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                  child: FutureBuilder<List<ItemModel>>(  
                    future: _itemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final items = snapshot.data!;
                      // Filtrar ítems disponibles en la tienda (in_shop == true)
                      final shopItems = items.where((item) =>
                        item.attributes['in_shop'] == true
                      ).toList();
                      if (shopItems.isEmpty) {
                        return const Center(child: Text('No hay artículos disponibles.'));
                      }
                      // Obtener categorías de tipo
                      final types = <String>['Todos'] + shopItems.map((i) => i.type).toSet().toList();
                      // Filtrar por tipo seleccionado
                      final filteredItems = _selectedType == 'Todos'
                          ? shopItems
                          : shopItems.where((i) => i.type == _selectedType).toList();
                      if (filteredItems.isEmpty) {
                        return Center(child: Text('No hay artículos de la categoría "$_selectedType".'));
                      }
                      // Paginación
                      final totalPages = (filteredItems.length / _itemsPerPage).ceil();
                      final start = _currentPage * _itemsPerPage;
                      final end = start + _itemsPerPage < filteredItems.length
                          ? start + _itemsPerPage
                          : filteredItems.length;
                      final pageItems = filteredItems.sublist(start, end);
                      
                      return Column(
                        children: [
                          // Filtro por tipo
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: DropdownButton<String>(
                              value: _selectedType,
                              items: types.map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t[0].toUpperCase() + t.substring(1)),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                  _currentPage = 0;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: pageItems.length,
                              itemBuilder: (context, index) {
                                final item = pageItems[index];
                                final dynamic priceVal = item.attributes['valor_monetario'];
                                final price = priceVal is num ? priceVal.toInt() : 0;
                                final hasPrice = item.attributes.containsKey('valor_monetario');
                                final canBuy = hasPrice && _coins >= price;
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    leading: Image.asset(
                                      'assets/images/${item.icon}',
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                                    ),
                                    title: Text(item.name, style: const TextStyle(fontFamily: 'PixelFont')),
                                    subtitle: Text(item.description),
                                    trailing: SizedBox(
                                      width: 100,
                                      child: PixelButton(
                                        onPressed: canBuy ? () => _buyItem(item) : null,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.monetization_on, size: 16),
                                            const SizedBox(width: 4),
                                            Text(hasPrice ? '$price' : 'Gratis'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Controles de paginación
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PixelButton(
                                  onPressed: _currentPage > 0
                                      ? () => setState(() => _currentPage--)
                                      : null,
                                  child: const Text('Anterior'),
                                ),
                                const SizedBox(width: 16),
                                Text('Página ${_currentPage + 1}/$totalPages'),
                                const SizedBox(width: 16),
                                PixelButton(
                                  onPressed: _currentPage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                                  child: const Text('Siguiente'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
