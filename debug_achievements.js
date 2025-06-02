const admin = require('firebase-admin');
const fs = require('fs');

// Inicializar Firebase Admin
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function debugAchievements() {
  try {
    console.log('🔍 Revisando logros en Firestore...');
    
    // Obtener todos los logros
    const achievementsSnapshot = await db.collection('achievements').get();
    
    console.log(`📊 Total de logros encontrados: ${achievementsSnapshot.docs.length}`);
    
    achievementsSnapshot.docs.forEach(doc => {
      const data = doc.data();
      console.log(`\n🏆 Logro: ${data.name}`);
      console.log(`   ID: ${doc.id}`);
      console.log(`   Tipo: ${data.achievementType}`);
      console.log(`   Categoría: ${data.category}`);
      console.log(`   Condiciones:`, data.conditions);
      console.log(`   Misiones requeridas:`, data.requiredMissionIds);
      if (data.requiredEnemyId) {
        console.log(`   Enemigo requerido: ${data.requiredEnemyId}`);
      }
    });
    
    console.log('\n🔍 Revisando misiones en Firestore...');
    
    // Obtener algunas misiones para ver sus IDs
    const missionsSnapshot = await db.collection('missions').limit(5).get();
    
    console.log(`\n📋 Primeras 5 misiones:`);
    missionsSnapshot.docs.forEach(doc => {
      const data = doc.data();
      console.log(`   - ${doc.id}: ${data.name}`);
      console.log(`     Tipo: ${data.type || 'No especificado'}`);
      if (data.objectives) {
        const hasBattle = data.objectives.some(obj => obj.type === 'batalla');
        console.log(`     Contiene batalla: ${hasBattle}`);
      }
    });
    
    console.log('\n🔍 Revisando usuarios para ver logros desbloqueados...');
    
    // Obtener algunos usuarios
    const usersSnapshot = await db.collection('users').limit(3).get();
    
    usersSnapshot.docs.forEach(doc => {
      const data = doc.data();
      console.log(`\n👤 Usuario: ${doc.id}`);
      console.log(`   Email: ${data.email || 'No especificado'}`);
      console.log(`   Logros desbloqueados: ${(data.unlockedAchievements || []).length}`);
      console.log(`   Lista de logros:`, data.unlockedAchievements || []);
      console.log(`   Misión actual: ${data.currentMissionId || 'Ninguna'}`);
      console.log(`   Misiones completadas: ${(data.completedMissions || []).length}`);
    });
    
  } catch (error) {
    console.error('❌ Error durante la revisión:', error);
  } finally {
    process.exit(0);
  }
}

// Ejecutar el script
debugAchievements();