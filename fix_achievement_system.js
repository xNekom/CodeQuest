const admin = require('firebase-admin');
const fs = require('fs');

// Inicializar Firebase Admin
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixAchievementSystem() {
  try {
    console.log('🔧 Corrigiendo sistema de logros...');
    
    // Paso 1: Corregir los logros de batalla para que funcionen con el sistema actual
    console.log('\n📝 Paso 1: Actualizando logros de batalla...');
    
    const battleAchievements = [
      {
        id: 'batalla_primera_victoria',
        updates: {
          achievementType: 'mission', // Cambiar a mission para que funcione con el código actual
          requiredMissionIds: [], // Se activará en cualquier misión de batalla
          conditions: {
            battleType: 'any', // Cualquier batalla
            victoriesRequired: 1
          }
        }
      },
      {
        id: 'batalla_final_conquistador',
        updates: {
          achievementType: 'mission', // Mantener como mission
          // requiredMissionIds ya está configurado correctamente
        }
      }
    ];
    
    for (const achievement of battleAchievements) {
      await db.collection('achievements').doc(achievement.id).update(achievement.updates);
      console.log(`✅ Actualizado logro: ${achievement.id}`);
    }
    
    // Paso 2: Crear un método especial para verificar logros de batalla
    console.log('\n📝 Paso 2: Verificando si hay usuarios que deberían tener logros...');
    
    // Obtener usuarios que han completado misiones
    const usersSnapshot = await db.collection('users').get();
    
    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const userId = userDoc.id;
      const completedMissions = userData.completedMissions || [];
      const unlockedAchievements = userData.unlockedAchievements || [];
      
      console.log(`\n👤 Revisando usuario: ${userData.email || userId}`);
      console.log(`   Misiones completadas: ${completedMissions.length}`);
      console.log(`   Logros actuales: ${unlockedAchievements.length}`);
      
      // Verificar si debería tener el logro de "Primera Victoria"
      if (completedMissions.length > 0 && !unlockedAchievements.includes('batalla_primera_victoria')) {
        // Verificar si alguna misión completada es de batalla
        let hasBattleMission = false;
        
        for (const missionId of completedMissions) {
          try {
            const missionDoc = await db.collection('missions').doc(missionId).get();
            if (missionDoc.exists) {
              const missionData = missionDoc.data();
              const objectives = missionData.objectives || [];
              const isBattleMission = objectives.some(obj => obj.type === 'batalla');
              
              if (isBattleMission) {
                hasBattleMission = true;
                break;
              }
            }
          } catch (e) {
            console.log(`   ⚠️ Error al verificar misión ${missionId}: ${e.message}`);
          }
        }
        
        if (hasBattleMission) {
          console.log(`   🏆 Otorgando logro "Primera Victoria"`);
          await db.collection('users').doc(userId).update({
            unlockedAchievements: admin.firestore.FieldValue.arrayUnion('batalla_primera_victoria')
          });
          
          // También crear en la subcolección
          await db.collection('user_achievements').doc(userId).collection('achievements').doc('batalla_primera_victoria').set({
            achievementId: 'batalla_primera_victoria',
            name: 'Primera Victoria',
            description: 'Completa tu primera batalla contra un enemigo.',
            iconUrl: 'assets/images/badge_primer_bug.svg',
            unlockedDate: admin.firestore.FieldValue.serverTimestamp(),
            category: 'battle',
            points: 50,
          });
        }
      }
      
      // Verificar logro de batalla final
      if (completedMissions.includes('mision_batalla_final') && !unlockedAchievements.includes('batalla_final_conquistador')) {
        console.log(`   🏆 Otorgando logro "Conquistador Supremo"`);
        await db.collection('users').doc(userId).update({
          unlockedAchievements: admin.firestore.FieldValue.arrayUnion('batalla_final_conquistador')
        });
        
        // También crear en la subcolección
        await db.collection('user_achievements').doc(userId).collection('achievements').doc('batalla_final_conquistador').set({
          achievementId: 'batalla_final_conquistador',
          name: 'Conquistador Supremo',
          description: 'Derrota al Bug Supremo en la Batalla Final.',
          iconUrl: 'assets/images/badge_bug_supremo.svg',
          unlockedDate: admin.firestore.FieldValue.serverTimestamp(),
          category: 'battle',
          points: 100,
        });
      }
    }
    
    console.log('\n✅ Sistema de logros corregido exitosamente!');
    console.log('\n📋 Resumen de cambios:');
    console.log('   - Logros de batalla ahora usan achievementType="mission"');
    console.log('   - Usuarios existentes han recibido logros retroactivamente');
    console.log('   - Sistema debería funcionar correctamente ahora');
    
  } catch (error) {
    console.error('❌ Error durante la corrección:', error);
  } finally {
    process.exit(0);
  }
}

// Ejecutar el script
fixAchievementSystem();