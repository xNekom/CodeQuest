const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function debugMissionLoading() {
  try {
    console.log('=== DEPURACIÓN DE CARGA DE MISIONES ===\n');
    
    // Verificar todas las misiones
    const missionsSnapshot = await db.collection('missions').get();
    console.log(`Total de misiones en Firebase: ${missionsSnapshot.size}\n`);
    
    missionsSnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`Misión: ${doc.id}`);
      console.log(`  - Nombre: ${data.name}`);
      console.log(`  - Tipo: ${data.type}`);
      
      if (data.battleConfig) {
        console.log(`  - BattleConfig presente:`);
        console.log(`    * enemyId: ${data.battleConfig.enemyId}`);
        console.log(`    * enemyIds: ${data.battleConfig.enemyIds}`);
        console.log(`    * questionIds: ${data.battleConfig.questionIds}`);
      }
      
      if (data.objectives) {
        console.log(`  - Objectives:`);
        console.log(`    * type: ${data.objectives.type}`);
        console.log(`    * enemyId: ${data.objectives.enemyId}`);
        console.log(`    * battleConfig: ${JSON.stringify(data.objectives.battleConfig)}`);
      }
      
      console.log('---');
    });
    
    console.log('\n=== VERIFICACIÓN ESPECÍFICA DE MISIONES DE BATALLA ===');
    
    const battleMissions = ['mision_batalla_1', 'mision_batalla_2'];
    
    for (const missionId of battleMissions) {
      console.log(`\n${missionId}:`);
      const doc = await db.collection('missions').doc(missionId).get();
      
      if (doc.exists) {
        const data = doc.data();
        console.log('Datos completos:', JSON.stringify(data, null, 2));
      } else {
        console.log('❌ No encontrada');
      }
    }
    
  } catch (error) {
    console.error('Error en depuración:', error);
  }
}

debugMissionLoading().then(() => {
  console.log('\nDepuración completada.');
  process.exit(0);
});