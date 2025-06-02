const admin = require('firebase-admin');
const fs = require('fs');

// Inicializar Firebase Admin
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixBattleAchievementsFinal() {
  try {
    console.log('🔧 Corrigiendo sistema de logros de batalla - Versión Final...');
    
    // Paso 1: Obtener todas las misiones para identificar cuáles son de batalla
    console.log('\n📝 Paso 1: Identificando misiones de batalla...');
    
    const missionsSnapshot = await db.collection('missions').get();
    const battleMissions = [];
    
    for (const missionDoc of missionsSnapshot.docs) {
      const missionData = missionDoc.data();
      const objectives = missionData.objectives || [];
      const isBattleMission = objectives.some(obj => obj.type === 'batalla');
      
      if (isBattleMission) {
        battleMissions.push(missionDoc.id);
        console.log(`   ⚔️ Misión de batalla encontrada: ${missionDoc.id}`);
      }
    }
    
    console.log(`\n📊 Total de misiones de batalla: ${battleMissions.length}`);
    
    // Paso 2: Actualizar el logro "Primera Victoria" para que funcione con cualquier misión de batalla
    console.log('\n📝 Paso 2: Actualizando logro "Primera Victoria"...');
    
    if (battleMissions.length > 0) {
      await db.collection('achievements').doc('batalla_primera_victoria').update({
        achievementType: 'mission',
        requiredMissionIds: battleMissions, // Agregar todas las misiones de batalla
        conditions: {
          battleType: 'any',
          victoriesRequired: 1
        }
      });
      console.log(`✅ Logro "Primera Victoria" actualizado con ${battleMissions.length} misiones de batalla`);
    }
    
    // Paso 3: Verificar usuarios que deberían tener logros
    console.log('\n📝 Paso 3: Otorgando logros retroactivamente...');
    
    const usersSnapshot = await db.collection('users').get();
    
    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const userId = userDoc.id;
      const completedMissions = userData.completedMissions || [];
      const unlockedAchievements = userData.unlockedAchievements || [];
      
      console.log(`\n👤 Usuario: ${userData.email || userId}`);
      console.log(`   Misiones completadas: ${JSON.stringify(completedMissions)}`);
      console.log(`   Logros actuales: ${unlockedAchievements.length}`);
      
      // Verificar logro "Primera Victoria"
      if (!unlockedAchievements.includes('batalla_primera_victoria')) {
        // Verificar si ha completado alguna misión de batalla
        const hasCompletedBattleMission = completedMissions.some(missionId => 
          battleMissions.includes(missionId)
        );
        
        if (hasCompletedBattleMission) {
          console.log(`   🏆 Otorgando "Primera Victoria"`);
          
          // Actualizar array de logros desbloqueados
          await db.collection('users').doc(userId).update({
            unlockedAchievements: admin.firestore.FieldValue.arrayUnion('batalla_primera_victoria')
          });
          
          // Crear documento en subcolección
          await db.collection('user_achievements').doc(userId).collection('achievements').doc('batalla_primera_victoria').set({
            achievementId: 'batalla_primera_victoria',
            name: 'Primera Victoria',
            description: 'Completa tu primera batalla contra un enemigo.',
            iconUrl: 'assets/images/badge_primer_bug.svg',
            unlockedDate: admin.firestore.FieldValue.serverTimestamp(),
            category: 'battle',
            points: 50,
          });
        } else {
          console.log(`   ⏳ No ha completado misiones de batalla aún`);
        }
      } else {
        console.log(`   ✅ Ya tiene "Primera Victoria"`);
      }
      
      // Verificar logro "Conquistador Supremo"
      if (!unlockedAchievements.includes('batalla_final_conquistador')) {
        if (completedMissions.includes('mision_batalla_final')) {
          console.log(`   🏆 Otorgando "Conquistador Supremo"`);
          
          await db.collection('users').doc(userId).update({
            unlockedAchievements: admin.firestore.FieldValue.arrayUnion('batalla_final_conquistador')
          });
          
          await db.collection('user_achievements').doc(userId).collection('achievements').doc('batalla_final_conquistador').set({
            achievementId: 'batalla_final_conquistador',
            name: 'Conquistador Supremo',
            description: 'Derrota al Bug Supremo en la Batalla Final.',
            iconUrl: 'assets/images/badge_bug_supremo.svg',
            unlockedDate: admin.firestore.FieldValue.serverTimestamp(),
            category: 'battle',
            points: 100,
          });
        } else {
          console.log(`   ⏳ No ha completado la batalla final aún`);
        }
      } else {
        console.log(`   ✅ Ya tiene "Conquistador Supremo"`);
      }
    }
    
    // Paso 4: Verificar estado final
    console.log('\n📝 Paso 4: Verificando estado final...');
    
    const finalUsersSnapshot = await db.collection('users').get();
    for (const userDoc of finalUsersSnapshot.docs) {
      const userData = userDoc.data();
      const unlockedAchievements = userData.unlockedAchievements || [];
      console.log(`👤 ${userData.email || userDoc.id}: ${unlockedAchievements.length} logros`);
      if (unlockedAchievements.length > 0) {
        console.log(`   Logros: ${JSON.stringify(unlockedAchievements)}`);
      }
    }
    
    console.log('\n✅ Sistema de logros de batalla corregido exitosamente!');
    console.log('\n📋 Resumen de cambios:');
    console.log(`   - Identificadas ${battleMissions.length} misiones de batalla`);
    console.log('   - Logro "Primera Victoria" configurado para todas las misiones de batalla');
    console.log('   - Logros otorgados retroactivamente a usuarios existentes');
    console.log('   - Sistema debería funcionar correctamente para nuevos usuarios');
    
  } catch (error) {
    console.error('❌ Error durante la corrección:', error);
  } finally {
    process.exit(0);
  }
}

// Ejecutar el script
fixBattleAchievementsFinal();