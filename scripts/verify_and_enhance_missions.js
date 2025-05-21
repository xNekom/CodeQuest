const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

// Configuración de Firebase
const serviceAccount = require('../assets/data/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://codequest-f7be9-default-rtdb.firebaseio.com/'
});

const db = admin.firestore();

// Cargar datos locales
const missionsData = JSON.parse(fs.readFileSync('../assets/data/missions_data.json', 'utf8'));
const questionsData = JSON.parse(fs.readFileSync('../assets/data/questions.json', 'utf8'));

class MissionTheoryAnalyzer {
  constructor() {
    this.analysisReport = {
      missionsAnalyzed: 0,
      questionsAnalyzed: 0,
      theoryGaps: [],
      enhancedMissions: [],
      recommendations: []
    };
  }

  // Analizar la relación entre teoría y preguntas
  analyzeTheoryQuestionAlignment() {
    console.log('🔍 Analizando alineación entre teoría y preguntas...');
    
    missionsData.forEach(mission => {
      if (mission.theory) {
        this.analysisReport.missionsAnalyzed++;
        
        const missionQuestions = this.getMissionQuestions(mission);
        const theoryKeywords = this.extractTheoryKeywords(mission.theory);
        const questionKeywords = this.extractQuestionKeywords(missionQuestions);
        
        const alignment = this.calculateAlignment(theoryKeywords, questionKeywords);
        
        if (alignment < 0.7) { // Umbral de alineación
          this.analysisReport.theoryGaps.push({
            missionId: mission.id,
            title: mission.title,
            alignment: alignment,
            missingConcepts: this.findMissingConcepts(theoryKeywords, questionKeywords),
            currentTheory: mission.theory
          });
        }
      }
    });
  }

  // Obtener preguntas de una misión
  getMissionQuestions(mission) {
    const questionIds = [];
    mission.objectives.forEach(objective => {
      if (objective.questionIds) {
        questionIds.push(...objective.questionIds);
      }
      if (objective.battleConfig && objective.battleConfig.questionIds) {
        questionIds.push(...objective.battleConfig.questionIds);
      }
    });
    
    return questionsData.filter(q => questionIds.includes(q.id));
  }

  // Extraer palabras clave de la teoría
  extractTheoryKeywords(theory) {
    const keywords = new Set();
    const text = theory.toLowerCase();
    
    // Conceptos clave de programación
    const programmingConcepts = [
      'programa', 'instrucciones', 'java', 'multiplataforma', 'jvm',
      'clase', 'método', 'main', 'variable', 'tipo', 'int', 'string',
      'boolean', 'double', 'if', 'else', 'bucle', 'for', 'while',
      'array', 'arraylist', 'objeto', 'instancia', 'constructor',
      'excepción', 'null', 'poo', 'orientada objetos', 'sintaxis',
      'compilador', 'punto y coma', 'nullpointerexception'
    ];
    
    programmingConcepts.forEach(concept => {
      if (text.includes(concept)) {
        keywords.add(concept);
      }
    });
    
    return Array.from(keywords);
  }

  // Extraer palabras clave de las preguntas
  extractQuestionKeywords(questions) {
    const keywords = new Set();
    
    questions.forEach(question => {
      const text = (question.text + ' ' + question.explanation).toLowerCase();
      
      const programmingConcepts = [
        'programa', 'instrucciones', 'java', 'multiplataforma', 'jvm',
        'clase', 'método', 'main', 'variable', 'tipo', 'int', 'string',
        'boolean', 'double', 'if', 'else', 'bucle', 'for', 'while',
        'array', 'arraylist', 'objeto', 'instancia', 'constructor',
        'excepción', 'null', 'poo', 'orientada objetos', 'sintaxis',
        'compilador', 'punto y coma', 'nullpointerexception'
      ];
      
      programmingConcepts.forEach(concept => {
        if (text.includes(concept)) {
          keywords.add(concept);
        }
      });
    });
    
    return Array.from(keywords);
  }

  // Calcular alineación entre teoría y preguntas
  calculateAlignment(theoryKeywords, questionKeywords) {
    if (questionKeywords.length === 0) return 0;
    
    const intersection = theoryKeywords.filter(keyword => 
      questionKeywords.includes(keyword)
    );
    
    return intersection.length / questionKeywords.length;
  }

  // Encontrar conceptos faltantes en la teoría
  findMissingConcepts(theoryKeywords, questionKeywords) {
    return questionKeywords.filter(keyword => 
      !theoryKeywords.includes(keyword)
    );
  }

