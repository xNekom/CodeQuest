const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function debugAndFixFinal() {
  try {
    console.log('=== DIAGNÓSTICO FINAL Y CORRECCIÓN ===\n');
    
    // 1. Verificar todas las misiones en Firebase
    console.log('1. Verificando TODAS las misiones en Firebase...');
    const missionsSnapshot = await db.collection('missions').get();
    
    console.log(`Total de misiones en Firebase: ${missionsSnapshot.size}`);
    
    missionsSnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`\nMisión: ${doc.id}`);
      
      if (data.objectives && Array.isArray(data.objectives)) {
        data.objectives.forEach((objective, index) => {
          if (objective.battleConfig) {
            console.log(`  Objetivo ${index + 1}:`);
            console.log(`    - enemyId: ${objective.battleConfig.enemyId}`);
            console.log(`    - enemyIds: ${JSON.stringify(objective.battleConfig.enemyIds)}`);
          }
        });
      }
      
      if (data.battleConfig) {
        console.log(`  BattleConfig principal:`);
        console.log(`    - enemyId: ${data.battleConfig.enemyId}`);
        console.log(`    - enemyIds: ${JSON.stringify(data.battleConfig.enemyIds)}`);
      }
    });
    
    // 2. Buscar cualquier referencia a "bug_basico"
    console.log('\n2. Buscando referencias a "bug_basico"...');
    let foundBugBasico = false;
    
    missionsSnapshot.forEach(doc => {
      const data = doc.data();
      const dataStr = JSON.stringify(data);
      if (dataStr.includes('bug_basico')) {
        console.log(`❌ ENCONTRADO "bug_basico" en misión: ${doc.id}`);
        console.log(`   Datos: ${dataStr}`);
        foundBugBasico = true;
      }
    });
    
    if (!foundBugBasico) {
      console.log('✅ No se encontraron referencias a "bug_basico" en Firebase');
    }
    
    // 3. Verificar enemigos disponibles
    console.log('\n3. Verificando enemigos disponibles...');
    const enemiesSnapshot = await db.collection('enemies').get();
    console.log(`Total de enemigos: ${enemiesSnapshot.size}`);
    
    enemiesSnapshot.forEach(doc => {
      console.log(`  - ${doc.id}: ${doc.data().name}`);
    });
    
    // 4. Limpiar y corregir datos si es necesario
    console.log('\n4. Limpiando y corrigiendo datos...');
    
    const battleMissions = ['mision_batalla_1', 'mision_batalla_2'];
    
    for (const missionId of battleMissions) {
      const docRef = db.collection('missions').doc(missionId);
      const doc = await docRef.get();
      
      if (doc.exists) {
        const data = doc.data();
        let needsUpdate = false;
        const updates = {};
        
        // Limpiar battleConfig principal
        if (data.battleConfig) {
          if (data.battleConfig.enemyId !== 'enemigo_nullpointerexception') {
            updates['battleConfig.enemyId'] = 'enemigo_nullpointerexception';
            needsUpdate = true;
          }
          if (data.battleConfig.enemyIds) {
            updates['battleConfig.enemyIds'] = admin.firestore.FieldValue.delete();
            needsUpdate = true;
          }
        }
        
        // Limpiar objectives
        if (data.objectives && Array.isArray(data.objectives)) {
          data.objectives.forEach((objective, index) => {
            if (objective.battleConfig) {
              if (objective.battleConfig.enemyId !== 'enemigo_nullpointerexception') {
                updates[`objectives.${index}.battleConfig.enemyId`] = 'enemigo_nullpointerexception';
                needsUpdate = true;
              }
              if (objective.battleConfig.enemyIds) {
                updates[`objectives.${index}.battleConfig.enemyIds`] = admin.firestore.FieldValue.delete();
                needsUpdate = true;
              }
            }
          });
        }
        
        if (needsUpdate) {
          await docRef.update(updates);
          console.log(`✅ ${missionId} actualizada`);
        } else {
          console.log(`✅ ${missionId} ya está correcta`);
        }
      }
    }
    
    // 5. Verificación final
    console.log('\n5. Verificación final...');
    for (const missionId of battleMissions) {
      const doc = await db.collection('missions').doc(missionId).get();
      if (doc.exists) {
        const data = doc.data();
        console.log(`${missionId}:`);
        console.log(`  - battleConfig.enemyId: ${data.battleConfig?.enemyId}`);
        if (data.objectives && data.objectives[0] && data.objectives[0].battleConfig) {
          console.log(`  - objectives[0].battleConfig.enemyId: ${data.objectives[0].battleConfig.enemyId}`);
        }
      }
    }
    
    console.log('\n=== CORRECCIÓN COMPLETADA ===');
    console.log('Todos los datos en Firebase están ahora correctos.');
    console.log('Reinicia la aplicación Flutter para ver los cambios.');
    
  } catch (error) {
    console.error('Error en diagnóstico:', error);
  }
}

debugAndFixFinal().then(() => {
  console.log('\nDiagnóstico completado.');
  process.exit(0);
});