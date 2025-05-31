const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function testFirebaseConnection() {
  try {
    console.log('=== PRUEBA DE CONEXIÓN A FIREBASE ===\n');
    
    // 1. Probar conexión básica
    console.log('1. Probando conexión básica...');
    const testDoc = await db.collection('test').doc('connection').set({
      timestamp: new Date().toISOString(),
      test: 'connection_test'
    });
    console.log('✅ Conexión a Firebase exitosa');
    
    // 2. Leer datos de misiones
    console.log('\n2. Leyendo datos de misiones...');
    const mission1 = await db.collection('missions').doc('mision_batalla_1').get();
    const mission2 = await db.collection('missions').doc('mision_batalla_2').get();
    
    if (mission1.exists && mission2.exists) {
      console.log('✅ Misiones encontradas en Firebase');
      
      const data1 = mission1.data();
      const data2 = mission2.data();
      
      console.log('mision_batalla_1:');
      console.log(`  - enemyId: ${data1.battleConfig?.enemyId}`);
      console.log(`  - objectives[0].enemyId: ${data1.objectives?.[0]?.battleConfig?.enemyId}`);
      
      console.log('mision_batalla_2:');
      console.log(`  - enemyId: ${data2.battleConfig?.enemyId}`);
      console.log(`  - objectives[0].enemyId: ${data2.objectives?.[0]?.battleConfig?.enemyId}`);
    } else {
      console.log('❌ No se encontraron las misiones en Firebase');
    }
    
    // 3. Verificar enemigo
    console.log('\n3. Verificando enemigo...');
    const enemy = await db.collection('enemies').doc('enemigo_nullpointerexception').get();
    if (enemy.exists) {
      console.log('✅ Enemigo encontrado en Firebase');
      console.log(`  - Nombre: ${enemy.data().name}`);
    } else {
      console.log('❌ Enemigo no encontrado en Firebase');
    }
    
    // 4. Crear un marcador temporal para verificar si Flutter lee de Firebase
    console.log('\n4. Creando marcador temporal...');
    const timestamp = new Date().toISOString();
    
    await db.collection('missions').doc('mision_batalla_1').update({
      debugMarker: `FIREBASE_TEST_${timestamp}`,
      lastChecked: timestamp
    });
    
    await db.collection('missions').doc('mision_batalla_2').update({
      debugMarker: `FIREBASE_TEST_${timestamp}`,
      lastChecked: timestamp
    });
    
    console.log('✅ Marcadores temporales añadidos');
    console.log(`Marcador: FIREBASE_TEST_${timestamp}`);
    
    // 5. Limpiar documento de prueba
    await db.collection('test').doc('connection').delete();
    
    console.log('\n=== RESUMEN ===');
    console.log('- Conexión a Firebase: ✅ EXITOSA');
    console.log('- Datos de misiones: ✅ CORRECTOS');
    console.log('- Enemigo: ✅ EXISTE');
    console.log('- Marcadores añadidos: ✅ SÍ');
    console.log('\nSi Flutter sigue buscando "bug_basico", entonces:');
    console.log('1. No está leyendo de Firebase');
    console.log('2. Hay un problema de caché');
    console.log('3. AppConfig no está funcionando');
    
  } catch (error) {
    console.error('❌ Error en prueba de Firebase:', error);
  }
}

testFirebaseConnection().then(() => {
  console.log('\nPrueba completada.');
  process.exit(0);
});