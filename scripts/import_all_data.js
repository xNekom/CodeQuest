// filepath: c:\Users\Pedro\Documents\GitHub\CodeQuest\scripts\import_all_data.js
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Carga el archivo de credenciales (asegúrate de que incluya "project_id")
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const questionsFilePath = path.join(__dirname, 'questions.json');
const itemsFilePath = path.join(__dirname, 'items_data.json');
const missionsFilePath = path.join(__dirname, 'missions_data.json');
const enemiesFilePath = path.join(__dirname, 'enemies_data.json');

async function uploadGenericData(filePath, collectionName) {
  try {
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    const collectionRef = db.collection(collectionName);
    const batch = db.batch();

    data.forEach(item => {
      if (!item.id) {
        console.error(`Error: El objeto en ${path.basename(filePath)} no tiene un campo 'id'. Saltando este objeto.`);
        return; 
      }
      const docRef = collectionRef.doc(item.id);
      batch.set(docRef, item);
    });

    await batch.commit();
    console.log(`Datos de ${path.basename(filePath)} subidos exitosamente a la colección ${collectionName} usando los IDs proporcionados.`);
  } catch (error) {
    console.error(`Error subiendo datos de ${path.basename(filePath)} a ${collectionName}:`, error);
  }
}

async function importAllData() {
  console.log('Iniciando la población de la base de datos...');

  // Importar preguntas
  try {
    const questions = JSON.parse(fs.readFileSync(questionsFilePath, 'utf8'));
    const batchQuestions = db.batch();
    for (const q of questions) {
      if (!q.id) {
        console.error(`Error: Pregunta en ${path.basename(questionsFilePath)} no tiene un campo 'id'. Saltando esta pregunta.`);
        continue;
      }
      const docRef = db.collection('questions').doc(q.id);
      // Asumiendo que q ya tiene todos los campos necesarios, incluyendo el id.
      // Si necesitas transformar el objeto q antes de guardarlo, hazlo aquí.
      // Por ejemplo, si el objeto q del JSON tiene más campos de los que quieres en Firestore:
      // const questionData = {
      //   text: q.text,
      //   options: q.options,
      //   correctAnswerIndex: q.correctAnswerIndex,
      //   explanation: q.explanation,
      //   // id: q.id, // No es necesario si el id ya está en el objeto q y se usa para .doc(q.id)
      // };
      // batchQuestions.set(docRef, questionData);
      batchQuestions.set(docRef, q); // Guarda el objeto q completo
      console.log(`Pregunta con ID ${q.id} preparada para importación.`);
    }
    await batchQuestions.commit();
    console.log(`Datos de ${path.basename(questionsFilePath)} subidos exitosamente a la colección 'questions' usando los IDs proporcionados.`);
  } catch (error) {
    console.error(`Error importando preguntas de ${path.basename(questionsFilePath)}:`, error);
  }

  // Importar otros datos
  await uploadGenericData(itemsFilePath, 'items');
  await uploadGenericData(missionsFilePath, 'missions');
  await uploadGenericData(enemiesFilePath, 'enemies');

  console.log('--------------------------------------------------------------------');
  console.log('Proceso de población de la base de datos finalizado.');
  console.log('Asegúrate de que tus reglas de seguridad de Firestore permitan el acceso de escritura para el SDK de administración.');
  console.log('--------------------------------------------------------------------');
  process.exit(0);
}

importAllData().catch(err => {
  console.error('Error en el proceso de importación de todos los datos:', err);
  process.exit(1);
});
