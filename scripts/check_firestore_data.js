const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkFirestoreData() {
  try {
    console.log('🔍 Verificando datos específicos en Firestore...');
    
    // Check users collection
    console.log('\n👥 Verificando colección de usuarios:');
    const usersSnapshot = await db.collection('users').get();
    
    if (!usersSnapshot.empty) {
      console.log(`   Total usuarios: ${usersSnapshot.size}`);
      
      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        console.log(`\n   Usuario: ${doc.id}`);
        console.log(`     Username: ${userData.username || 'N/A'}`);
        console.log(`     Email: ${userData.email || 'N/A'}`);
        console.log(`     Nivel: ${userData.level || 0}`);
        console.log(`     Experiencia: ${userData.experience || 0}`);
        console.log(`     Batallas ganadas: ${userData.stats?.battlesWon || 0}`);
        console.log(`     Respuestas correctas: ${userData.stats?.correctAnswers || 0}`);
        console.log(`     Misiones completadas: ${userData.completedMissions ? userData.completedMissions.length : 0}`);
        
        // Calculate score like in the service
        const score = (userData.level || 1) * 1000 + 
                     (userData.experience || 0) + 
                     (userData.stats?.battlesWon || 0) * 50 + 
                     (userData.stats?.correctAnswers || 0) * 10 + 
                     (userData.completedMissions ? userData.completedMissions.length * 200 : 0);
        console.log(`     Puntuación calculada: ${score}`);
      });
    } else {
      console.log('   ❌ No se encontraron usuarios');
    }
    
    // Check leaderboard collection
    console.log('\n🏆 Verificando colección leaderboard:');
    const leaderboardSnapshot = await db.collection('leaderboard').orderBy('score', 'desc').get();
    
    if (!leaderboardSnapshot.empty) {
      console.log(`   Total entradas en leaderboard: ${leaderboardSnapshot.size}`);
      
      leaderboardSnapshot.forEach(doc => {
        const leaderboardData = doc.data();
        console.log(`\n   Entrada: ${doc.id}`);
        console.log(`     Usuario ID: ${leaderboardData.userId}`);
        console.log(`     Username: ${leaderboardData.username || 'N/A'}`);
        console.log(`     Puntuación: ${leaderboardData.score}`);
        console.log(`     Última actualización: ${leaderboardData.lastUpdated ? leaderboardData.lastUpdated.toDate() : 'N/A'}`);
      });
    } else {
      console.log('   ❌ No se encontraron entradas en leaderboard');
    }
    
    // Check leaderboards collection (plural)
    console.log('\n🏆 Verificando colección leaderboards (plural):');
    const leaderboardsSnapshot = await db.collection('leaderboards').orderBy('score', 'desc').get();
    
    if (!leaderboardsSnapshot.empty) {
      console.log(`   Total entradas en leaderboards: ${leaderboardsSnapshot.size}`);
      
      leaderboardsSnapshot.forEach(doc => {
        const leaderboardData = doc.data();
        console.log(`\n   Entrada: ${doc.id}`);
        console.log(`     Usuario ID: ${leaderboardData.userId}`);
        console.log(`     Username: ${leaderboardData.username || 'N/A'}`);
        console.log(`     Puntuación: ${leaderboardData.score}`);
        console.log(`     Última actualización: ${leaderboardData.lastUpdated ? leaderboardData.lastUpdated.toDate() : 'N/A'}`);
      });
    } else {
      console.log('   ❌ No se encontraron entradas en leaderboards');
    }
    
  } catch (error) {
    console.error('❌ Error verificando datos:', error);
  } finally {
    process.exit(0);
  }
}

checkFirestoreData();