  // Ampliar teoría basada en las preguntas
  enhanceTheory() {
    console.log('📚 Ampliando teoría de las misiones...');
    
    const enhancedTheories = {
      'mision_teoria_1': {
        title: 'Fundamentos de Java',
        pages: [
          {
            title: 'Página 1: ¿Qué es un programa?',
            content: `Un programa es un conjunto de instrucciones escritas en un lenguaje que el ordenador puede entender y ejecutar. Estas instrucciones le dicen al ordenador exactamente qué hacer, paso a paso, para realizar una tarea específica.

**Características de un programa:**
- Secuencia ordenada de instrucciones
- Escritas en un lenguaje de programación
- Diseñadas para resolver un problema específico
- Pueden procesar datos de entrada y producir resultados

**Ejemplos de programas:**
- Un videojuego que responde a las acciones del jugador
- Una calculadora que realiza operaciones matemáticas
- Un navegador web que muestra páginas de internet
- Una aplicación de mensajería que envía y recibe mensajes`,
            examples: [
              'Programa simple: Mostrar "Hola Mundo" en pantalla',
              'Programa interactivo: Pedir el nombre del usuario y saludarlo',
              'Programa de cálculo: Sumar dos números introducidos por el usuario'
            ]
          },
          {
            title: 'Página 2: Java Multiplataforma',
            content: `Java es un lenguaje de programación especial porque es **multiplataforma**. Esto significa que un programa escrito en Java puede ejecutarse en diferentes sistemas operativos sin necesidad de modificaciones.

**¿Cómo funciona?**
1. **Código fuente**: Escribes tu programa en Java (.java)
2. **Compilación**: El compilador convierte tu código a bytecode (.class)
3. **JVM (Java Virtual Machine)**: Cada sistema operativo tiene su propia JVM que ejecuta el bytecode

**Ventajas de ser multiplataforma:**
- Escribe una vez, ejecuta en cualquier lugar
- Ahorro de tiempo y recursos de desarrollo
- Mayor alcance de usuarios
- Mantenimiento simplificado`,
            examples: [
              'Windows: JVM de Windows ejecuta el mismo bytecode',
              'macOS: JVM de macOS ejecuta el mismo bytecode',
              'Linux: JVM de Linux ejecuta el mismo bytecode',
              'Android: JVM de Android ejecuta el mismo bytecode'
            ]
          }
        ]
      },
      'mision_teoria_2': {
        title: 'Estructura en Java',
        pages: [
          {
            title: 'Página 1: Organización en Clases',
            content: `En Java, todo el código debe estar organizado dentro de **clases**. Una clase es como un contenedor que agrupa código relacionado.

**Estructura básica de una clase:**
\`\`\`java
public class NombreDeLaClase {
    // Aquí va el contenido de la clase
}
\`\`\`

**Reglas importantes:**
- El nombre de la clase debe coincidir con el nombre del archivo
- Cada archivo .java puede tener solo una clase pública
- Los nombres de clase empiezan con mayúscula
- Se usa CamelCase para nombres compuestos

**¿Por qué usar clases?**
- Organización del código
- Reutilización de código
- Encapsulación de funcionalidad
- Base de la programación orientada a objetos`,
            examples: [
              'public class MiPrimerPrograma { }',
              'public class CalculadoraSimple { }',
              'public class JuegoAdivinanza { }'
            ]
          },
          {
            title: 'Página 2: El Método Main',
            content: `El método **main** es el punto de entrada de cualquier programa Java. Es donde comienza la ejecución del programa.

**Sintaxis del método main:**
\`\`\`java
public static void main(String[] args) {
    // Aquí va el código que se ejecutará
}
\`\`\`

**Explicación de cada parte:**
- **public**: Puede ser accedido desde cualquier lugar
- **static**: Pertenece a la clase, no a una instancia
- **void**: No devuelve ningún valor
- **main**: Nombre especial que Java busca para iniciar
- **String[] args**: Parámetros de línea de comandos

**Ejemplo completo:**
\`\`\`java
public class HolaMundo {
    public static void main(String[] args) {
        System.out.println("¡Hola Mundo!");
    }
}
\`\`\``,
            examples: [
              'System.out.println("Mi primer programa");',
              'System.out.println("Bienvenido a Java");',
              'System.out.println("CodeQuest - Aprende programando");'
            ]
          }
        ]
      },
      'mision_teoria_3': {
        title: 'Variables y Tipos de Datos',
        pages: [
          {
            title: 'Página 1: ¿Qué son las Variables?',
            content: `Una **variable** es como una caja etiquetada en la memoria del ordenador donde puedes guardar información que puede cambiar durante la ejecución del programa.

**Características de las variables:**
- Tienen un nombre único (identificador)
- Almacenan un valor específico
- El valor puede cambiar durante la ejecución
- Tienen un tipo de dato específico

**Analogía de la caja:**
Imagina que tienes cajas en tu habitación:
- Caja "edad": contiene el número 25
- Caja "nombre": contiene el texto "Pedro"
- Caja "esEstudiante": contiene verdadero o falso

**Reglas para nombrar variables:**
- Empezar con letra, _ o $
- No usar espacios
- No usar palabras reservadas de Java
- Usar nombres descriptivos`,
            examples: [
              'int edad = 25;',
              'String nombre = "Pedro";',
              'boolean esEstudiante = true;',
              'double altura = 1.75;'
            ]
          },
          {
            title: 'Página 2: Tipos de Datos Primitivos',
            content: `Java tiene varios **tipos de datos primitivos** para almacenar diferentes tipos de información:

**Tipos numéricos enteros:**
- **int**: Números enteros (-2,147,483,648 a 2,147,483,647)
- **long**: Números enteros muy grandes
- **short**: Números enteros pequeños
- **byte**: Números enteros muy pequeños

**Tipos numéricos decimales:**
- **double**: Números con decimales (precisión doble)
- **float**: Números con decimales (precisión simple)

**Otros tipos:**
- **boolean**: Verdadero (true) o falso (false)
- **char**: Un solo carácter ('A', '5', '@')

**Tipo de referencia:**
- **String**: Cadena de texto ("Hola mundo")`,
            examples: [
              'int puntuacion = 1500;',
              'double precio = 29.99;',
              'boolean juegoTerminado = false;',
              'char inicial = \'P\';',
              'String mensaje = "¡Felicidades!";'
            ]
          },
          {
            title: 'Página 3: Declaración y Asignación',
            content: `**Declaración**: Crear una variable especificando su tipo y nombre.
**Asignación**: Dar un valor a la variable.

**Formas de trabajar con variables:**

1. **Declarar y asignar por separado:**
\`\`\`java
int edad;        // Declaración
edad = 25;       // Asignación
\`\`\`

2. **Declarar y asignar en una línea:**
\`\`\`java
int edad = 25;   // Declaración + Asignación
\`\`\`

3. **Cambiar el valor:**
\`\`\`java
int edad = 25;
edad = 26;       // Nuevo valor
\`\`\`

**Operaciones con variables:**
- Suma: edad = edad + 1;
- Resta: vidas = vidas - 1;
- Multiplicación: total = precio * cantidad;
- División: promedio = suma / cantidad;`,
            examples: [
              'int vidas = 3; vidas = vidas - 1;',
              'String nombre = "Jugador"; nombre = "Pedro";',
              'double dinero = 100.0; dinero = dinero + 50.5;',
              'boolean activo = true; activo = false;'
            ]
          }
        ]
      }
    };

    // Actualizar misiones con teoría ampliada
    missionsData.forEach(mission => {
      if (enhancedTheories[mission.id]) {
        const enhanced = enhancedTheories[mission.id];
        mission.enhancedTheory = enhanced;
        mission.theory = enhanced.pages[0].content; // Mantener compatibilidad
        this.analysisReport.enhancedMissions.push(mission.id);
      }
    });
  }

