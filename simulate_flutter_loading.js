const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Simular exactamente lo que hace MissionService.getMissions()
async function simulateFlutterLoading() {
  try {
    console.log('=== SIMULANDO CARGA DE MISIONES COMO EN FLUTTER ===');
    
    // Obtener misiones ordenadas por 'order' como en Flutter
    const snapshot = await db.collection('missions').orderBy('order').get();
    
    console.log(`Total documentos en snapshot: ${snapshot.size}`);
    
    if (snapshot.docs.length === 0) {
      console.log('No hay documentos en el snapshot.');
      return;
    }
    
    const missions = [];
    const parseErrors = [];
    
    // Simular el parsing como en Flutter
    for (const doc of snapshot.docs) {
      try {
        const data = doc.data();
        console.log(`\n--- Parseando misión: ${doc.id} ---`);
        console.log(`Tipo: ${data.type}`);
        console.log(`Nombre: ${data.name}`);
        console.log(`Order: ${data.order}`);
        
        // Verificar campos requeridos
        const requiredFields = ['name', 'description', 'zone', 'levelRequired', 'objectives', 'rewards'];
        const missingFields = [];
        
        for (const field of requiredFields) {
          if (!data[field]) {
            missingFields.push(field);
          }
        }
        
        if (missingFields.length > 0) {
          console.log(`❌ Campos faltantes: ${missingFields.join(', ')}`);
          parseErrors.push({
            id: doc.id,
            error: `Missing fields: ${missingFields.join(', ')}`,
            data: data
          });
          continue;
        }
        
        // Verificar objetivos
        if (!Array.isArray(data.objectives) || data.objectives.length === 0) {
          console.log(`❌ Objetivos inválidos o vacíos`);
          parseErrors.push({
            id: doc.id,
            error: 'Invalid or empty objectives',
            data: data
          });
          continue;
        }
        
        // Verificar cada objetivo
        let objectiveErrors = [];
        for (let i = 0; i < data.objectives.length; i++) {
          const obj = data.objectives[i];
          if (!obj.type || !obj.description) {
            objectiveErrors.push(`Objetivo ${i + 1}: falta type o description`);
          }
        }
        
        if (objectiveErrors.length > 0) {
          console.log(`❌ Errores en objetivos: ${objectiveErrors.join(', ')}`);
          parseErrors.push({
            id: doc.id,
            error: `Objective errors: ${objectiveErrors.join(', ')}`,
            data: data
          });
          continue;
        }
        
        // Verificar rewards
        if (!data.rewards || typeof data.rewards !== 'object') {
          console.log(`❌ Rewards inválidos`);
          parseErrors.push({
            id: doc.id,
            error: 'Invalid rewards',
            data: data
          });
          continue;
        }
        
        console.log(`✅ Misión parseada correctamente`);
        missions.push({
          id: doc.id,
          name: data.name,
          type: data.type,
          order: data.order
        });
        
      } catch (error) {
        console.log(`❌ Error parseando ${doc.id}: ${error.message}`);
        parseErrors.push({
          id: doc.id,
          error: error.message,
          data: doc.data()
        });
      }
    }
    
    console.log(`\n=== RESUMEN ===`);
    console.log(`Misiones parseadas exitosamente: ${missions.length}`);
    console.log(`Errores de parsing: ${parseErrors.length}`);
    
    console.log(`\n=== MISIONES EXITOSAS ===`);
    missions.forEach(mission => {
      console.log(`- ${mission.id} (${mission.type}) - Order: ${mission.order}`);
    });
    
    if (parseErrors.length > 0) {
      console.log(`\n=== ERRORES DE PARSING ===`);
      parseErrors.forEach(error => {
        console.log(`\n❌ ${error.id}:`);
        console.log(`   Error: ${error.error}`);
        console.log(`   Datos:`, JSON.stringify(error.data, null, 2));
      });
    }
    
  } catch (error) {
    console.error('Error en simulación:', error);
  }
}

simulateFlutterLoading().then(() => {
  console.log('\nSimulación completada.');
  process.exit(0);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});