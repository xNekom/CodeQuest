const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function forceHotReload() {
  try {
    console.log('=== FORZANDO ACTUALIZACIÓN DE DATOS ===\n');
    
    // 1. Verificar configuración actual
    console.log('1. Verificando configuración de AppConfig...');
    const fs = require('fs');
    const appConfigPath = './lib/config/app_config.dart';
    const appConfigContent = fs.readFileSync(appConfigPath, 'utf8');
    console.log('AppConfig content:');
    console.log(appConfigContent);
    
    // 2. Verificar datos actuales en Firebase
    console.log('\n2. Verificando datos actuales en Firebase...');
    const battleMissions = ['mision_batalla_1', 'mision_batalla_2'];
    
    for (const missionId of battleMissions) {
      const doc = await db.collection('missions').doc(missionId).get();
      if (doc.exists) {
        const data = doc.data();
        console.log(`${missionId}:`);
        console.log(`  - battleConfig.enemyId: ${data.battleConfig?.enemyId}`);
        console.log(`  - objectives.enemyId: ${data.objectives?.enemyId}`);
      }
    }
    
    // 3. Actualizar timestamp para forzar recarga
    console.log('\n3. Actualizando timestamp para forzar recarga...');
    const timestamp = new Date().toISOString();
    
    for (const missionId of battleMissions) {
      await db.collection('missions').doc(missionId).update({
        lastUpdated: timestamp,
        forceReload: true
      });
      console.log(`✅ ${missionId} marcada para recarga forzada`);
    }
    
    // 4. Verificar que el enemigo existe
    console.log('\n4. Verificando que el enemigo existe...');
    const enemyDoc = await db.collection('enemies').doc('enemigo_nullpointerexception').get();
    if (enemyDoc.exists) {
      const enemyData = enemyDoc.data();
      console.log('✅ Enemigo encontrado:');
      console.log(`  - ID: enemigo_nullpointerexception`);
      console.log(`  - Nombre: ${enemyData.name}`);
      console.log(`  - Descripción: ${enemyData.description}`);
    } else {
      console.log('❌ Enemigo NO encontrado en Firebase');
    }
    
    console.log('\n=== RESUMEN ===');
    console.log('- Datos actualizados en Firebase');
    console.log('- Timestamp de recarga forzada añadido');
    console.log('- Enemigo verificado');
    console.log('\nReinicia la aplicación Flutter para ver los cambios.');
    
  } catch (error) {
    console.error('Error forzando actualización:', error);
  }
}

forceHotReload().then(() => {
  console.log('\nActualización completada.');
  process.exit(0);
});