  // Generar recomendaciones
  generateRecommendations() {
    console.log('💡 Generando recomendaciones...');
    
    this.analysisReport.recommendations = [
      {
        type: 'theory_enhancement',
        description: 'Se ha ampliado la teoría de las misiones principales con contenido paginado',
        impact: 'Alto',
        implementation: 'Teoría dividida en páginas más digestibles con ejemplos prácticos'
      },
      {
        type: 'question_alignment',
        description: 'Mejorar alineación entre teoría y preguntas en misiones con baja puntuación',
        impact: 'Medio',
        implementation: 'Añadir conceptos faltantes a la teoría o ajustar preguntas'
      },
      {
        type: 'progressive_learning',
        description: 'Implementar sistema de teoría progresiva con navegación entre páginas',
        impact: 'Alto',
        implementation: 'UI para navegar entre páginas de teoría con progreso visual'
      },
      {
        type: 'interactive_examples',
        description: 'Añadir ejemplos interactivos en cada página de teoría',
        impact: 'Medio',
        implementation: 'Código ejecutable en línea para cada ejemplo'
      }
    ];
  }

  // Actualizar datos en Firebase
  async updateFirebaseData() {
    console.log('🔥 Actualizando datos en Firebase...');
    
    try {
      // Actualizar misiones
      const batch = db.batch();
      
      for (const mission of missionsData) {
        const missionRef = db.collection('missions').doc(mission.id);
        batch.set(missionRef, mission, { merge: true });
      }
      
      // Actualizar preguntas
      for (const question of questionsData) {
        const questionRef = db.collection('questions').doc(question.id);
        batch.set(questionRef, question, { merge: true });
      }
      
      await batch.commit();
      console.log('✅ Datos actualizados en Firebase exitosamente');
      
    } catch (error) {
      console.error('❌ Error actualizando Firebase:', error);
      throw error;
    }
  }

