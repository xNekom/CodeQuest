const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Inicializar Firebase Admin SDK
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadData() {
  try {
    console.log('🚀 Iniciando subida de datos reorganizados a Firestore...');
    
    // Leer datos reorganizados
    const missionsPath = path.join(__dirname, 'assets', 'data', 'missions_reorganized_pedagogical.json');
    const questionsPath = path.join(__dirname, 'assets', 'data', 'questions_reorganized_pedagogical.json');
    
    const missions = JSON.parse(fs.readFileSync(missionsPath, 'utf8'));
    const questions = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));
    
    console.log(`📋 Misiones a subir: ${missions.length}`);
    console.log(`❓ Preguntas a subir: ${questions.length}`);
    
    // Subir misiones
    console.log('\n📤 Subiendo misiones...');
    const batch = db.batch();
    
    for (const mission of missions) {
      const missionRef = db.collection('missions').doc(mission.id);
      batch.set(missionRef, mission);
      console.log(`  ✓ ${mission.id}: ${mission.title}`);
    }
    
    // Subir preguntas
    console.log('\n📤 Subiendo preguntas...');
    for (const question of questions) {
      const questionRef = db.collection('questions').doc(question.id);
      batch.set(questionRef, question);
      console.log(`  ✓ ${question.id} (Nivel ${question.difficulty})`);
    }
    
    // Ejecutar batch
    await batch.commit();
    
    console.log('\n✅ ¡Datos subidos exitosamente a Firestore!');
    console.log('\n📊 Resumen de la reorganización:');
    console.log('  🎯 Progresión pedagógica implementada');
    console.log('  📚 Conceptos organizados de básico a avanzado');
    console.log('  🐛 Primera batalla ahora apropiada para principiantes');
    console.log('  🔄 Teoría y preguntas ahora están alineadas');
    
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error al subir datos:', error);
    process.exit(1);
  }
}

// Función para verificar datos antes de subir
async function verifyData() {
  console.log('🔍 Verificando estructura de datos...');
  
  const missionsPath = path.join(__dirname, 'assets', 'data', 'missions_reorganized_pedagogical.json');
  const questionsPath = path.join(__dirname, 'assets', 'data', 'questions_reorganized_pedagogical.json');
  
  if (!fs.existsSync(missionsPath)) {
    console.error('❌ No se encontró el archivo de misiones reorganizadas');
    return false;
  }
  
  if (!fs.existsSync(questionsPath)) {
    console.error('❌ No se encontró el archivo de preguntas reorganizadas');
    return false;
  }
  
  const missions = JSON.parse(fs.readFileSync(missionsPath, 'utf8'));
  const questions = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));
  
  // Verificar que las preguntas referenciadas en las misiones existen
  for (const mission of missions) {
    if (mission.objectives) {
      for (const objective of mission.objectives) {
        if (objective.questionIds) {
          for (const questionId of objective.questionIds) {
            const questionExists = questions.find(q => q.id === questionId);
            if (!questionExists) {
              console.error(`❌ Pregunta ${questionId} referenciada en misión ${mission.id} no existe`);
              return false;
            }
          }
        }
      }
    }
  }
  
  console.log('✅ Verificación completada - datos válidos');
  return true;
}

// Ejecutar verificación y subida
verifyData().then(isValid => {
  if (isValid) {
    uploadData();
  } else {
    console.error('❌ Verificación falló - no se subirán los datos');
    process.exit(1);
  }
});