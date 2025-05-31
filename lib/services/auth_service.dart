import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'leaderboard_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inicio de sesión con email y contraseña
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Actualizar la fecha del último inicio de sesión
      if (result.user != null) {
        final uid = result.user!.uid;
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        // Verificar si falta documento de perfil y crearlo si no existe
        final doc = await _firestore.collection('users').doc(uid).get();
        if (!doc.exists) {
          final defaultUsername = result.user!.email!.split('@')[0];
          await _createUserDocument(uid, result.user!.email!, defaultUsername);
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('Error en inicio de sesión: $e');
      rethrow;
    }
  }

  // Registro con email y contraseña
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Verificar si el nombre de usuario ya existe
      bool usernameExists = await _checkUsernameExists(username);
      if (usernameExists) {
        throw Exception('El nombre de usuario ya está en uso');
      }

      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Crear documento del usuario en Firestore
      await _createUserDocument(userCredential.user!.uid, email, username);
      
      return userCredential;
    } catch (e) {
      debugPrint('Error en registro: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error en SignOut: $e');
      rethrow;
    }
  }
  
  // Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error al enviar reset de contraseña: $e');
      rethrow;
    }
  }
  
  // Verificar si un nombre de usuario ya existe - Método alternativo sin consultas
  Future<bool> _checkUsernameExists(String username) async {
    try {
      // Método alternativo: crear un documento temporal con el username como ID
      // y verificar si ya existe
      final DocumentSnapshot usernameDoc = await _firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .get();
          
      return usernameDoc.exists;
    } catch (e) {
      debugPrint('Error al verificar nombre de usuario: $e');
      // Si hay error, permitir continuar para no bloquear el registro
      return false;
    }
  }
  
  // Crear documento de usuario en Firestore
  Future<void> _createUserDocument(String uid, String email, String username) async {
    try {
      // Crear documento de usuario
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'role': 'user',
        'currentMissionId': '',
        'progressInMission': {},
        'completedMissions': [],
        'level': 1,
        'experience': 0,
        'experiencePoints': 0,
        'coins': 0,
        'gameCurrency': 0,
        'inventory': {'items': []},
        'unlockedAbilities': [],
        'equippedItems': {},
        'unlockedAchievements': [],
        'skinTone': 'Claro',
        'hairStyle': 'Corto',
        'outfit': 'Aventurero',
        'characterCreated': false,
        'stats': {
          'questionsAnswered': 0,
          'correctAnswers': 0,
          'battlesWon': 0,
          'battlesLost': 0,
          'enemiesDefeated': {},
          'totalEnemiesDefeated': 0,
        },
        'characterStats': {
          'health': 100,
          'attack': 10,
          'defense': 5,
          'speed': 8,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      // Registrar username en colección separada para verificación
      await _firestore.collection('usernames').doc(username.toLowerCase()).set({
        'uid': uid,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Crear entrada inicial en el leaderboard
      await _leaderboardService.updateLeaderboardEntry(
        userId: uid,
        username: username,
        score: 1000, // Puntuación inicial (nivel 1 * 1000)
      );
      
      debugPrint('Usuario creado exitosamente: $uid');
    } catch (e) {
      debugPrint('Error al crear documento de usuario: $e');
      rethrow;
    }
  }

  // Reautenticar al usuario
  Future<bool> reauthenticateUser(String currentPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception("Usuario no encontrado o email no disponible para reautenticación.");
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase Auth, por ejemplo, contraseña incorrecta
      debugPrint('Error de reautenticación: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error inesperado durante la reautenticación: $e');
      rethrow;
    }
  }

  // Cambiar la contraseña del usuario
  Future<void> changePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Usuario no encontrado para cambiar contraseña.");
      }
      await user.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Error al cambiar la contraseña: $e');
      rethrow;
    }
  }
}
