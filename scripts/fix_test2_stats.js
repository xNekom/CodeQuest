const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixTest2Stats() {
  try {
    console.log('🔧 Corrigiendo estadísticas del usuario test2...');
    
    // ID específico del usuario test2
    const test2UserId = 'XDaofPpwGVNSBACvVCtwYBGSJAN2';
    
    // Obtener datos actuales del usuario
    const userDoc = await db.collection('users').doc(test2UserId).get();
    
    if (!userDoc.exists) {
      console.log('❌ Usuario test2 no encontrado');
      return;
    }
    
    const userData = userDoc.data();
    console.log('📊 Datos actuales del usuario test2:');
    console.log(`   questionsAnswered (raíz): ${userData.questionsAnswered || 0}`);
    console.log(`   correctAnswers (raíz): ${userData.correctAnswers || 0}`);
    console.log(`   stats.questionsAnswered: ${userData.stats?.questionsAnswered || 0}`);
    console.log(`   stats.correctAnswers: ${userData.stats?.correctAnswers || 0}`);
    
    // Preparar datos de actualización
    const updateData = {
      'stats.questionsAnswered': userData.questionsAnswered || 0,
      'stats.correctAnswers': userData.correctAnswers || 0,
      // Eliminar campos duplicados de la raíz
      questionsAnswered: admin.firestore.FieldValue.delete(),
      correctAnswers: admin.firestore.FieldValue.delete()
    };
    
    console.log('\n🔄 Aplicando correcciones...');
    console.log(`   Moviendo questionsAnswered: ${userData.questionsAnswered || 0} -> stats.questionsAnswered`);
    console.log(`   Moviendo correctAnswers: ${userData.correctAnswers || 0} -> stats.correctAnswers`);
    console.log('   Eliminando campos duplicados de la raíz');
    
    // Aplicar actualización
    await db.collection('users').doc(test2UserId).update(updateData);
    
    console.log('\n✅ Corrección aplicada exitosamente');
    
    // Verificar resultado
    const updatedDoc = await db.collection('users').doc(test2UserId).get();
    const updatedData = updatedDoc.data();
    
    console.log('\n📊 Datos después de la corrección:');
    console.log(`   questionsAnswered (raíz): ${updatedData.questionsAnswered || 'ELIMINADO'}`);
    console.log(`   correctAnswers (raíz): ${updatedData.correctAnswers || 'ELIMINADO'}`);
    console.log(`   stats.questionsAnswered: ${updatedData.stats?.questionsAnswered || 0}`);
    console.log(`   stats.correctAnswers: ${updatedData.stats?.correctAnswers || 0}`);
    
    // Actualizar leaderboard
    console.log('\n🏆 Actualizando leaderboard...');
    const leaderboardService = {
      async updateUserScore(userId) {
        const userDoc = await db.collection('users').doc(userId).get();
        if (!userDoc.exists) return;
        
        const userData = userDoc.data();
        const score = (userData.level || 1) * 1000 + 
                     (userData.experience || 0) + 
                     (userData.stats?.battlesWon || 0) * 50 + 
                     (userData.stats?.correctAnswers || 0) * 10 + 
                     (userData.completedMissions ? userData.completedMissions.length * 200 : 0);
        
        await db.collection('leaderboard').doc(userId).update({
          score: score,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log(`   ✅ Puntuación actualizada: ${score}`);
      }
    };
    
    await leaderboardService.updateUserScore(test2UserId);
    
  } catch (error) {
    console.error('❌ Error corrigiendo estadísticas:', error);
  } finally {
    process.exit(0);
  }
}

fixTest2Stats();