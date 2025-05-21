const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function debugBattleMissions() {
  try {
    console.log('=== DEBUGGING MISIONES DE BATALLA ===');
    
    // Obtener todas las misiones ordenadas por 'order'
    const snapshot = await db.collection('missions').orderBy('order').get();
    
    if (snapshot.empty) {
      console.log('No se encontraron misiones en Firebase.');
      return;
    }
    
    console.log(`Total misiones encontradas: ${snapshot.size}`);
    console.log('\n=== ORDEN DE MISIONES ===');
    
    snapshot.docs.forEach((doc, index) => {
      const data = doc.data();
      console.log(`${index + 1}. ID: ${doc.id}`);
      console.log(`   Nombre: ${data.name || 'N/A'}`);
      console.log(`   Tipo: ${data.type || 'N/A'}`);
      console.log(`   Order: ${data.order}`);
      console.log(`   Level Required: ${data.levelRequired || 'N/A'}`);
      console.log(`   Status: ${data.status || 'N/A'}`);
      
      // Verificar si tiene battleConfig para misiones de batalla
      if (data.type === 'batalla') {
        console.log(`   BattleConfig: ${data.battleConfig ? 'SÍ' : 'NO'}`);
        if (data.battleConfig) {
          console.log(`   Enemies: ${data.battleConfig.enemies ? data.battleConfig.enemies.length : 0}`);
        }
      }
      
      // Verificar objetivos
      console.log(`   Objetivos: ${data.objectives ? data.objectives.length : 0}`);
      if (data.objectives && data.objectives.length > 0) {
        data.objectives.forEach((obj, objIndex) => {
          console.log(`     ${objIndex + 1}. Tipo: ${obj.type || 'N/A'}`);
        });
      }
      
      console.log('---');
    });
    
    // Verificar específicamente las misiones de batalla
    const battleMissions = snapshot.docs.filter(doc => doc.data().type === 'batalla');
    console.log(`\n=== ANÁLISIS ESPECÍFICO DE MISIONES DE BATALLA ===`);
    console.log(`Total misiones de batalla: ${battleMissions.length}`);
    
    battleMissions.forEach(doc => {
      const data = doc.data();
      console.log(`\nMisión: ${doc.id}`);
      console.log(`  Datos completos:`);
      console.log(JSON.stringify(data, null, 2));
    });
    
  } catch (error) {
    console.error('Error debugging misiones de batalla:', error);
  }
}

debugBattleMissions().then(() => {
  console.log('\nDebug completado.');
  process.exit(0);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});