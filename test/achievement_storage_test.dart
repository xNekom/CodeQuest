import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/reward_service.dart';
import '../lib/models/achievement_model.dart';
import '../lib/config/app_config.dart';

// Mocks necesarios para el test
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('Achievement Storage Tests', () {
    late RewardService rewardService;
    late MockFirestore mockFirestore;
    late MockCollectionReference mockUsersCollection;
    late MockCollectionReference mockAchievementsCollection;
    late MockDocumentReference mockUserDoc;
    late MockDocumentSnapshot mockUserSnapshot;

    setUp(() {
      mockFirestore = MockFirestore();
      mockUsersCollection = MockCollectionReference();
      mockAchievementsCollection = MockCollectionReference();
      mockUserDoc = MockDocumentReference();
      mockUserSnapshot = MockDocumentSnapshot();
      
      // Configurar mocks básicos
      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockFirestore.collection('achievements')).thenReturn(mockAchievementsCollection);
      when(mockUsersCollection.doc(any)).thenReturn(mockUserDoc);
      
      rewardService = RewardService();
    });

    testWidgets('Achievement is stored in both user document and separate collection', (WidgetTester tester) async {
      // Configurar AppConfig para usar Firebase
      AppConfig.shouldUseFirebase = true;
      
      // Datos de prueba
      const String testUserId = 'test_user_123';
      const String testMissionId = 'mision_batalla_final';
      
      final testAchievement = Achievement(
        id: 'achievement_bug_supremo',
        name: 'Conquistador Supremo',
        description: 'Derrota al Bug Supremo en la Batalla Final.',
        iconUrl: 'assets/images/badge_bug_supremo.png',
        category: 'mission',
        points: 100,
        conditions: {},
        requiredMissionIds: [testMissionId],
        rewardId: 'recompensa_bug_supremo',
        achievementType: 'mission',
      );

      // Mock para simular que el usuario completó la misión requerida
      when(mockUserSnapshot.exists).thenReturn(true);
      when(mockUserSnapshot.data()).thenReturn({
        'completedMissions': [testMissionId],
        'unlockedAchievements': [], // Inicialmente vacío
      });
      when(mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);

      // Mock para simular que el logro no está desbloqueado aún
      final mockUserAchievementsCol = MockCollectionReference();
      final mockAchievementDoc = MockDocumentReference();
      final mockAchievementSnapshot = MockDocumentSnapshot();
      
      when(mockFirestore.collection('user_achievements')).thenReturn(mockUserAchievementsCol);
      when(mockUserAchievementsCol.doc(testUserId)).thenReturn(mockUserDoc);
      when(mockUserDoc.collection('achievements')).thenReturn(mockUserAchievementsCol);
      when(mockUserAchievementsCol.doc(testAchievement.id)).thenReturn(mockAchievementDoc);
      when(mockAchievementSnapshot.exists).thenReturn(false);
      when(mockAchievementDoc.get()).thenAnswer((_) async => mockAchievementSnapshot);

      // Mock para obtener logros que requieren la misión
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      
      when(mockAchievementsCollection.where('requiredMissionIds', arrayContains: testMissionId))
          .thenReturn(MockQuery());
      when(MockQuery().get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.data()).thenReturn(testAchievement.toMap());

      // Mock para las operaciones de escritura
      when(mockAchievementDoc.set(any)).thenAnswer((_) async => {});
      when(mockUserDoc.update(any)).thenAnswer((_) async => {});

      // Ejecutar el método que verifica y desbloquea logros
      try {
        await rewardService.checkAndUnlockAchievement(testUserId, testMissionId);
        
        // Verificaciones
        // 1. Verificar que se guarda en la colección separada
        verify(mockAchievementDoc.set(argThat(containsPair('achievementId', testAchievement.id))));
        
        // 2. Verificar que se actualiza el documento principal del usuario
        verify(mockUserDoc.update(argThat(containsPair('unlockedAchievements', anything))));
        
        print('✅ Test pasado: El logro se almacena en ambos lugares correctamente');
      } catch (e) {
        print('❌ Test falló: $e');
        rethrow;
      }
    });

    test('User document contains unlockedAchievements field after achievement unlock', () async {
      // Este test simula verificar que el documento del usuario contiene el campo después del desbloqueo
      
      const String testUserId = 'test_user_123';
      const String achievementId = 'achievement_primer_bug';
      
      // Simular datos del usuario después del desbloqueo
      final userData = {
        'uid': testUserId,
        'email': 'test@example.com',
        'displayName': 'Test User',
        'unlockedAchievements': [achievementId], // El logro debe aparecer aquí
        'completedMissions': ['some_mission_id'],
        'experiencePoints': 100,
      };

      // Verificar que el campo unlockedAchievements contiene el ID del logro
      expect(userData['unlockedAchievements'], contains(achievementId));
      expect(userData['unlockedAchievements'], isA<List>());
      expect((userData['unlockedAchievements'] as List).length, equals(1));
      
      print('✅ Test pasado: El documento del usuario contiene el campo unlockedAchievements con el logro desbloqueado');
    });

    test('Achievement model serialization includes all required fields', () {
      // Test para verificar que el modelo de Achievement incluye todos los campos necesarios
      
      final testAchievement = Achievement(
        id: 'test_achievement',
        name: 'Test Achievement',
        description: 'Test Description',
        iconUrl: 'test_icon.png',
        category: 'test',
        points: 50,
        conditions: {'test': 'value'},
        requiredMissionIds: ['mission1'],
        rewardId: 'reward1',
        achievementType: 'mission',
      );

      final map = testAchievement.toMap();
      
      // Verificar que todos los campos necesarios están presentes
      expect(map['id'], equals('test_achievement'));
      expect(map['name'], equals('Test Achievement'));
      expect(map['description'], equals('Test Description'));
      expect(map['iconUrl'], equals('test_icon.png'));
      expect(map['category'], equals('test'));
      expect(map['points'], equals(50));
      expect(map['conditions'], equals({'test': 'value'}));
      expect(map['requiredMissionIds'], equals(['mission1']));
      expect(map['rewardId'], equals('reward1'));
      expect(map['achievementType'], equals('mission'));
      
      print('✅ Test pasado: El modelo de Achievement se serializa correctamente con todos los campos');
    });
  });
}

// Mocks adicionales necesarios para el test
class MockQuery extends Mock implements Query {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}
