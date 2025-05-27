const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Cargar la clave de servicio
const serviceAccount = require('./assets/data/serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadCodeExercises() {
  try {
    console.log('=== SUBIENDO EJERCICIOS DE CÓDIGO A FIRESTORE ===\n');
    
    // Leer el archivo de ejercicios
    const exercisesPath = path.join(__dirname, 'assets/data/code_exercises.json');
    const exercisesData = JSON.parse(fs.readFileSync(exercisesPath, 'utf8'));
    
    console.log(`Encontrados ${exercisesData.length} ejercicios para subir...\n`);
    
    // Subir cada ejercicio
    for (let i = 0; i < exercisesData.length; i++) {
      const exercise = exercisesData[i];
      const exerciseId = exercise.exerciseId;
      
      console.log(`${i + 1}. Subiendo ejercicio: ${exercise.title} (${exerciseId})`);
      
      try {
        await db.collection('code_exercises').doc(exerciseId).set(exercise);
        console.log(`   ✅ Ejercicio ${exerciseId} subido exitosamente`);
      } catch (error) {
        console.log(`   ❌ Error subiendo ejercicio ${exerciseId}:`, error.message);
      }
    }
    
    console.log('\n=== VERIFICANDO EJERCICIOS EN FIRESTORE ===\n');
    
    // Verificar que se subieron correctamente
    const snapshot = await db.collection('code_exercises').get();
    console.log(`Total de ejercicios en Firestore: ${snapshot.size}`);
    
    snapshot.forEach(doc => {
      const data = doc.data();
      console.log(`- ${doc.id}: ${data.title} (Dificultad: ${data.difficulty})`);
    });
    
    console.log('\n✅ Proceso completado exitosamente');
    
  } catch (error) {
    console.error('❌ Error durante el proceso:', error);
  } finally {
    // Cerrar la conexión
    process.exit(0);
  }
}

// Función para verificar ejercicios existentes
async function checkExistingExercises() {
  try {
    console.log('=== VERIFICANDO EJERCICIOS EXISTENTES ===\n');
    
    const snapshot = await db.collection('code_exercises').get();
    
    if (snapshot.empty) {
      console.log('No hay ejercicios en Firestore. Procediendo a subirlos...');
      return false;
    } else {
      console.log(`Encontrados ${snapshot.size} ejercicios existentes:`);
      snapshot.forEach(doc => {
        const data = doc.data();
        console.log(`- ${doc.id}: ${data.title}`);
      });
      return true;
    }
  } catch (error) {
    console.error('Error verificando ejercicios:', error);
    return false;
  }
}

// Función principal
async function main() {
  const hasExercises = await checkExistingExercises();
  
  if (!hasExercises) {
    await uploadCodeExercises();
  } else {
    console.log('\n¿Deseas sobrescribir los ejercicios existentes? (y/n)');
    console.log('Ejecuta el script con --force para sobrescribir automáticamente');
    
    if (process.argv.includes('--force')) {
      console.log('\nSobrescribiendo ejercicios existentes...');
      await uploadCodeExercises();
    } else {
      console.log('\nProceso cancelado. Los ejercicios ya existen en Firestore.');
      process.exit(0);
    }
  }
}

// Ejecutar el script
main();