  // Guardar archivos actualizados localmente
  saveUpdatedFiles() {
    console.log('💾 Guardando archivos actualizados...');
    
    // Guardar misiones actualizadas
    fs.writeFileSync(
      '../assets/data/missions_data_enhanced.json',
      JSON.stringify(missionsData, null, 2),
      'utf8'
    );
    
    // Guardar reporte de análisis
    fs.writeFileSync(
      '../assets/data/theory_analysis_report.json',
      JSON.stringify(this.analysisReport, null, 2),
      'utf8'
    );
    
    console.log('✅ Archivos guardados exitosamente');
  }

  // Generar reporte detallado
  generateDetailedReport() {
    console.log('\n📊 REPORTE DE ANÁLISIS DE TEORÍA Y PREGUNTAS');
    console.log('=' .repeat(60));
    
    console.log(`\n📈 ESTADÍSTICAS GENERALES:`);
    console.log(`- Misiones analizadas: ${this.analysisReport.missionsAnalyzed}`);
    console.log(`- Preguntas analizadas: ${this.analysisReport.questionsAnalyzed}`);
    console.log(`- Misiones mejoradas: ${this.analysisReport.enhancedMissions.length}`);
    console.log(`- Brechas de teoría encontradas: ${this.analysisReport.theoryGaps.length}`);
    
    if (this.analysisReport.theoryGaps.length > 0) {
      console.log(`\n⚠️  BRECHAS DE TEORÍA DETECTADAS:`);
      this.analysisReport.theoryGaps.forEach(gap => {
        console.log(`\n- Misión: ${gap.title} (${gap.missionId})`);
        console.log(`  Alineación: ${(gap.alignment * 100).toFixed(1)}%`);
        console.log(`  Conceptos faltantes: ${gap.missingConcepts.join(', ')}`);
      });
    }
    
    console.log(`\n🚀 MISIONES MEJORADAS:`);
    this.analysisReport.enhancedMissions.forEach(missionId => {
      const mission = missionsData.find(m => m.id === missionId);
      console.log(`- ${mission.title} (${missionId})`);
      if (mission.enhancedTheory) {
        console.log(`  Páginas de teoría: ${mission.enhancedTheory.pages.length}`);
      }
    });
    
    console.log(`\n💡 RECOMENDACIONES:`);
    this.analysisReport.recommendations.forEach((rec, index) => {
      console.log(`\n${index + 1}. ${rec.description}`);
      console.log(`   Impacto: ${rec.impact}`);
      console.log(`   Implementación: ${rec.implementation}`);
    });
    
    console.log('\n' + '=' .repeat(60));
    console.log('✅ Análisis completado exitosamente');
  }

  // Ejecutar análisis completo
  async runCompleteAnalysis() {
    try {
      console.log('🚀 Iniciando análisis completo de misiones y teoría...');
      
      this.analyzeTheoryQuestionAlignment();
      this.enhanceTheory();
      this.generateRecommendations();
      this.saveUpdatedFiles();
      
      // Preguntar si actualizar Firebase
      const readline = require('readline');
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
      });
      
      rl.question('¿Deseas actualizar los datos en Firebase? (s/n): ', async (answer) => {
        if (answer.toLowerCase() === 's' || answer.toLowerCase() === 'si') {
          await this.updateFirebaseData();
        }
        
        this.generateDetailedReport();
        rl.close();
      });
      
    } catch (error) {
      console.error('❌ Error durante el análisis:', error);
      process.exit(1);
    }
  }
}

// Ejecutar el análisis
if (require.main === module) {
  const analyzer = new MissionTheoryAnalyzer();
  analyzer.runCompleteAnalysis();
}

module.exports = MissionTheoryAnalyzer;