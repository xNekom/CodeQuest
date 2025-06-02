const admin = require('firebase-admin');
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkMissions() {
  try {
    console.log('🔍 Verificando misiones en Firebase...');
    const snapshot = await db.collection('missions').get();
    console.log(`📊 Total misiones en Firebase: ${snapshot.size}`);
    console.log('\n=== LISTADO DE MISIONES ===');
    
    snapshot.forEach(doc => {
      const data = doc.data();
      console.log(`\n🎯 ID: ${doc.id}`);
      console.log(`   Título: ${data.title || data.name || 'Sin título'}`);
      console.log(`   Tipo: ${data.type || 'Sin tipo'}`);
      console.log(`   Zona: ${data.zone || 'Sin zona'}`);
      console.log(`   Nivel requerido: ${data.levelRequired || 'Sin nivel'}`);
      console.log(`   Estado: ${data.status || 'Sin estado'}`);
      
      if (data.objectives) {
        if (Array.isArray(data.objectives)) {
          console.log(`   Objetivos: ${data.objectives.length} objetivos`);
          data.objectives.forEach((obj, i) => {
            console.log(`     ${i+1}. Tipo: ${obj.type || 'Sin tipo'} - ${obj.description || 'Sin descripción'}`);
            if (obj.type === 'batalla' && obj.battleConfig) {
              console.log(`        ⚔️ BattleConfig: Enemigo ${obj.battleConfig.enemyId || 'Sin enemigo'}`);
            }
          });
        } else {
          console.log(`   Objetivos: Formato Object (no Array)`);
          console.log(`   Contenido:`, JSON.stringify(data.objectives, null, 2));
        }
      } else {
        console.log(`   ❌ Sin objetivos`);
      }
      
      if (data.battleConfig) {
        console.log(`   ⚔️ BattleConfig a nivel misión: Presente`);
      }
      
      console.log('   ---');
    });
    
    // Análisis por tipo
    console.log('\n=== ANÁLISIS POR TIPO ===');
    const missionsByType = {};
    snapshot.forEach(doc => {
      const data = doc.data();
      let type = 'Sin tipo';
      
      if (data.type) {
        type = data.type;
      } else if (doc.id.includes('teoria')) {
        type = 'teoria (detectado por ID)';
      } else if (doc.id.includes('batalla')) {
        type = 'batalla (detectado por ID)';
      } else if (data.objectives && Array.isArray(data.objectives)) {
        const hasBattleObjective = data.objectives.some(obj => obj.type === 'batalla');
        if (hasBattleObjective) {
          type = 'batalla (detectado por objetivo)';
        }
      }
      
      if (!missionsByType[type]) {
        missionsByType[type] = [];
      }
      missionsByType[type].push(doc.id);
    });
    
    Object.keys(missionsByType).forEach(type => {
      console.log(`\n📋 ${type}: ${missionsByType[type].length} misiones`);
      missionsByType[type].forEach(id => {
        console.log(`   - ${id}`);
      });
    });
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
  
  process.exit(0);
}

checkMissions();