const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Simular exactamente el parsing de MissionModel.fromFirestore
function simulateExactParsing(doc) {
  try {
    const data = doc.data();
    const missionId = doc.id;
    
    console.log(`\n🔍 Parseando misión: ${missionId}`);
    console.log(`Tipo: ${data.type}`);
    
    // Simular MissionModel.fromJson paso a paso
    console.log('\n📝 Paso a paso del parsing:');
    
    // 1. Parse objectives
    console.log('1. Parseando objectives...');
    let objectivesList = [];
    if (data['objectives'] != null && Array.isArray(data['objectives'])) {
      console.log(`   ✓ Objectives es array con ${data['objectives'].length} elementos`);
      
      for (let i = 0; i < data['objectives'].length; i++) {
        const objData = data['objectives'][i];
        console.log(`   Parseando objetivo ${i + 1}:`, JSON.stringify(objData, null, 4));
        
        // Simular Objective.fromJson
        const objective = {
          type: objData['type'] || 'unknown',
          description: objData['description'] || 'No description',
          target: objData['target'] || 1,
          questionIds: objData['questionIds'] || [],
          timeLimitSeconds: objData['timeLimitSeconds'],
          itemId: objData['itemId'],
          quantity: objData['quantity'],
          enemyId: objData['enemyId'],
          targetKillCount: objData['targetKillCount'],
          location: objData['location'],
          collectionSource: objData['collectionSource'],
          collectionSourceDescription: objData['collectionSourceDescription'],
          battleConfig: objData['battleConfig'] ? objData['battleConfig'] : null
        };
        
        objectivesList.push(objective);
        console.log(`   ✓ Objetivo ${i + 1} parseado exitosamente`);
      }
    } else {
      console.log(`   ❌ Objectives no es array válido:`, data['objectives']);
      return false;
    }
    
    // 2. Parse examples
    console.log('2. Parseando examples...');
    let examplesList = null;
    if (data['examples'] != null && Array.isArray(data['examples'])) {
      console.log(`   ✓ Examples es array con ${data['examples'].length} elementos`);
      examplesList = data['examples'];
    } else {
      console.log(`   ⚠️ Examples no presente o no es array`);
    }
    
    // 3. Parse unlocks
    console.log('3. Parseando unlocks...');
    let unlocksList = null;
    if (data['unlocks'] != null && Array.isArray(data['unlocks'])) {
      console.log(`   ✓ Unlocks es array con ${data['unlocks'].length} elementos`);
      unlocksList = data['unlocks'];
    } else {
      console.log(`   ⚠️ Unlocks no presente o no es array`);
    }
    
    // 4. Parse story pages
    console.log('4. Parseando storyPages...');
    let storyPagesList = null;
    if (data['storyPages'] != null && Array.isArray(data['storyPages'])) {
      console.log(`   ✓ StoryPages es array con ${data['storyPages'].length} elementos`);
      storyPagesList = data['storyPages'];
    } else {
      console.log(`   ⚠️ StoryPages no presente o no es array`);
    }
    
    // 5. Parse rewards - AQUÍ PUEDE ESTAR EL PROBLEMA
    console.log('5. Parseando rewards...');
    const rewardsData = data['rewards'] || {};
    console.log(`   Rewards data:`, JSON.stringify(rewardsData, null, 4));
    
    // Simular Reward.fromMap
    const reward = {
      id: rewardsData['id'] || '',
      name: rewardsData['name'] || '',
      description: rewardsData['description'] || '',
      iconUrl: rewardsData['iconUrl'] || '',
      type: rewardsData['type'] || 'points',
      value: rewardsData['value'] || 0,
      conditions: rewardsData['conditions'] || {}
    };
    
    console.log(`   ✓ Reward parseado:`, JSON.stringify(reward, null, 4));
    
    // 6. Parse requirements
    console.log('6. Parseando requirements...');
    let requirements = null;
    if (data['requirements'] != null) {
      console.log(`   ✓ Requirements presente:`, JSON.stringify(data['requirements'], null, 4));
      requirements = data['requirements'];
    } else {
      console.log(`   ⚠️ Requirements no presente`);
    }
    
    // 7. Parse battleConfig
    console.log('7. Parseando battleConfig...');
    let battleConfig = null;
    if (data['battleConfig'] != null && typeof data['battleConfig'] === 'object') {
      console.log(`   ✓ BattleConfig presente:`, JSON.stringify(data['battleConfig'], null, 4));
      battleConfig = data['battleConfig'];
    } else {
      console.log(`   ⚠️ BattleConfig no presente`);
    }
    
    // 8. Crear el objeto final
    console.log('8. Creando objeto MissionModel...');
    const mission = {
      missionId: missionId,
      name: data['name'] || data['title'] || 'Misión sin nombre',
      description: data['description'] || 'Sin descripción',
      zone: data['zone'] || 'Zona desconocida',
      levelRequired: data['levelRequired'] || 1,
      status: data['status'] || 'disponible',
      requirements: requirements,
      objectives: objectivesList,
      rewards: reward,
      isRepeatable: data['isRepeatable'] || false,
      theory: data['theory'],
      examples: examplesList,
      storyPages: storyPagesList,
      battleConfig: battleConfig,
      type: data['type'],
      order: data['order'],
      unlocks: unlocksList,
      createdAt: data['createdAt']
    };
    
    console.log(`✅ Misión ${missionId} parseada exitosamente`);
    console.log(`   Campos finales: name=${mission.name}, type=${mission.type}, order=${mission.order}`);
    
    return true;
    
  } catch (error) {
    console.log(`❌ Error parseando misión ${doc.id}: ${error.message}`);
    console.log(`Stack trace:`, error.stack);
    return false;
  }
}

async function debugExactParsing() {
  try {
    console.log('=== DEBUGGING PARSING EXACTO ===');
    
    const snapshot = await db.collection('missions').orderBy('order').get();
    
    console.log(`Total documentos: ${snapshot.size}`);
    
    let successCount = 0;
    let failCount = 0;
    
    for (const doc of snapshot.docs) {
      const success = simulateExactParsing(doc);
      
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
      
      console.log('\n' + '='.repeat(60));
    }
    
    console.log('\n=== RESUMEN FINAL ===');
    console.log(`Exitosas: ${successCount}`);
    console.log(`Fallidas: ${failCount}`);
    
  } catch (error) {
    console.error('Error en debug:', error);
  }
}

debugExactParsing().then(() => {
  console.log('\nDebug exacto completado.');
  process.exit(0);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});