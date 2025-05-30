// Script para poblar el leaderboard con datos de usuarios existentes en Firebase
const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function populateLeaderboard() {
  console.log('🚀 Iniciando población del leaderboard...');
  
  try {
    // Obtener todos los usuarios
    console.log('📊 Obteniendo usuarios existentes...');
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('⚠️  No se encontraron usuarios en la base de datos');
      return;
    }
    
    console.log(`👥 Encontrados ${usersSnapshot.size} usuarios`);
    
    let processedUsers = 0;
    let successfulUpdates = 0;
    
    // Procesar cada usuario
    for (const userDoc of usersSnapshot.docs) {
      try {
        const userData = userDoc.data();
        const userId = userDoc.id;
        const username = userData.username || `Usuario ${userId.substring(0, 6)}`;
        
        // Calcular puntuación usando la misma lógica que LeaderboardService
        const level = userData.level || 1;
        const experience = userData.experience || 0;
        const battlesWon = userData.battlesWon || 0;
        const correctAnswers = userData.correctAnswers || 0;
        const completedMissions = userData.completedMissions ? userData.completedMissions.length : 0;
        
        const score = (level * 1000) + 
                     (experience * 10) + 
                     (battlesWon * 500) + 
                     (correctAnswers * 100) + 
                     (completedMissions * 200);
        
        // Solo actualizar si el usuario tiene algún progreso
        if (score > 1000) { // Más que solo el nivel inicial
          // Crear entrada en el leaderboard
          await db.collection('leaderboard').doc(userId).set({
            userId: userId,
            username: username,
            score: score,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp()
          }, { merge: true });
          
          console.log(`✅ Usuario actualizado: ${username} (Puntuación: ${score})`);
          successfulUpdates++;
        } else {
          console.log(`⏭️  Usuario omitido: ${username} (Sin progreso significativo)`);
        }
        
        processedUsers++;
        
        // Pequeña pausa para evitar sobrecargar Firestore
        await new Promise(resolve => setTimeout(resolve, 100));
        
      } catch (e) {
        console.log(`❌ Error procesando usuario ${userDoc.id}: ${e.message}`);
      }
    }
    
    console.log('\n🎉 Proceso completado:');
    console.log(`   📊 Usuarios procesados: ${processedUsers}`);
    console.log(`   ✅ Actualizaciones exitosas: ${successfulUpdates}`);
    console.log(`   ❌ Errores: ${processedUsers - successfulUpdates}`);
    
    // Mostrar top 10 del leaderboard
    console.log('\n🏆 Top 10 del leaderboard:');
    const leaderboardSnapshot = await db
      .collection('leaderboard')
      .orderBy('score', 'desc')
      .limit(10)
      .get();
    
    leaderboardSnapshot.docs.forEach((doc, index) => {
      const data = doc.data();
      const username = data.username || 'Usuario desconocido';
      const score = data.score || 0;
      const medal = index === 0 ? '🥇' : index === 1 ? '🥈' : index === 2 ? '🥉' : '  ';
      console.log(`   ${medal} ${index + 1}. ${username} - ${score} puntos`);
    });
    
  } catch (error) {
    console.error('💥 Error crítico:', error);
    process.exit(1);
  }
  
  console.log('\n✨ Script completado exitosamente');
  process.exit(0);
}

// Ejecutar el script
populateLeaderboard();