const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkMissionStructure() {
  try {
    console.log('=== VERIFICANDO ESTRUCTURA DE MISIONES ===');
    
    const snapshot = await db.collection('missions').orderBy('order').get();
    
    console.log(`Total misiones: ${snapshot.size}`);
    
    for (const doc of snapshot.docs) {
      const data = doc.data();
      const missionId = doc.id;
      
      console.log(`\n📋 MISIÓN: ${missionId}`);
      console.log(`Tipo: ${data.type}`);
      console.log(`Nombre: ${data.name}`);
      console.log(`Order: ${data.order}`);
      
      // Verificar campos principales
      const mainFields = ['name', 'description', 'type', 'order', 'objectives', 'rewards'];
      console.log('\n🔍 Campos principales:');
      
      mainFields.forEach(field => {
        const exists = data.hasOwnProperty(field);
        const value = data[field];
        const type = Array.isArray(value) ? 'array' : typeof value;
        const length = Array.isArray(value) ? value.length : 'N/A';
        
        console.log(`  ${field}: ${exists ? '✅' : '❌'} (${type}${length !== 'N/A' ? `, length: ${length}` : ''})`);
        
        if (exists && Array.isArray(value) && value.length > 0) {
          console.log(`    Primer elemento:`, JSON.stringify(value[0], null, 4));
        }
      });
      
      // Verificar campos opcionales
      const optionalFields = ['levelRequired', 'requirements', 'unlocks', 'storyPages', 'examples'];
      console.log('\n🔍 Campos opcionales:');
      
      optionalFields.forEach(field => {
        const exists = data.hasOwnProperty(field);
        if (exists) {
          const value = data[field];
          const type = Array.isArray(value) ? 'array' : typeof value;
          console.log(`  ${field}: ✅ (${type})`);
        } else {
          console.log(`  ${field}: ❌`);
        }
      });
      
      // Para misiones de batalla, verificar battleConfig
      if (data.type === 'batalla') {
        console.log('\n⚔️ Análisis específico de batalla:');
        
        if (data.objectives && Array.isArray(data.objectives)) {
          data.objectives.forEach((obj, index) => {
            console.log(`  Objetivo ${index + 1}:`);
            console.log(`    Tipo: ${obj.type}`);
            console.log(`    BattleConfig presente: ${obj.battleConfig ? '✅' : '❌'}`);
            
            if (obj.battleConfig) {
              console.log(`    BattleConfig:`, JSON.stringify(obj.battleConfig, null, 6));
            }
          });
        }
      }
      
      console.log('\n' + '='.repeat(50));
    }
    
  } catch (error) {
    console.error('Error verificando estructura:', error);
  }
}

checkMissionStructure().then(() => {
  console.log('\nVerificación de estructura completada.');
  process.exit(0);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});