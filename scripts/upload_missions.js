const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Cargar la clave de servicio
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadMissions() {
  try {
    console.log('=== SUBIENDO MISIONES A FIRESTORE ===\n');
    
    // Leer el archivo de misiones
    const missionsPath = path.join(__dirname, '../assets/data/missions_data.json');
    const missionsData = JSON.parse(fs.readFileSync(missionsPath, 'utf8'));
    
    console.log(`Encontradas ${missionsData.length} misiones para subir...\n`);
    
    // Subir cada misión
    for (let i = 0; i < missionsData.length; i++) {
      const mission = missionsData[i];
      const missionId = mission.missionId || mission.id;
      
      console.log(`${i + 1}. Subiendo misión: ${mission.name || mission.title} (${missionId})`);
      
      try {
        await db.collection('missions').doc(missionId).set(mission);
        console.log(`   ✅ Misión ${missionId} subida exitosamente`);
      } catch (error) {
        console.log(`   ❌ Error subiendo misión ${missionId}:`, error.message);
      }
    }
    
    console.log('\n=== VERIFICANDO MISIONES EN FIRESTORE ===\n');
    
    // Verificar que se subieron correctamente
    const snapshot = await db.collection('missions').get();
    console.log(`Total de misiones en Firestore: ${snapshot.size}`);
    
    snapshot.forEach(doc => {
      const data = doc.data();
      console.log(`- ${doc.id}: ${data.name || data.title}`);
    });
    
    console.log('\n✅ Proceso completado exitosamente');
    
  } catch (error) {
    console.error('❌ Error durante el proceso:', error);
  } finally {
    process.exit(0);
  }
}

// Ejecutar la función
uploadMissions();