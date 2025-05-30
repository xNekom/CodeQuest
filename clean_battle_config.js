const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function cleanBattleConfig() {
  try {
    console.log('Limpiando configuración de batalla...');
    
    const battleMissions = ['mision_batalla_1', 'mision_batalla_2'];
    
    for (const missionId of battleMissions) {
      console.log(`\nProcesando ${missionId}...`);
      
      const missionDoc = await db.collection('missions').doc(missionId).get();
      if (!missionDoc.exists) {
        console.log(`❌ Misión ${missionId} no encontrada.`);
        continue;
      }
      
      const missionData = missionDoc.data();
      
      // Limpiar battleConfig
      if (missionData.battleConfig) {
        console.log('Antes:');
        console.log('  - enemyId:', missionData.battleConfig.enemyId);
        console.log('  - enemyIds:', missionData.battleConfig.enemyIds);
        
        // Mantener solo enemyId y eliminar enemyIds
        missionData.battleConfig.enemyId = 'enemigo_nullpointerexception';
        delete missionData.battleConfig.enemyIds;
        
        console.log('Después:');
        console.log('  - enemyId:', missionData.battleConfig.enemyId);
        console.log('  - enemyIds:', missionData.battleConfig.enemyIds);
      }
      
      // Limpiar objectives si tiene battleConfig anidado
      if (missionData.objectives && missionData.objectives.battleConfig) {
        console.log('Limpiando objectives.battleConfig...');
        missionData.objectives.battleConfig.enemyId = 'enemigo_nullpointerexception';
        delete missionData.objectives.battleConfig.enemyIds;
      }
      
      // Asegurar que objectives tenga enemyId
      if (missionData.objectives) {
        missionData.objectives.enemyId = 'enemigo_nullpointerexception';
      }
      
      // Guardar cambios
      await db.collection('missions').doc(missionId).update(missionData);
      console.log(`✅ ${missionId} limpiada y actualizada`);
    }
    
    console.log('\n=== VERIFICACIÓN FINAL ===');
    for (const missionId of battleMissions) {
      const doc = await db.collection('missions').doc(missionId).get();
      if (doc.exists) {
        const data = doc.data();
        console.log(`\n${missionId}:`);
        console.log(`  - battleConfig.enemyId: ${data.battleConfig?.enemyId}`);
        console.log(`  - battleConfig.enemyIds: ${data.battleConfig?.enemyIds}`);
        console.log(`  - objectives.enemyId: ${data.objectives?.enemyId}`);
      }
    }
    
  } catch (error) {
    console.error('Error limpiando configuración:', error);
  }
}

cleanBattleConfig().then(() => {
  console.log('\nLimpieza completada.');
  process.exit(0);
});