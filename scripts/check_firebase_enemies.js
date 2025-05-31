const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkFirebaseEnemies() {
  try {
    console.log('Verificando enemigos en Firebase...');
    
    const enemiesSnapshot = await db.collection('enemies').get();
    
    if (enemiesSnapshot.empty) {
      console.log('No hay enemigos en Firebase.');
      return;
    }
    
    console.log(`\nEnemigos encontrados en Firebase (${enemiesSnapshot.size} total):`);
    enemiesSnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`- ID: ${doc.id}, Nombre: ${data.name || 'Sin nombre'}`);
    });
    
    // Verificar específicamente si existe bug_basico
    const bugBasicoDoc = await db.collection('enemies').doc('bug_basico').get();
    console.log(`\n¿Existe 'bug_basico' en Firebase? ${bugBasicoDoc.exists}`);
    
    // Verificar si existe bug_logico
    const bugLogicoDoc = await db.collection('enemies').doc('bug_logico').get();
    console.log(`¿Existe 'bug_logico' en Firebase? ${bugLogicoDoc.exists}`);
    
    if (bugLogicoDoc.exists) {
      console.log('Datos de bug_logico:', bugLogicoDoc.data());
    }
    
  } catch (error) {
    console.error('Error verificando enemigos:', error);
  }
}

checkFirebaseEnemies().then(() => {
  console.log('\nVerificación completada.');
  process.exit(0);
});