const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkOrderField() {
  try {
    console.log('=== VERIFICANDO CAMPO ORDER EN MISIONES ===');
    const snapshot = await db.collection('missions').get();
    
    if (snapshot.empty) {
      console.log('No se encontraron misiones en Firebase.');
      return;
    }
    
    snapshot.docs.forEach(doc => {
      const data = doc.data();
      console.log(`ID: ${doc.id}`);
      console.log(`  Nombre: ${data.name || 'N/A'}`);
      console.log(`  Tipo: ${data.type || 'N/A'}`);
      console.log(`  Order: ${data.order !== undefined ? data.order : 'MISSING'}`);
      console.log('---');
    });
    
    // Verificar específicamente las misiones de batalla
    const battleMissions = snapshot.docs.filter(doc => doc.data().type === 'batalla');
    console.log(`\n=== RESUMEN MISIONES DE BATALLA ===`);
    console.log(`Total misiones de batalla: ${battleMissions.length}`);
    
    battleMissions.forEach(doc => {
      const data = doc.data();
      console.log(`- ${doc.id}: order = ${data.order !== undefined ? data.order : 'MISSING'}`);
    });
    
  } catch (error) {
    console.error('Error verificando campo order:', error);
  }
}

checkOrderField().then(() => {
  console.log('\nVerificación completada.');
  process.exit(0);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});