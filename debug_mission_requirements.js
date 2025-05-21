const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function debugMissionRequirements() {
  try {
    console.log('=== DEBUGGING REQUISITOS DE MISIONES ===');
    
    // Obtener todas las misiones
    const missionsSnapshot = await db.collection('missions').orderBy('order').get();
    
    // Obtener datos de usuario (asumiendo que hay un usuario test)
    const usersSnapshot = await db.collection('users').limit(5).get();
    
    console.log(`Total misiones: ${missionsSnapshot.size}`);
    console.log(`Total usuarios encontrados: ${usersSnapshot.size}`);
    
    if (usersSnapshot.empty) {
      console.log('\n❌ No se encontraron usuarios. Creando datos de prueba...');
      // Simular datos de usuario típicos
      const testUserData = {
        level: 1,
        completedMissions: []
      };
      
      console.log('\n=== ANÁLISIS CON USUARIO DE PRUEBA ===');
      console.log(`Nivel de usuario: ${testUserData.level}`);
      console.log(`Misiones completadas: ${testUserData.completedMissions.length}`);
      
      analyzeMissions(missionsSnapshot.docs, testUserData);
      return;
    }
    
    // Analizar con usuarios reales
    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      console.log(`\n=== ANÁLISIS PARA USUARIO: ${userDoc.id} ===`);
      console.log(`Nivel: ${userData.level || 1}`);
      console.log(`Misiones completadas: ${(userData.completedMissions || []).length}`);
      console.log(`Lista de misiones completadas: ${(userData.completedMissions || []).join(', ')}`);
      
      analyzeMissions(missionsSnapshot.docs, userData);
      break; // Solo analizar el primer usuario
    }
    
  } catch (error) {
    console.error('Error debugging requisitos:', error);
  }
}

function analyzeMissions(missionDocs, userData) {
  console.log('\n=== ANÁLISIS DE DESBLOQUEADO/BLOQUEADO ===');
  
  const userLevel = userData.level || 1;
  const completedMissions = userData.completedMissions || [];
  
  missionDocs.forEach(doc => {
    const mission = doc.data();
    const missionId = doc.id;
    
    console.log(`\n🎯 ${missionId} (${mission.type})`);
    console.log(`   Nombre: ${mission.name}`);
    console.log(`   Nivel requerido: ${mission.levelRequired || 1}`);
    console.log(`   Order: ${mission.order}`);
    
    // Verificar nivel
    const levelOk = userLevel >= (mission.levelRequired || 1);
    console.log(`   ✓ Nivel suficiente: ${levelOk} (usuario: ${userLevel}, requerido: ${mission.levelRequired || 1})`);
    
    // Verificar requisitos
    let requirementsOk = true;
    let requirementReason = '';
    
    if (mission.requirements) {
      console.log(`   Requisitos encontrados:`, JSON.stringify(mission.requirements, null, 2));
      
      if (mission.requirements.completedMissionId) {
        const requiredMissionCompleted = completedMissions.includes(mission.requirements.completedMissionId);
        requirementsOk = requiredMissionCompleted;
        requirementReason = `Requiere completar: ${mission.requirements.completedMissionId} (completada: ${requiredMissionCompleted})`;
        console.log(`   ✓ Requisito de misión: ${requirementsOk} - ${requirementReason}`);
      }
    } else {
      console.log(`   ✓ Sin requisitos especiales`);
    }
    
    const isUnlocked = levelOk && requirementsOk;
    const isCompleted = completedMissions.includes(missionId);
    
    console.log(`   🔓 DESBLOQUEADA: ${isUnlocked}`);
    console.log(`   ✅ COMPLETADA: ${isCompleted}`);
    
    if (!isUnlocked) {
      const reasons = [];
      if (!levelOk) reasons.push(`Nivel insuficiente (${userLevel}/${mission.levelRequired || 1})`);
      if (!requirementsOk) reasons.push(requirementReason);
      console.log(`   🚫 Razones de bloqueo: ${reasons.join(', ')}`);
    }
  });
  
  // Resumen por tipo
  console.log('\n=== RESUMEN POR TIPO ===');
  const missionsByType = {};
  const unlockedByType = {};
  
  missionDocs.forEach(doc => {
    const mission = doc.data();
    const type = mission.type || 'unknown';
    
    if (!missionsByType[type]) {
      missionsByType[type] = 0;
      unlockedByType[type] = 0;
    }
    
    missionsByType[type]++;
    
    // Calcular si está desbloqueada
    const levelOk = userLevel >= (mission.levelRequired || 1);
    let requirementsOk = true;
    
    if (mission.requirements && mission.requirements.completedMissionId) {
      requirementsOk = completedMissions.includes(mission.requirements.completedMissionId);
    }
    
    if (levelOk && requirementsOk) {
      unlockedByType[type]++;
    }
  });
  
  Object.keys(missionsByType).forEach(type => {
    console.log(`${type}: ${unlockedByType[type]}/${missionsByType[type]} desbloqueadas`);
  });
}

debugMissionRequirements().then(() => {
  console.log('\nDebug completado.');
  process.exit(0);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});