// filepath: c:\Users\Pedro\Documents\GitHub\CodeQuest\scripts\import_questions.js

const admin = require('firebase-admin');
const fs = require('fs');

// Carga el archivo de credenciales (asegúrate de que incluya "project_id")
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const questions = JSON.parse(fs.readFileSync(__dirname + '/questions.json', 'utf8'));

async function importQuestions() {
  for (const q of questions) {
    const docRef = db.collection('questions').doc(q.id);
    await docRef.set({
      text: q.text,
      options: q.options,
      correctAnswerIndex: q.correctAnswerIndex,
      explanation: q.explanation,
    });
    console.log(`Importada pregunta ${q.id}`);
  }
  console.log('Importación completa.');
  process.exit(0);
}

importQuestions().catch(err => {
  console.error('Error importando preguntas:', err);
  process.exit(1);
});