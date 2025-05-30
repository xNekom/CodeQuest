const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://codequest-c7b0b-default-rtdb.firebaseio.com/'
  });
}

const db = admin.firestore();

async function fixTest2Experience() {
  try {
    console.log('Iniciando corrección de experiencia para test2...');
    
    // Buscar el usuario test2
    const usersSnapshot = await db.collection('users').where('username', '==', 'test2').get();
    
    if (usersSnapshot.empty) {
      console.log('Usuario test2 no encontrado');
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userData = userDoc.data();
    const userId = userDoc.id;
    
    console.log(`Usuario encontrado: ${userData.username}`);
    console.log(`Nivel actual: ${userData.level || 1}`);
    console.log(`Experiencia actual: ${userData.experience || 0}`);
    
    const currentLevel = userData.level || 1;
    const currentExp = userData.experience || 0;
    const maxExpForLevel = currentLevel * 100;
    
    console.log(`Experiencia máxima para nivel ${currentLevel}: ${maxExpForLevel}`);
    
    if (currentExp > maxExpForLevel) {
      console.log(`Corrigiendo experiencia de ${currentExp} a ${maxExpForLevel}`);
      
      await db.collection('users').doc(userId).update({
        experience: maxExpForLevel
      });
      
      console.log('✅ Experiencia corregida exitosamente');
      
      // Actualizar leaderboard
      const leaderboardSnapshot = await db.collection('leaderboard').where('userId', '==', userId).get();
      if (!leaderboardSnapshot.empty) {
        const leaderboardDoc = leaderboardSnapshot.docs[0];
        
        // Recalcular puntuación
        const level = userData.level || 1;
        const experience = maxExpForLevel;
        const battlesWon = userData.stats?.battlesWon || 0;
        const correctAnswers = userData.stats?.correctAnswers || 0;
        const completedMissions = userData.completedMissions?.length || 0;
        
        const newScore = (level * 1000) + experience + (battlesWon * 50) + (correctAnswers * 10) + (completedMissions * 200);
        
        await db.collection('leaderboard').doc(leaderboardDoc.id).update({
          score: newScore
        });
        
        console.log(`✅ Puntuación actualizada en leaderboard: ${newScore}`);
      }
    } else {
      console.log('La experiencia ya está dentro del rango correcto');
    }
    
    console.log('Proceso completado');
    
  } catch (error) {
    console.error('Error al corregir experiencia:', error);
  }
}

fixTest2Experience().then(() => {
  process.exit(0);
}).catch((error) => {
  console.error('Error:', error);
  process.exit(1);
});