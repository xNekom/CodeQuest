const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function revertMissionData() {
  try {
    console.log('=== REVIRTIENDO DATOS DE MISIONES ===\n');
    
    // Datos originales de las misiones de batalla
    const originalMissionData = {
      'mision_batalla_1': {
        name: 'Batalla 1: Cazando Bugs Básicos',
        description: 'Tu primera batalla contra los bugs de programación. Derrota al Bug del Punto y Coma.',
        zone: 'Campo de Batalla',
        levelRequired: 1,
        status: 'disponible',
        isRepeatable: true,
        type: 'batalla',
        order: 4,
        objectives: [{
          type: 'batalla',
          description: 'Derrota al Bug del Punto y Coma respondiendo preguntas.',
          target: 1,
          battleConfig: {
            enemyId: 'enemigo_bug_del_punto_y_coma',
            questionIds: [
              'pregunta_que_es_un_programa',
              'pregunta_multiplataforma_java',
              'pregunta_estructura_principal_java_clase_main'
            ],
            playerHealthMultiplier: 1.0,
            enemyAttackMultiplier: 0.8,
            environment: 'campo_bug'
          }
        }],
        rewards: {
          experience: 30,
          coins: 25,
          items: [],
          unlocks: ['mision_batalla_2']
        }
      },
      'mision_batalla_2': {
        name: 'Batalla 2: Excepciones Peligrosas',
        description: 'Enfrenta al temido NullPointerException en esta batalla intermedia.',
        zone: 'Campo de Batalla',
        levelRequired: 1,
        status: 'bloqueada',
        isRepeatable: true,
        type: 'batalla',
        order: 5,
        requirements: {
          completedMissionId: 'mision_batalla_1'
        },
        objectives: [{
          type: 'batalla',
          description: 'Derrota al NullPointerException con tus conocimientos.',
          target: 1,
          battleConfig: {
            enemyId: 'enemigo_nullpointerexception',
            questionIds: [
              'pregunta_instruccion_hola_mundo_java',
              'pregunta_que_es_una_variable',
              'pregunta_tipo_dato_edad_java'
            ],
            playerHealthMultiplier: 1.0,
            enemyAttackMultiplier: 1.2,
            environment: 'campo_excepcion'
          }
        }],
        rewards: {
          experience: 50,
          coins: 40,
          items: [],
          unlocks: ['mision_batalla_final']
        }
      }
    };
    
    // Restaurar cada misión
    for (const [missionId, missionData] of Object.entries(originalMissionData)) {
      console.log(`Restaurando ${missionId}...`);
      
      // Eliminar campos que pudieron haber sido añadidos
      const cleanData = { ...missionData };
      
      // Actualizar la misión en Firebase
      await db.collection('missions').doc(missionId).set(cleanData, { merge: false });
      console.log(`✅ ${missionId} restaurada`);
    }
    
    // Verificar que los enemigos existen
    console.log('\nVerificando enemigos...');
    const enemiesNeeded = ['enemigo_bug_del_punto_y_coma', 'enemigo_nullpointerexception'];
    
    for (const enemyId of enemiesNeeded) {
      const enemyDoc = await db.collection('enemies').doc(enemyId).get();
      if (enemyDoc.exists) {
        console.log(`✅ ${enemyId}: ${enemyDoc.data().name}`);
      } else {
        console.log(`❌ ${enemyId}: NO ENCONTRADO`);
      }
    }
    
    // Verificación final
    console.log('\n=== VERIFICACIÓN FINAL ===');
    for (const missionId of Object.keys(originalMissionData)) {
      const doc = await db.collection('missions').doc(missionId).get();
      if (doc.exists) {
        const data = doc.data();
        console.log(`${missionId}:`);
        console.log(`  - enemyId: ${data.objectives[0].battleConfig.enemyId}`);
        console.log(`  - questionIds: ${data.objectives[0].battleConfig.questionIds.length} preguntas`);
      }
    }
    
    console.log('\n=== RESTAURACIÓN COMPLETADA ===');
    console.log('Las misiones de batalla han sido restauradas a su estado original.');
    console.log('Reinicia la aplicación Flutter para ver los cambios.');
    
  } catch (error) {
    console.error('Error revirtiendo datos:', error);
  }
}

revertMissionData().then(() => {
  console.log('\nRestauración completada.');
  process.exit(0);
});