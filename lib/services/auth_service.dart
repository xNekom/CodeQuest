import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  
  // Verificar si un nombre de usuario ya existe
  Future<bool> _checkUsernameExists(String username) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
          
      return result.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error al verificar nombre de usuario: $e');
      rethrow;
    }
  }
  
  // Crear documento de usuario en Firestore
  Future<void> _createUserDocument(String uid, String email, String username) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'role': 'user',
        'currentMissionId': '',
        'progressInMission': {},
        'completedMissions': {},
        'level': 1,
        'experiencePoints': 0,
        'gameCurrency': 0,
        'inventory': {},
        'unlockedAbilities': [],
        'equippedItems': {},
        'characterStats': {
          'questionsAnswered': 0,
          'correctAnswers': 0,
          'battlesWon': 0,
          'battlesLost': 0,
        },
        'difficultConcepts': {},
        'settings': {},
        'lastLogin': FieldValue.serverTimestamp(),
        'creationDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error al crear documento de usuario: $e');
      rethrow;
    }
  }
}
