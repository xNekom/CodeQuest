const admin = require('firebase-admin');
const fs = require('fs');

// Inicializar Firebase Admin
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function debugUserMissions() {
  try {
    console.log('🔍 Analizando misiones del usuario en detalle...');
    
    // Obtener usuario
    const usersSnapshot = await db.collection('users').get();
    const userDoc = usersSnapshot.docs[0]; // Primer usuario
    const userData = userDoc.data();
    const userId = userDoc.id;
    
    console.log(`\n👤 Usuario: ${userData.email || userId}`);
    console.log(`Misiones completadas: ${JSON.stringify(userData.completedMissions || [])}`);
    
    // Analizar cada misión completada
    const completedMissions = userData.completedMissions || [];
    
    for (const missionId of completedMissions) {
      console.log(`\n📋 Analizando misión: ${missionId}`);
      
      try {
        const missionDoc = await db.collection('missions').doc(missionId).get();
        
        if (missionDoc.exists) {
          const missionData = missionDoc.data();
          console.log(`   Título: ${missionData.title || 'Sin título'}`);
          console.log(`   Objetivos: ${JSON.stringify(missionData.objectives || [])}`);
          
          const objectives = missionData.objectives || [];
          const hasBattle = objectives.some(obj => obj.type === 'batalla');
          console.log(`   ⚔️ Contiene batalla: ${hasBattle}`);
          
          if (hasBattle) {
            console.log(`   🎯 Esta misión debería activar el logro "Primera Victoria"`);
          }
        } else {
          console.log(`   ❌ Misión no encontrada en Firestore`);
        }
      } catch (error) {
        console.log(`   ❌ Error al obtener misión: ${error.message}`);
      }
    }
    
    // Verificar todas las misiones disponibles
    console.log('\n📚 Todas las misiones disponibles:');
    const allMissionsSnapshot = await db.collection('missions').get();
    
    for (const missionDoc of allMissionsSnapshot.docs) {
      const missionData = missionDoc.data();
      const objectives = missionData.objectives || [];
      const hasBattle = objectives.some(obj => obj.type === 'batalla');
      
      console.log(`   ${missionDoc.id}: ${missionData.title || 'Sin título'} - Batalla: ${hasBattle}`);
    }
    
    // Verificar logros actuales
    console.log('\n🏆 Estado actual de logros:');
    const achievementsSnapshot = await db.collection('achievements').get();
    
    for (const achievementDoc of achievementsSnapshot.docs) {
      const achievementData = achievementDoc.data();
      if (achievementData.category === 'battle') {
        console.log(`   ${achievementDoc.id}: ${achievementData.name}`);
        console.log(`     Tipo: ${achievementData.achievementType}`);
        console.log(`     Misiones requeridas: ${JSON.stringify(achievementData.requiredMissionIds || [])}`);
      }
    }
    
    // Simular verificación de logros
    console.log('\n🧪 Simulando verificación de logros...');
    
    // Verificar si alguna misión completada está en las requiredMissionIds del logro "Primera Victoria"
    const primeraVictoriaDoc = await db.collection('achievements').doc('batalla_primera_victoria').get();
    if (primeraVictoriaDoc.exists) {
      const primeraVictoriaData = primeraVictoriaDoc.data();
      const requiredMissions = primeraVictoriaData.requiredMissionIds || [];
      
      console.log(`Logro "Primera Victoria" requiere misiones: ${JSON.stringify(requiredMissions)}`);
      console.log(`Usuario completó misiones: ${JSON.stringify(completedMissions)}`);
      
      const intersection = completedMissions.filter(mission => requiredMissions.includes(mission));
      console.log(`Misiones en común: ${JSON.stringify(intersection)}`);
      
      if (intersection.length > 0) {
        console.log(`✅ El usuario DEBERÍA tener el logro "Primera Victoria"`);
        
        // Otorgar logro manualmente
        console.log(`🔧 Otorgando logro manualmente...`);
        
        await db.collection('users').doc(userId).update({
          unlockedAchievements: admin.firestore.FieldValue.arrayUnion('batalla_primera_victoria')
        });
        
        await db.collection('user_achievements').doc(userId).collection('achievements').doc('batalla_primera_victoria').set({
          achievementId: 'batalla_primera_victoria',
          name: 'Primera Victoria',
          description: 'Completa tu primera batalla contra un enemigo.',
          iconUrl: 'assets/images/badge_primer_bug.svg',
          unlockedDate: admin.firestore.FieldValue.serverTimestamp(),
          category: 'battle',
          points: 50,
        });
        
        console.log(`✅ Logro "Primera Victoria" otorgado manualmente`);
      } else {
        console.log(`❌ El usuario NO debería tener el logro "Primera Victoria" aún`);
      }
    }
    
  } catch (error) {
    console.error('❌ Error durante el análisis:', error);
  } finally {
    process.exit(0);
  }
}

// Ejecutar el script
debugUserMissions();