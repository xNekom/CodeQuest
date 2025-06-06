import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpecificManagementTab extends StatefulWidget {
  final String title;
  final String field;
  final String fieldName;
  final IconData icon;
  final Color color;
  final int maxValue;
  final List<int> quickIncrements;
  final List<String> quickLabels;
  final VoidCallback? onDataUpdated;

  const SpecificManagementTab({
    super.key,
    required this.title,
    required this.field,
    required this.fieldName,
    required this.icon,
    required this.color,
    required this.maxValue,
    required this.quickIncrements,
    required this.quickLabels,
    this.onDataUpdated,
  });

  @override
  State<SpecificManagementTab> createState() => _SpecificManagementTabState();
}

class _SpecificManagementTabState extends State<SpecificManagementTab> {
  final CollectionReference _usersCol = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    if (currentUserId == null) {
      return Center(
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text(
                  'Error de autenticación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'No se pudo obtener la información del usuario actual.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            border: Border.all(color: widget.color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestiona específicamente tus valores de ${widget.fieldName}.',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.color.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _usersCol.doc(currentUserId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('No se encontraron datos del usuario'));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final currentValue = data[widget.field] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: widget.color,
                              child: Icon(widget.icon, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['username'] ?? 'Usuario actual',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${widget.fieldName} actual: $currentValue',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showSpecificHackDialog(
                                  currentUserId,
                                  widget.field,
                                  currentValue,
                                  widget.fieldName,
                                  widget.icon,
                                  widget.color,
                                  widget.maxValue,
                                  widget.quickIncrements,
                                  widget.quickLabels,
                                ),
                                icon: Icon(Icons.edit, size: 16),
                                label: Text(
                                  'Editar ${widget.fieldName}',
                                  style: TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.color,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _quickUpdate(
                                currentUserId,
                                widget.field,
                                0,
                                widget.fieldName,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            widget.quickIncrements.length,
                            (i) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: TextButton(
                                  onPressed: () => _quickUpdate(
                                    currentUserId,
                                    widget.field,
                                    currentValue + widget.quickIncrements[i],
                                    widget.fieldName,
                                  ),
                                  child: Text('+${widget.quickLabels[i]}', style: TextStyle(fontSize: 10)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
            },
          ),
        ),
      ],
    );
  }

  void _showSpecificHackDialog(
    String userId,
    String field,
    int currentValue,
    String fieldName,
    IconData icon,
    Color color,
    int maxValue,
    List<int> quickIncrements,
    List<String> quickLabels,
  ) {
    final controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Editar $fieldName',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: fieldName,
                hintText: 'Valor entre 0 y $maxValue',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(icon, color: color),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Incrementos rápidos:',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                quickIncrements.length,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ElevatedButton(
                      onPressed: () {
                        int newValue = currentValue + quickIncrements[i];
                        if (newValue <= maxValue) {
                          controller.text = newValue.toString();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('+${quickLabels[i]}', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                controller.text = '0';
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset a 0'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value == null || value < 0 || value > maxValue) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Valor inválido. Debe estar entre 0 y $maxValue',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Capturar contextos antes de operaciones async
              final navigatorContext = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              try {
                await _usersCol.doc(userId).update({field: value});
                if (!mounted) return;
                widget.onDataUpdated?.call(); // Notificar cambios
                navigatorContext.pop(true); // Notificar que hubo cambios
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '$fieldName actualizado correctamente a $value',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _quickUpdate(
    String userId,
    String field,
    int newValue,
    String fieldName,
  ) async {
    try {
      await _usersCol.doc(userId).update({field: newValue});
      if (!mounted) return;
      widget.onDataUpdated?.call(); // Notificar cambios
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName actualizado a $newValue'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}