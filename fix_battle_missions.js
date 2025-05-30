const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixBattleMissions() {
  try {
    console.log('=== FIXING BATTLE MISSIONS STRUCTURE ===');
    
    // Get battle missions
    const snapshot = await db.collection('missions').where('type', '==', 'batalla').get();
    
    console.log(`Found ${snapshot.size} battle missions to fix`);
    
    for (const doc of snapshot.docs) {
      const data = doc.data();
      const missionId = doc.id;
      
      console.log(`\n🔧 Fixing mission: ${missionId}`);
      console.log(`Current structure:`);
      console.log(`  - battleConfig.enemyIds: ${JSON.stringify(data.battleConfig?.enemyIds)}`);
      console.log(`  - battleConfig.enemyId: ${data.battleConfig?.enemyId || 'NOT PRESENT'}`);
      console.log(`  - battleConfig.questionIds: ${JSON.stringify(data.battleConfig?.questionIds) || 'NOT PRESENT'}`);
      
      // Check if we need to fix the structure
      let needsUpdate = false;
      const updatedData = { ...data };
      
      if (data.battleConfig) {
        const battleConfig = { ...data.battleConfig };
        
        // Fix enemyId (convert from enemyIds array to single enemyId)
        if (battleConfig.enemyIds && Array.isArray(battleConfig.enemyIds) && battleConfig.enemyIds.length > 0) {
          if (!battleConfig.enemyId) {
            battleConfig.enemyId = battleConfig.enemyIds[0]; // Take the first enemy
            console.log(`  ✓ Added enemyId: ${battleConfig.enemyId}`);
            needsUpdate = true;
          }
        }
        
        // Add questionIds if missing (battle missions need questions for combat)
        if (!battleConfig.questionIds) {
          // For now, we'll add some default question IDs
          // In a real scenario, you'd want to assign appropriate questions
          battleConfig.questionIds = [
            'q_basic_1', 
            'q_basic_2', 
            'q_basic_3'
          ];
          console.log(`  ✓ Added questionIds: ${JSON.stringify(battleConfig.questionIds)}`);
          needsUpdate = true;
        }
        
        // Also fix objectives if they have battleConfig
        if (data.objectives && Array.isArray(data.objectives)) {
          const updatedObjectives = data.objectives.map(objective => {
            if (objective.battleConfig) {
              const objBattleConfig = { ...objective.battleConfig };
              
              // Fix enemyId in objective's battleConfig
              if (objBattleConfig.enemyIds && Array.isArray(objBattleConfig.enemyIds) && objBattleConfig.enemyIds.length > 0) {
                if (!objBattleConfig.enemyId) {
                  objBattleConfig.enemyId = objBattleConfig.enemyIds[0];
                  needsUpdate = true;
                }
              }
              
              // Add questionIds to objective's battleConfig
              if (!objBattleConfig.questionIds) {
                objBattleConfig.questionIds = [
                  'q_basic_1', 
                  'q_basic_2', 
                  'q_basic_3'
                ];
                needsUpdate = true;
              }
              
              return {
                ...objective,
                battleConfig: objBattleConfig
              };
            }
            return objective;
          });
          
          updatedData.objectives = updatedObjectives;
        }
        
        updatedData.battleConfig = battleConfig;
      }
      
      if (needsUpdate) {
        console.log(`  🔄 Updating mission ${missionId}...`);
        await doc.ref.update(updatedData);
        console.log(`  ✅ Mission ${missionId} updated successfully`);
      } else {
        console.log(`  ⚠️ Mission ${missionId} doesn't need updates`);
      }
    }
    
    console.log('\n=== VERIFICATION ===');
    
    // Verify the fixes
    const verifySnapshot = await db.collection('missions').where('type', '==', 'batalla').get();
    
    for (const doc of verifySnapshot.docs) {
      const data = doc.data();
      const missionId = doc.id;
      
      console.log(`\n✅ Verified ${missionId}:`);
      console.log(`  - battleConfig.enemyId: ${data.battleConfig?.enemyId || 'MISSING'}`);
      console.log(`  - battleConfig.questionIds: ${JSON.stringify(data.battleConfig?.questionIds) || 'MISSING'}`);
      
      if (data.objectives && Array.isArray(data.objectives)) {
        data.objectives.forEach((obj, index) => {
          if (obj.battleConfig) {
            console.log(`  - objectives[${index}].battleConfig.enemyId: ${obj.battleConfig.enemyId || 'MISSING'}`);
            console.log(`  - objectives[${index}].battleConfig.questionIds: ${JSON.stringify(obj.battleConfig.questionIds) || 'MISSING'}`);
          }
        });
      }
    }
    
  } catch (error) {
    console.error('Error fixing battle missions:', error);
  }
}

fixBattleMissions().then(() => {
  console.log('\nBattle missions fix completed.');
  process.exit(0);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});