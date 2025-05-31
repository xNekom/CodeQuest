const admin = require('firebase-admin');
const serviceAccount = require('../assets/data/serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function verifyCompleteStructure() {
  try {
    console.log('🔍 VERIFICACIÓN COMPLETA DE LA ESTRUCTURA DE FIRESTORE');
    console.log('=' .repeat(60));
    
    // 1. Verificar colección users
    console.log('\n👥 COLECCIÓN USERS:');
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('   ❌ No hay usuarios');
    } else {
      console.log(`   ✅ Total usuarios: ${usersSnapshot.size}`);
      
      usersSnapshot.forEach((doc, index) => {
        const userData = doc.data();
        console.log(`\n   ${index + 1}. Usuario ID: ${doc.id}`);
        console.log(`      Username: ${userData.username || 'N/A'}`);
        console.log(`      Email: ${userData.email || 'N/A'}`);
        console.log(`      Nivel: ${userData.level || 1}`);
        console.log(`      Experiencia: ${userData.experience || 0}`);
        console.log(`      Stats:`);
        console.log(`        - Batallas ganadas: ${userData.stats?.battlesWon || 0}`);
        console.log(`        - Respuestas correctas: ${userData.stats?.correctAnswers || 0}`);
        console.log(`        - Misiones completadas: ${userData.completedMissions?.length || 0}`);
        
        // Calcular puntuación
        const score = (userData.level || 1) * 1000 + 
                     (userData.experience || 0) + 
                     (userData.stats?.battlesWon || 0) * 50 + 
                     (userData.stats?.correctAnswers || 0) * 10 + 
                     (userData.completedMissions?.length || 0) * 200;
        console.log(`      Puntuación calculada: ${score}`);
      });
    }
    
    // 2. Verificar colección leaderboard
    console.log('\n\n🏆 COLECCIÓN LEADERBOARD:');
    const leaderboardSnapshot = await db.collection('leaderboard')
      .orderBy('score', 'desc')
      .get();
    
    if (leaderboardSnapshot.empty) {
      console.log('   ❌ No hay entradas en leaderboard');
    } else {
      console.log(`   ✅ Total entradas: ${leaderboardSnapshot.size}`);
      
      leaderboardSnapshot.forEach((doc, index) => {
        const data = doc.data();
        console.log(`\n   ${index + 1}. Posición en ranking`);
        console.log(`      Document ID: ${doc.id}`);
        console.log(`      User ID: ${data.userId}`);
        console.log(`      Username: ${data.username || 'N/A'}`);
        console.log(`      Puntuación: ${data.score}`);
        console.log(`      Última actualización: ${data.lastUpdated ? data.lastUpdated.toDate() : 'N/A'}`);
      });
    }
    
    // 3. Verificar colección usernames
    console.log('\n\n📝 COLECCIÓN USERNAMES:');
    const usernamesSnapshot = await db.collection('usernames').get();
    
    if (usernamesSnapshot.empty) {
      console.log('   ❌ No hay entradas en usernames');
    } else {
      console.log(`   ✅ Total entradas: ${usernamesSnapshot.size}`);
      
      usernamesSnapshot.forEach((doc, index) => {
        const data = doc.data();
        console.log(`\n   ${index + 1}. Username: ${doc.id}`);
        console.log(`      User ID: ${data.uid}`);
        console.log(`      Username original: ${data.username}`);
        console.log(`      Creado: ${data.createdAt ? data.createdAt.toDate() : 'N/A'}`);
      });
    }
    
    // 4. Verificar consistencia entre colecciones
    console.log('\n\n🔄 VERIFICACIÓN DE CONSISTENCIA:');
    
    // Verificar que cada usuario tenga entrada en leaderboard
    const userIds = usersSnapshot.docs.map(doc => doc.id);
    const leaderboardUserIds = leaderboardSnapshot.docs.map(doc => doc.data().userId);
    
    const usersWithoutLeaderboard = userIds.filter(id => !leaderboardUserIds.includes(id));
    const leaderboardWithoutUsers = leaderboardUserIds.filter(id => !userIds.includes(id));
    
    if (usersWithoutLeaderboard.length === 0) {
      console.log('   ✅ Todos los usuarios tienen entrada en leaderboard');
    } else {
      console.log(`   ❌ Usuarios sin entrada en leaderboard: ${usersWithoutLeaderboard.join(', ')}`);
    }
    
    if (leaderboardWithoutUsers.length === 0) {
      console.log('   ✅ Todas las entradas del leaderboard corresponden a usuarios existentes');
    } else {
      console.log(`   ❌ Entradas del leaderboard sin usuario: ${leaderboardWithoutUsers.join(', ')}`);
    }
    
    // Verificar usernames
    const usersWithUsernames = usersSnapshot.docs.filter(doc => doc.data().username);
    const usernameEntries = usernamesSnapshot.docs.map(doc => doc.data().uid);
    
    const usersWithoutUsernameEntry = usersWithUsernames
      .map(doc => doc.id)
      .filter(id => !usernameEntries.includes(id));
    
    if (usersWithoutUsernameEntry.length === 0) {
      console.log('   ✅ Todos los usuarios con username tienen entrada en colección usernames');
    } else {
      console.log(`   ❌ Usuarios con username sin entrada en usernames: ${usersWithoutUsernameEntry.join(', ')}`);
    }
    
    console.log('\n' + '=' .repeat(60));
    console.log('✅ VERIFICACIÓN COMPLETA FINALIZADA');
    
  } catch (error) {
    console.error('❌ Error en la verificación:', error);
  } finally {
    process.exit(0);
  }
}

verifyCompleteStructure();