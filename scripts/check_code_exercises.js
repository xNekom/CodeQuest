const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkCodeExercises() {
  try {
    console.log('=== VERIFICANDO EJERCICIOS DE CÓDIGO EN FIRESTORE ===\n');
    
    const snapshot = await db.collection('code_exercises').orderBy('difficulty').get();
    
    if (snapshot.empty) {
      console.log('❌ No hay ejercicios de código en Firestore');
      console.log('Ejecuta: node upload_code_exercises.js para subirlos');
      return;
    }
    
    console.log(`✅ Encontrados ${snapshot.size} ejercicios en Firestore:\n`);
    
    snapshot.forEach((doc, index) => {
      const data = doc.data();
      console.log(`${index + 1}. ${data.title}`);
      console.log(`   ID: ${doc.id}`);
      console.log(`   Dificultad: ${data.difficulty}`);
      console.log(`   Conceptos: ${data.concepts.join(', ')}`);
      console.log(`   Casos de prueba: ${data.testCases.length}`);
      console.log(`   Pistas: ${data.hints.length}`);
      console.log('');
    });
    
    // Verificar estructura de un ejercicio
    const firstDoc = snapshot.docs[0];
    const firstExercise = firstDoc.data();
    
    console.log('=== ESTRUCTURA DEL PRIMER EJERCICIO ===\n');
    console.log('Campos requeridos:');
    console.log(`- exerciseId: ${firstExercise.exerciseId ? '✅' : '❌'}`);
    console.log(`- title: ${firstExercise.title ? '✅' : '❌'}`);
    console.log(`- description: ${firstExercise.description ? '✅' : '❌'}`);
    console.log(`- initialCode: ${firstExercise.initialCode ? '✅' : '❌'}`);
    console.log(`- expectedOutput: ${firstExercise.expectedOutput ? '✅' : '❌'}`);
    console.log(`- hints: ${Array.isArray(firstExercise.hints) ? '✅' : '❌'}`);
    console.log(`- requiredPatterns: ${Array.isArray(firstExercise.requiredPatterns) ? '✅' : '❌'}`);
    console.log(`- testCases: ${Array.isArray(firstExercise.testCases) ? '✅' : '❌'}`);
    console.log(`- difficulty: ${typeof firstExercise.difficulty === 'number' ? '✅' : '❌'}`);
    console.log(`- concepts: ${Array.isArray(firstExercise.concepts) ? '✅' : '❌'}`);
    
  } catch (error) {
    console.error('❌ Error verificando ejercicios:', error);
  } finally {
    process.exit(0);
  }
}

// Ejecutar verificación
checkCodeExercises();