const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function checkFirestoreRules() {
  try {
    console.log('🔒 Verificando reglas de seguridad de Firestore...');
    
    // Note: Firebase Admin SDK doesn't directly provide access to security rules
    // But we can test permissions by trying to read/write data
    
    const db = admin.firestore();
    
    console.log('\n🧪 Probando permisos de lectura/escritura...');
    
    // Test reading users collection
    try {
      const usersSnapshot = await db.collection('users').limit(1).get();
      console.log('✅ Lectura de usuarios: PERMITIDA');
    } catch (error) {
      console.log('❌ Lectura de usuarios: DENEGADA');
      console.log(`   Error: ${error.message}`);
    }
    
    // Test reading leaderboard collection
    try {
      const leaderboardSnapshot = await db.collection('leaderboard').limit(1).get();
      console.log('✅ Lectura de leaderboard: PERMITIDA');
    } catch (error) {
      console.log('❌ Lectura de leaderboard: DENEGADA');
      console.log(`   Error: ${error.message}`);
    }
    
    // Test writing to leaderboard collection
    try {
      const testDoc = db.collection('leaderboard').doc('test-entry');
      await testDoc.set({
        userId: 'test-user',
        displayName: 'Test User',
        score: 0,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log('✅ Escritura de leaderboard: PERMITIDA');
      
      // Clean up test document
      await testDoc.delete();
      console.log('🧹 Documento de prueba eliminado');
    } catch (error) {
      console.log('❌ Escritura de leaderboard: DENEGADA');
      console.log(`   Error: ${error.message}`);
    }
    
    console.log('\n📋 Reglas recomendadas para Firestore:');
    console.log(`
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para usuarios
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Permitir lectura para leaderboard
    }
    
    // Reglas para leaderboard
    match /leaderboard/{entryId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
    }
    
    // Reglas para otras colecciones
    match /questions/{questionId} {
      allow read: if request.auth != null;
    }
    
    match /missions/{missionId} {
      allow read: if request.auth != null;
    }
    
    match /enemies/{enemyId} {
      allow read: if request.auth != null;
    }
    
    match /items/{itemId} {
      allow read: if request.auth != null;
    }
    
    match /rewards/{rewardId} {
      allow read: if request.auth != null;
    }
    
    match /achievements/{achievementId} {
      allow read: if request.auth != null;
    }
  }
}`);
    
  } catch (error) {
    console.error('❌ Error verificando reglas:', error);
  } finally {
    process.exit(0);
  }
}

checkFirestoreRules();