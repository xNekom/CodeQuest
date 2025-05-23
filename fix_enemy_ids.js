const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixEnemyIds() {
  try {
    console.log('Corrigiendo IDs de enemigos en misiones de batalla...');
    
    // Obtener las misiones de batalla
    const missions = ['mision_batalla_1', 'mision_batalla_2'];
    
    for (const missionId of missions) {
      console.log(`\nProcesando ${missionId}...`);
      
      const missionDoc = await db.collection('missions').doc(missionId).get();
      if (!missionDoc.exists) {
        console.log(`Misión ${missionId} no encontrada.`);
        continue;
      }
      
      const missionData = missionDoc.data();
      console.log(`Datos actuales de ${missionId}:`);
      console.log('- enemyId en battleConfig:', missionData.battleConfig?.enemyId);
      console.log('- enemyId en objectives:', missionData.objectives?.enemyId);
      
      // Usar un enemigo que sabemos que existe en Firebase
      const newEnemyId = 'enemigo_nullpointerexception';
      
      // Actualizar battleConfig
      if (missionData.battleConfig) {
        missionData.battleConfig.enemyId = newEnemyId;
      }
      
      // Actualizar objectives
      if (missionData.objectives) {
        missionData.objectives.enemyId = newEnemyId;
      }
      
      // Guardar los cambios
      await db.collection('missions').doc(missionId).update(missionData);
      console.log(`✅ ${missionId} actualizada con enemyId: ${newEnemyId}`);
    }
    
    console.log('\n=== Verificación de cambios ===');
    for (const missionId of missions) {
      const missionDoc = await db.collection('missions').doc(missionId).get();
      if (missionDoc.exists) {
        const data = missionDoc.data();
        console.log(`${missionId}:`);
        console.log(`  - battleConfig.enemyId: ${data.battleConfig?.enemyId}`);
        console.log(`  - objectives.enemyId: ${data.objectives?.enemyId}`);
      }
    }
    
  } catch (error) {
    console.error('Error corrigiendo IDs de enemigos:', error);
  }
}

fixEnemyIds().then(() => {
  console.log('\nCorreción completada.');
  process.exit(0);
});