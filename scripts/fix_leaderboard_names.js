const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixLeaderboardNames() {
  try {
    console.log('🔧 Corrigiendo nombres en el leaderboard...');
    
    // Get all users
    const usersSnapshot = await db.collection('users').get();
    const users = {};
    
    console.log('\n👥 Usuarios encontrados:');
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      users[doc.id] = {
        displayName: userData.displayName || userData.email || doc.id,
        email: userData.email
      };
      console.log(`   ${doc.id}: ${users[doc.id].displayName}`);
    });
    
    // Get all leaderboard entries
    const leaderboardSnapshot = await db.collection('leaderboard').get();
    
    console.log('\n🏆 Actualizando entradas del leaderboard:');
    
    const batch = db.batch();
    let updatedCount = 0;
    
    leaderboardSnapshot.forEach(doc => {
      const leaderboardData = doc.data();
      const userId = leaderboardData.userId;
      
      if (users[userId]) {
        const newDisplayName = users[userId].displayName;
        
        if (leaderboardData.displayName !== newDisplayName) {
          console.log(`   Actualizando ${userId}: "${leaderboardData.displayName}" -> "${newDisplayName}"`);
          
          batch.update(doc.ref, {
            displayName: newDisplayName,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp()
          });
          updatedCount++;
        } else {
          console.log(`   ${userId}: Ya tiene el nombre correcto (${newDisplayName})`);
        }
      } else {
        console.log(`   ⚠️  Usuario ${userId} no encontrado en la colección users`);
      }
    });
    
    if (updatedCount > 0) {
      await batch.commit();
      console.log(`\n✅ Se actualizaron ${updatedCount} entradas del leaderboard`);
    } else {
      console.log('\n✅ No se necesitaron actualizaciones');
    }
    
    // Show updated leaderboard
    console.log('\n🏆 Leaderboard actualizado:');
    const updatedLeaderboard = await db.collection('leaderboard')
      .orderBy('score', 'desc')
      .get();
    
    let rank = 1;
    updatedLeaderboard.forEach(doc => {
      const data = doc.data();
      console.log(`   ${rank}. ${data.displayName} - ${data.score} puntos`);
      rank++;
    });
    
  } catch (error) {
    console.error('❌ Error corrigiendo nombres:', error);
  } finally {
    process.exit(0);
  }
}

fixLeaderboardNames();