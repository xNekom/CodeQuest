// Script para corregir los IDs de preguntas en los documentos de misiones
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

// Mapa de IDs antiguos a nuevos (ajusta según tu mapeo de preguntas)
const idMap = {
  'pregunta1_id': 'q1',
  'pregunta2_id': 'q2'
};

async function updateMissions() {
  const missionsSnap = await db.collection('missions').get();
  for (const mission of missionsSnap.docs) {
    const data = mission.data();
    const struct = data.structure;
    if (Array.isArray(struct)) {
      const updated = struct.map(id => idMap[id] || id);
      await db.collection('missions').doc(mission.id).update({ structure: updated });
      console.log(`Misión ${mission.id} actualizada:`, updated);
    }
  }
  console.log('Actualización de misiones completada.');
  process.exit(0);
}

updateMissions().catch(err => {
  console.error('Error al actualizar misiones:', err);
  process.exit(1);
});
