const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Inicializar Firebase Admin
let serviceAccount;
try {
  // Intentar cargar desde assets/data primero
  serviceAccount = require('../assets/data/serviceAccountKey.json');
} catch (error) {
  console.log('⚠️  serviceAccountKey.json no encontrado en assets/data');
  console.log('📝 Por favor, coloca el archivo serviceAccountKey.json en assets/data/');
  console.log('🔗 Puedes descargarlo desde Firebase Console > Project Settings > Service Accounts');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Función para descargar y guardar una colección
async function backupCollection(collectionName, fileName) {
  try {
    console.log(`Descargando colección: ${collectionName}`);
    const snapshot = await db.collection(collectionName).get();
    
    const data = [];
    snapshot.forEach(doc => {
      data.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    const filePath = path.join(__dirname, '..', 'assets', 'data', fileName);
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
    console.log(`✅ Guardado: ${fileName} (${data.length} documentos)`);
    
    return data.length;
  } catch (error) {
    console.error(`❌ Error al descargar ${collectionName}:`, error);
    return 0;
  }
}

// Función principal
async function backupAllData() {
  console.log('🔄 Iniciando backup de datos de Firebase...');
  
  const collections = [
    { name: 'missions', file: 'missions_data.json' },
    { name: 'questions', file: 'questions.json' },
    { name: 'achievements', file: 'achievements_data.json' },
    { name: 'enemies', file: 'enemies_data.json' },
    { name: 'items', file: 'items_data.json' },
    { name: 'rewards', file: 'rewards_data.json' },
    { name: 'code_exercises', file: 'code_exercises.json' },
    { name: 'users', file: 'users_data.json' },
    { name: 'leaderboard', file: 'leaderboard_data.json' },
    { name: 'user_progress', file: 'user_progress_data.json' },
    { name: 'battle_results', file: 'battle_results_data.json' }
  ];
  
  let totalDocuments = 0;
  
  for (const collection of collections) {
    const count = await backupCollection(collection.name, collection.file);
    totalDocuments += count;
  }
  
  console.log(`\n🎉 Backup completado!`);
  console.log(`📊 Total de documentos descargados: ${totalDocuments}`);
  console.log(`📁 Archivos guardados en: assets/data/`);
  
  process.exit(0);
}

// Ejecutar el backup
backupAllData().catch(error => {
  console.error('❌ Error durante el backup:', error);
  process.exit(1);
});