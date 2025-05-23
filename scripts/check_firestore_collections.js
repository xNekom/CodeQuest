const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkFirestoreCollections() {
  try {
    console.log('🔍 Verificando colecciones en Firestore...');
    
    // Get all collections
    const collections = await db.listCollections();
    
    console.log('\n📋 Colecciones encontradas:');
    collections.forEach(collection => {
      console.log(`  - ${collection.id}`);
    });
    
    console.log('\n📊 Detalles de cada colección:');
    
    for (const collection of collections) {
      const snapshot = await collection.limit(5).get();
      console.log(`\n🗂️  Colección: ${collection.id}`);
      console.log(`   Documentos encontrados: ${snapshot.size}`);
      
      if (!snapshot.empty) {
        console.log('   Primeros documentos:');
        snapshot.forEach(doc => {
          console.log(`     - ID: ${doc.id}`);
          console.log(`       Datos: ${JSON.stringify(doc.data(), null, 2)}`);
        });
      } else {
        console.log('   ⚠️  Colección vacía');
      }
    }
    
    // Check specifically for leaderboard collections
    console.log('\n🎯 Verificando colecciones de leaderboard específicamente:');
    
    const leaderboardVariants = ['leaderboard', 'leaderboards', 'ranking', 'rankings'];
    
    for (const variant of leaderboardVariants) {
      try {
        const snapshot = await db.collection(variant).limit(1).get();
        if (!snapshot.empty) {
          console.log(`✅ Encontrada: ${variant} (${snapshot.size} documentos)`);
        } else {
          console.log(`❌ Vacía: ${variant}`);
        }
      } catch (error) {
        console.log(`❌ No existe: ${variant}`);
      }
    }
    
  } catch (error) {
    console.error('❌ Error verificando colecciones:', error);
  } finally {
    process.exit(0);
  }
}

checkFirestoreCollections();