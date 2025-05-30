const admin = require('firebase-admin');

// Verificar si Firebase ya está inicializado
if (admin.apps.length === 0) {
  const serviceAccount = require('./assets/data/serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function simpleRevert() {
  try {
    console.log('Revirtiendo misiones de batalla...');
    
    // Restaurar mision_batalla_1
    await db.collection('missions').doc('mision_batalla_1').set({
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
    });
    console.log('✅ mision_batalla_1 restaurada');
    
    // Restaurar mision_batalla_2
    await db.collection('missions').doc('mision_batalla_2').set({
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
    });
    console.log('✅ mision_batalla_2 restaurada');
    
    console.log('\nRestauración completada. Las misiones ahora usan:');
    console.log('- mision_batalla_1: enemigo_bug_del_punto_y_coma');
    console.log('- mision_batalla_2: enemigo_nullpointerexception');
    
  } catch (error) {
    console.error('Error:', error.message);
  }
}

simpleRevert();