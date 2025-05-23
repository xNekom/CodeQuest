const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Simular el parsing de MissionModel.fromFirestore
function simulateMissionParsing(doc) {
  try {
    const data = doc.data();
    const missionId = doc.id;
    
    console.log(`\n🔍 Parseando misión: ${missionId}`);
    console.log(`Datos raw:`, JSON.stringify(data, null, 2));
    
    // Verificar campos requeridos básicos
    const requiredFields = ['name', 'description', 'type', 'order'];
    const missingFields = [];
    
    for (const field of requiredFields) {
      if (!data.hasOwnProperty(field) || data[field] === null || data[field] === undefined) {
        missingFields.push(field);
      }
    }
    
    if (missingFields.length > 0) {
      console.log(`❌ Campos faltantes: ${missingFields.join(', ')}`);
      return false;
    }
    
    // Verificar estructura de objectives
    if (!data.objectives || !Array.isArray(data.objectives)) {
      console.log(`❌ Campo 'objectives' faltante o no es array`);
      return false;
    }
    
    // Verificar cada objetivo
    for (let i = 0; i < data.objectives.length; i++) {
      const objective = data.objectives[i];
      console.log(`  Objetivo ${i + 1}:`, JSON.stringify(objective, null, 2));
      
      if (!objective.type || !objective.description) {
        console.log(`  ❌ Objetivo ${i + 1} falta 'type' o 'description'`);
        return false;
      }
      
      // Para misiones de batalla, verificar battleConfig
      if (data.type === 'batalla' && objective.battleConfig) {
        console.log(`  ✓ BattleConfig encontrado para objetivo de batalla`);
        
        const battleConfig = objective.battleConfig;
        const requiredBattleFields = ['enemyIds', 'maxEnemies', 'timeLimit', 'difficulty'];
        
        for (const field of requiredBattleFields) {
          if (!battleConfig.hasOwnProperty(field)) {
            console.log(`  ❌ BattleConfig falta campo: ${field}`);
            return false;
          }
        }
      }
    }
    
    // Verificar rewards
    if (!data.rewards || !Array.isArray(data.rewards)) {
      console.log(`❌ Campo 'rewards' faltante o no es array`);
      return false;
    }
    
    console.log(`✅ Misión ${missionId} parseada exitosamente`);
    return true;
    
  } catch (error) {
    console.log(`❌ Error parseando misión ${doc.id}: ${error.message}`);
    console.log(`Stack trace:`, error.stack);
    return false;
  }
}

async function debugMissionService() {
  try {
    console.log('=== DEBUGGING MISSION SERVICE PARSING ===');
    
    // Simular la consulta del MissionService
    const snapshot = await db.collection('missions').orderBy('order').get();
    
    console.log(`Total documentos en consulta: ${snapshot.size}`);
    
    const successfulMissions = [];
    const failedMissions = [];
    
    for (const doc of snapshot.docs) {
      const success = simulateMissionParsing(doc);
      
      if (success) {
        successfulMissions.push({
          id: doc.id,
          type: doc.data().type,
          order: doc.data().order
        });
      } else {
        failedMissions.push({
          id: doc.id,
          type: doc.data().type,
          order: doc.data().order
        });
      }
    }
    
    console.log('\n=== RESUMEN DE PARSING ===');
    console.log(`Misiones parseadas exitosamente: ${successfulMissions.length}`);
    console.log(`Misiones que fallaron: ${failedMissions.length}`);
    
    if (successfulMissions.length > 0) {
      console.log('\n✅ MISIONES EXITOSAS:');
      successfulMissions.forEach(mission => {
        console.log(`  - ${mission.id} (${mission.type}) - Order: ${mission.order}`);
      });
    }
    
    if (failedMissions.length > 0) {
      console.log('\n❌ MISIONES FALLIDAS:');
      failedMissions.forEach(mission => {
        console.log(`  - ${mission.id} (${mission.type}) - Order: ${mission.order}`);
      });
    }
    
    // Análisis por tipo
    console.log('\n=== ANÁLISIS POR TIPO ===');
    const typeAnalysis = {};
    
    successfulMissions.forEach(mission => {
      if (!typeAnalysis[mission.type]) {
        typeAnalysis[mission.type] = { successful: 0, failed: 0 };
      }
      typeAnalysis[mission.type].successful++;
    });
    
    failedMissions.forEach(mission => {
      if (!typeAnalysis[mission.type]) {
        typeAnalysis[mission.type] = { successful: 0, failed: 0 };
      }
      typeAnalysis[mission.type].failed++;
    });
    
    Object.keys(typeAnalysis).forEach(type => {
      const analysis = typeAnalysis[type];
      console.log(`${type}: ${analysis.successful} exitosas, ${analysis.failed} fallidas`);
    });
    
  } catch (error) {
    console.error('Error en debug:', error);
  }
}

debugMissionService().then(() => {
  console.log('\nDebug del MissionService completado.');
  process.exit(0);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});