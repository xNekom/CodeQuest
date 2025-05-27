const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Inicializar Firebase Admin
const serviceAccount = require('./assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function cleanAndUploadAchievements() {
  try {
    console.log('🧹 Limpiando logros existentes en Firestore...');
    
    // Obtener todos los logros existentes
    const achievementsSnapshot = await db.collection('achievements').get();
    
    // Eliminar todos los logros existentes
    const batch = db.batch();
    achievementsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`✅ Eliminados ${achievementsSnapshot.docs.length} logros existentes`);
    
    // Crear los nuevos logros correctos
    const newAchievements = [
      // 2 Logros para batallas
      {
        id: "batalla_primera_victoria",
        name: "Primera Victoria",
        description: "Completa tu primera batalla contra un enemigo.",
        iconUrl: "assets/images/badge_primer_bug.svg",
        category: "battle",
        points: 50,
        conditions: {
          battleType: "first_battle",
          victoriesRequired: 1
        },
        requiredMissionIds: [],
        achievementType: "battle",
        rewardId: "recompensa_primera_batalla"
      },
      {
        id: "batalla_final_conquistador",
        name: "Conquistador Supremo",
        description: "Derrota al Bug Supremo en la Batalla Final.",
        iconUrl: "assets/images/badge_bug_supremo.svg",
        category: "battle",
        points: 100,
        conditions: {
          battleType: "final_battle",
          victoriesRequired: 1
        },
        requiredMissionIds: ["mision_batalla_final"],
        achievementType: "battle",
        rewardId: "recompensa_batalla_final"
      },
      // 6 Logros para ejercicios de código
      {
        id: "ejercicio_hola_mundo",
        name: "Primer Hechizo",
        description: "Completa el ejercicio 'Hola Mundo' exitosamente.",
        iconUrl: "assets/images/badge_primer_bug.svg",
        category: "code_exercise",
        points: 20,
        conditions: {
          exerciseId: "hola_mundo_java",
          completionsRequired: 1
        },
        requiredMissionIds: [],
        achievementType: "code_exercise",
        rewardId: "recompensa_hola_mundo"
      },
      {
        id: "ejercicio_variables",
        name: "Maestro de Recipientes",
        description: "Completa el ejercicio de Variables Básicas.",
        iconUrl: "assets/images/badge_array_expert.svg",
        category: "code_exercise",
        points: 25,
        conditions: {
          exerciseId: "variables_basicas",
          completionsRequired: 1
        },
        requiredMissionIds: [],
        achievementType: "code_exercise",
        rewardId: "recompensa_variables"
      },
      {
        id: "ejercicio_operaciones",
        name: "Alquimista Numérico",
        description: "Completa el ejercicio de Operaciones Matemáticas.",
        iconUrl: "assets/images/badge_stack_master.svg",
        category: "code_exercise",
        points: 25,
        conditions: {
          exerciseId: "operaciones_matematicas",
          completionsRequired: 1
        },
        requiredMissionIds: [],
        achievementType: "code_exercise",
        rewardId: "recompensa_operaciones"
      },
      {
        id: "ejercicio_condicionales",
        name: "Guardián de las Puertas",
        description: "Completa el ejercicio de Condicionales IF.",
        iconUrl: "assets/images/badge_null_hunter.svg",
        category: "code_exercise",
        points: 30,
        conditions: {
          exerciseId: "condicionales_if",
          completionsRequired: 1
        },
        requiredMissionIds: [],
        achievementType: "code_exercise",
        rewardId: "recompensa_condicionales"
      },
      {
        id: "ejercicio_bucles",
        name: "Maestro de Círculos Mágicos",
        description: "Completa el ejercicio de Bucles FOR.",
        iconUrl: "assets/images/badge_loop_breaker.svg",
        category: "code_exercise",
        points: 30,
        conditions: {
          exerciseId: "bucle_for_basico",
          completionsRequired: 1
        },
        requiredMissionIds: [],
        achievementType: "code_exercise",
        rewardId: "recompensa_bucles"
      },
      {
        id: "ejercicio_metodos",
        name: "Invocador de Hechizos",
        description: "Completa el ejercicio de Métodos Simples.",
        iconUrl: "assets/images/badge_exception_handler.svg",
        category: "code_exercise",
        points: 35,
        conditions: {
          exerciseId: "metodo_simple",
          completionsRequired: 1
        },
        requiredMissionIds: [],
        achievementType: "code_exercise",
        rewardId: "recompensa_metodos"
      }
    ];
    
    console.log('📤 Subiendo nuevos logros a Firestore...');
    
    // Subir los nuevos logros
    const uploadBatch = db.batch();
    newAchievements.forEach(achievement => {
      const docRef = db.collection('achievements').doc(achievement.id);
      uploadBatch.set(docRef, achievement);
    });
    
    await uploadBatch.commit();
    
    console.log(`✅ Subidos ${newAchievements.length} nuevos logros correctos`);
    console.log('\n📊 Resumen de logros creados:');
    console.log('🏆 Batallas: 2 logros');
    console.log('💻 Ejercicios de código: 6 logros');
    console.log('📈 Total: 8 logros');
    
    console.log('\n🎯 Logros de batallas:');
    newAchievements.filter(a => a.category === 'battle').forEach(a => {
      console.log(`  - ${a.name}: ${a.description}`);
    });
    
    console.log('\n💻 Logros de ejercicios:');
    newAchievements.filter(a => a.category === 'code_exercise').forEach(a => {
      console.log(`  - ${a.name}: ${a.description}`);
    });
    
    console.log('\n🎉 ¡Proceso completado exitosamente!');
    
  } catch (error) {
    console.error('❌ Error durante el proceso:', error);
  } finally {
    process.exit(0);
  }
}

// Ejecutar el script
cleanAndUploadAchievements();