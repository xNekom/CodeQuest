import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/code_exercise_model.dart';
import '../config/app_config.dart';

class DebugFirebaseScreen extends StatefulWidget {
  const DebugFirebaseScreen({super.key});

  @override
  State<DebugFirebaseScreen> createState() => _DebugFirebaseScreenState();
}

class _DebugFirebaseScreenState extends State<DebugFirebaseScreen> {
  final List<String> _logs = [];
  bool _isLoading = false;
  List<CodeExerciseModel> _exercises = [];
  String? _error;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
    });
    debugPrint(message);
  }

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _logs.clear();
      _exercises.clear();
    });

    try {
      _addLog('🔍 Iniciando test de conexión Firebase...');
      _addLog('⚙️ shouldUseFirebase: ${AppConfig.shouldUseFirebase}');

      if (!AppConfig.shouldUseFirebase) {
        _addLog('❌ Firebase está deshabilitado en AppConfig');
        setState(() {
          _error = 'Firebase está deshabilitado en la configuración';
          _isLoading = false;
        });
        return;
      }

      // Test 1: Conexión básica
      _addLog('📡 Test 1: Verificando conexión básica...');
      final firestore = FirebaseFirestore.instance;

      // Test 2: Verificar colección
      _addLog('📊 Test 2: Verificando colección code_exercises...');
      final collection = firestore.collection('code_exercises');

      // Test 3: Contar documentos
      _addLog('🔢 Test 3: Contando documentos...');
      final countSnapshot = await collection.get();
      _addLog('📋 Documentos encontrados: ${countSnapshot.docs.length}');

      if (countSnapshot.docs.isEmpty) {
        _addLog('⚠️ La colección está vacía');
        setState(() {
          _error = 'No hay ejercicios en Firestore';
          _isLoading = false;
        });
        return;
      }

      // Test 4: Consulta con orderBy
      _addLog('🔄 Test 4: Ejecutando consulta con orderBy...');
      final snapshot = await collection.orderBy('difficulty').get();
      _addLog('✅ Consulta orderBy exitosa: ${snapshot.docs.length} documentos');

      // Test 5: Deserialización
      _addLog('🔄 Test 5: Deserializando documentos...');
      List<CodeExerciseModel> exercises = [];

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        try {
          _addLog('📄 Procesando documento ${i + 1}: ${doc.id}');
          final data = doc.data();
          _addLog('📋 Campos: ${data.keys.join(', ')}');

          final exercise = CodeExerciseModel.fromJson(data);
          exercises.add(exercise);
          _addLog('✅ Ejercicio deserializado: ${exercise.title}');
        } catch (e) {
          _addLog('❌ Error deserializando documento ${doc.id}: $e');
        }
      }

      _addLog('🎯 Total de ejercicios procesados: ${exercises.length}');

      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });

      if (exercises.isEmpty) {
        _addLog('⚠️ No se pudo deserializar ningún ejercicio');
        setState(() {
          _error = 'Error en la deserialización de ejercicios';
        });
      } else {
        _addLog('🎉 Test completado exitosamente!');
      }
    } catch (e, stackTrace) {
      _addLog('❌ Error en test Firebase: $e');
      _addLog('📱 Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Firebase'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón de test
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testFirebaseConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Ejecutando test...'),
                          ],
                        )
                        : const Text('Ejecutar Test Firebase'),
              ),
            ),

            const SizedBox(height: 16),

            // Información de estado
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),

            if (_exercises.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ejercicios cargados:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    ..._exercises.map(
                      (exercise) => Text(
                        '• ${exercise.title} (Dificultad: ${exercise.difficulty})',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Logs
            const Text(
              'Logs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    _logs.isEmpty
                        ? const Text(
                          'No hay logs disponibles. Ejecuta el test para ver los logs.',
                          style: TextStyle(color: Colors.grey),
                        )
                        : ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                _logs[index],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
