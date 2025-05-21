import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script para poblar el leaderboard con datos de usuarios existentes
void main() async {
  print('🚀 Iniciando población del leaderboard...');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
    
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    // Obtener todos los usuarios
    print('📊 Obteniendo usuarios existentes...');
    QuerySnapshot usersSnapshot = await firestore.collection('users').get();
    
    if (usersSnapshot.docs.isEmpty) {
      print('⚠️  No se encontraron usuarios en la base de datos');
      return;
    }
    
    print('👥 Encontrados ${usersSnapshot.docs.length} usuarios');
    
    int processedUsers = 0;
    int successfulUpdates = 0;
    
    // Procesar cada usuario
    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      try {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userId = userDoc.id;
        final username = userData['username'] ?? 'Usuario ${userId.substring(0, 6)}';
        
        // Calcular puntuación usando la misma lógica que LeaderboardService
        final level = userData['level'] ?? 1;
        final experience = userData['experience'] ?? 0;
        final battlesWon = userData['battlesWon'] ?? 0;
        final correctAnswers = userData['correctAnswers'] ?? 0;
        final completedMissions = userData['completedMissions']?.length ?? 0;
        
        final score = (level * 1000) + 
                     (experience * 10) + 
                     (battlesWon * 500) + 
                     (correctAnswers * 100) + 
                     (completedMissions * 200);
        
        // Solo actualizar si el usuario tiene algún progreso
        if (score > 1000) { // Más que solo el nivel inicial
          // Crear entrada en el leaderboard
          await firestore.collection('leaderboard').doc(userId).set({
            'userId': userId,
            'username': username,
            'score': score,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
          print('✅ Usuario actualizado: $username (Puntuación: $score)');
          successfulUpdates++;
        } else {
          print('⏭️  Usuario omitido: $username (Sin progreso significativo)');
        }
        
        processedUsers++;
        
        // Pequeña pausa para evitar sobrecargar Firestore
        await Future.delayed(Duration(milliseconds: 100));
        
      } catch (e) {
        print('❌ Error procesando usuario ${userDoc.id}: $e');
      }
    }
    
    print('\n🎉 Proceso completado:');
    print('   📊 Usuarios procesados: $processedUsers');
    print('   ✅ Actualizaciones exitosas: $successfulUpdates');
    print('   ❌ Errores: ${processedUsers - successfulUpdates}');
    
    // Mostrar top 10 del leaderboard
    print('\n🏆 Top 10 del leaderboard:');
    QuerySnapshot leaderboardSnapshot = await firestore
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .limit(10)
        .get();
    
    for (int i = 0; i < leaderboardSnapshot.docs.length; i++) {
      final doc = leaderboardSnapshot.docs[i];
      final data = doc.data() as Map<String, dynamic>;
      final username = data['username'] ?? 'Usuario desconocido';
      final score = data['score'] ?? 0;
      final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '  ';
      print('   $medal ${i + 1}. $username - $score puntos');
    }
    
  } catch (e, stackTrace) {
    print('💥 Error crítico: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
  
  print('\n✨ Script completado exitosamente');
  exit(0);
}