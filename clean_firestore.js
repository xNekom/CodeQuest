const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Inicializar Firebase Admin
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Función para eliminar todos los documentos de una colección
async function deleteCollection(collectionName) {
  console.log(`🗑️ Eliminando colección: ${collectionName}`);
  
  const collectionRef = db.collection(collectionName);
  const snapshot = await collectionRef.get();
  
  if (snapshot.empty) {
    console.log(`⚠️ La colección ${collectionName} ya está vacía`);
    return;
  }
  
  const batch = db.batch();
  let count = 0;
  
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
    count++;
  });
  
  await batch.commit();
  console.log(`✅ ${count} documentos eliminados de ${collectionName}`);
}

// Función principal
async function cleanFirestore() {
  try {
    console.log('🧹 Iniciando limpieza de Firestore...');
    
    // Lista de colecciones a limpiar
    const collections = [
      'achievements',
      'enemies', 
      'items',
      'questions',
      'rewards',
      'missions',
      'code_exercises'
    ];
    
    // Eliminar cada colección
    for (const collection of collections) {
      await deleteCollection(collection);
    }
    
    console.log('\n✅ Limpieza de Firestore completada');
    console.log('📝 Ahora puedes ejecutar restore_all_data.js para subir los datos actualizados');
    
  } catch (error) {
    console.error('❌ Error durante la limpieza:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

// Ejecutar la limpieza
cleanFirestore();