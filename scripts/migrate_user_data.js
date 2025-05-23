const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrateUserData() {
  try {
    console.log('🔄 Iniciando migración de datos de usuarios...');
    
    // Get all users
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No se encontraron usuarios para migrar');
      return;
    }
    
    console.log(`📊 Encontrados ${usersSnapshot.size} usuarios para procesar`);
    
    let migratedCount = 0;
    let errorCount = 0;
    
    for (const userDoc of usersSnapshot.docs) {
      try {
        const userData = userDoc.data();
        const userId = userDoc.id;
        
        console.log(`\n🔍 Procesando usuario: ${userId}`);
        console.log(`   Username: ${userData.username || 'N/A'}`);
        console.log(`   Email: ${userData.email || 'N/A'}`);
        
        // Calculate current score using the correct formula
        const level = userData.level || 1;
        const experience = userData.experience || 0;
        const battlesWon = userData.stats?.battlesWon || 0;
        const correctAnswers = userData.stats?.correctAnswers || 0;
        const completedMissions = userData.completedMissions?.length || 0;
        
        const calculatedScore = (level * 1000) + experience + (battlesWon * 50) + (correctAnswers * 10) + (completedMissions * 200);
        
        console.log(`   Puntuación calculada: ${calculatedScore}`);
        
        // Check if user exists in leaderboard
        const leaderboardQuery = await db.collection('leaderboard')
          .where('userId', '==', userId)
          .get();
        
        if (!leaderboardQuery.empty) {
          // Update existing leaderboard entry
          const leaderboardDoc = leaderboardQuery.docs[0];
          const currentLeaderboardData = leaderboardDoc.data();
          
          console.log(`   📝 Actualizando entrada existente en leaderboard`);
          console.log(`   Puntuación actual en leaderboard: ${currentLeaderboardData.score}`);
          
          await leaderboardDoc.ref.update({
            username: userData.username || 'Usuario',
            score: calculatedScore,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp()
          });
          
          console.log(`   ✅ Entrada actualizada`);
        } else {
          // Create new leaderboard entry
          console.log(`   🆕 Creando nueva entrada en leaderboard`);
          
          await db.collection('leaderboard').add({
            userId: userId,
            username: userData.username || 'Usuario',
            score: calculatedScore,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp()
          });
          
          console.log(`   ✅ Nueva entrada creada`);
        }
        
        // Check if user exists in usernames collection
        if (userData.username) {
          const usernameDoc = await db.collection('usernames')
            .doc(userData.username.toLowerCase())
            .get();
          
          if (!usernameDoc.exists) {
            console.log(`   🆕 Creando entrada en colección usernames`);
            
            await db.collection('usernames')
              .doc(userData.username.toLowerCase())
              .set({
                uid: userId,
                username: userData.username,
                createdAt: admin.firestore.FieldValue.serverTimestamp()
              });
            
            console.log(`   ✅ Entrada en usernames creada`);
          } else {
            console.log(`   ℹ️  Entrada en usernames ya existe`);
          }
        }
        
        migratedCount++;
        
      } catch (userError) {
        console.error(`❌ Error procesando usuario ${userDoc.id}:`, userError);
        errorCount++;
      }
    }
    
    console.log(`\n📊 Resumen de migración:`);
    console.log(`   ✅ Usuarios procesados exitosamente: ${migratedCount}`);
    console.log(`   ❌ Errores: ${errorCount}`);
    
    // Verify leaderboard after migration
    console.log(`\n🔍 Verificando leaderboard después de la migración:`);
    const leaderboardSnapshot = await db.collection('leaderboard')
      .orderBy('score', 'desc')
      .get();
    
    console.log(`   Total entradas en leaderboard: ${leaderboardSnapshot.size}`);
    
    leaderboardSnapshot.forEach((doc, index) => {
      const data = doc.data();
      console.log(`   ${index + 1}. ${data.username} - ${data.score} puntos`);
    });
    
  } catch (error) {
    console.error('❌ Error en la migración:', error);
  } finally {
    process.exit(0);
  }
}

migrateUserData();