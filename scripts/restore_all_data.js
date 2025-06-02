const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Inicializar Firebase Admin
const serviceAccount = require('../assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadData(collectionName, dataFile) {
  try {
    console.log(`Subiendo datos a la colección: ${collectionName}`);
    const data = JSON.parse(fs.readFileSync(path.join(__dirname, '../assets/data', dataFile), 'utf8'));
    
    const batch = db.batch();
    let count = 0;
    
    for (const item of data) {
      const docRef = db.collection(collectionName).doc();
      batch.set(docRef, item);
      count++;
    }
    
    await batch.commit();
    console.log(`✅ ${count} documentos subidos a ${collectionName}`);
  } catch (error) {
    console.error(`❌ Error subiendo ${collectionName}:`, error.message);
  }
}

async function restoreAllData() {
  console.log('🔄 Iniciando restauración de datos del sistema...');
  
  // Restaurar datos del sistema (no usuarios)
  await uploadData('achievements', 'achievements_data.json');
  await uploadData('enemies', 'enemies_data.json');
  await uploadData('items', 'items_data.json');
  await uploadData('questions', 'questions.json');
  await uploadData('rewards', 'rewards_data.json');
  
  console.log('\n✅ Restauración completada');
  console.log('📝 Nota: Los usuarios tendrán que registrarse nuevamente');
  console.log('📝 Las misiones y ejercicios de código ya fueron restaurados previamente');
  
  process.exit(0);
}

restoreAllData().catch(console.error);