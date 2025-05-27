const fs = require('fs');
const path = require('path');

// Leer datos actuales
const missionsPath = path.join(__dirname, 'assets', 'data', 'missions_data.json');
const questionsPath = path.join(__dirname, 'assets', 'data', 'questions.json');

const missions = JSON.parse(fs.readFileSync(missionsPath, 'utf8'));
const questions = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));

// Preguntas reorganizadas por nivel de dificultad
const reorganizedQuestions = [
  // NIVEL 1: Conceptos básicos de programación
  {
    "id": "pregunta_que_es_programar",
    "text": "¿Qué significa 'programar' un ordenador?",
    "options": [
      "Encender y apagar el ordenador",
      "Darle instrucciones paso a paso para que haga algo específico",
      "Cambiar el color de la pantalla",
      "Conectarlo a internet"
    ],
    "correctAnswerIndex": 1,
    "explanation": "Programar es como enseñarle al ordenador cómo resolver un problema o realizar una tarea, escribiendo las instrucciones en un lenguaje que él pueda entender.",
    "difficulty": 1
  },
  {
    "id": "pregunta_que_es_un_programa",
    "text": "¿Qué es un 'programa' en el contexto de la programación?",
    "options": [
      "Un dibujo de un ordenador",
      "Un conjunto de instrucciones para que el ordenador realice una tarea",
      "Un tipo de música",
      "Un juego de mesa"
    ],
    "correctAnswerIndex": 1,
    "explanation": "Un programa es precisamente eso: una serie de pasos detallados que le decimos a una máquina para que la ejecute y logre un objetivo.",
    "difficulty": 1
  },
  {
    "id": "pregunta_por_que_java",
    "text": "¿Por qué Java es un buen lenguaje para aprender programación?",
    "options": [
      "Porque es muy difícil",
      "Porque solo funciona en un ordenador",
      "Porque es fácil de leer y funciona en muchos tipos de ordenadores",
      "Porque es muy antiguo"
    ],
    "correctAnswerIndex": 2,
    "explanation": "Java fue diseñado para ser claro y comprensible, y tiene la ventaja de que un programa escrito en Java puede ejecutarse en Windows, Mac, Linux y otros sistemas sin cambios.",
    "difficulty": 1
  },
  
  // NIVEL 2: Variables y tipos de datos básicos
  {
    "id": "pregunta_que_es_una_variable",
    "text": "En programación, ¿qué es una 'variable'?",
    "options": [
      "Un error en el código",
      "Una caja de almacenamiento en la memoria del ordenador que guarda un valor que puede cambiar",
      "Un programa completo",
      "Un tipo de teclado"
    ],
    "correctAnswerIndex": 1,
    "explanation": "Las variables son esenciales en programación porque nos permiten almacenar y manipular información mientras el programa se ejecuta, como la puntuación de un juego o el nombre de un usuario.",
    "difficulty": 2
  },
  {
    "id": "pregunta_tipo_dato_edad_java",
    "text": "Si necesitas guardar la edad de una persona (por ejemplo, 25) en una variable en Java, ¿cuál es el tipo de dato más adecuado?",
    "options": [
      "double",
      "boolean",
      "int",
      "String"
    ],
    "correctAnswerIndex": 2,
    "explanation": "El tipo int (de 'integer') se utiliza para números enteros, y la edad de una persona es típicamente un número entero sin decimales.",
    "difficulty": 2
  },
  {
    "id": "pregunta_declaracion_variable_entera_java",
    "text": "¿Cuál de las siguientes líneas declara correctamente una variable entera llamada puntuacion y le asigna un valor inicial de 100 en Java?",
    "options": [
      "puntuacion = 100;",
      "int puntuacion;",
      "int puntuacion = 100;",
      "Puntuacion int = 100;"
    ],
    "correctAnswerIndex": 2,
    "explanation": "Esta línea declara una variable de tipo entero (int), la nombra puntuacion, y le asigna el valor 100 en el mismo momento.",
    "difficulty": 2
  },
  
  // NIVEL 3: Instrucciones básicas y estructura
  {
    "id": "pregunta_instruccion_hola_mundo_java",
    "text": "¿Cuál es la instrucción correcta en Java para mostrar el mensaje 'Hola Mundo' en la consola?",
    "options": [
      "print(\"Hola Mundo\");",
      "System.in.println(\"Hola Mundo\");",
      "System.out.println(\"Hola Mundo\");",
      "console.log(\"Hola Mundo\");"
    ],
    "correctAnswerIndex": 2,
    "explanation": "Esta es la sintaxis estándar en Java para imprimir texto en la consola de salida y añadir un salto de línea al final.",
    "difficulty": 3
  },
  {
    "id": "pregunta_estructura_principal_java_clase_main",
    "text": "En Java, ¿dentro de qué estructura principal se organiza el código y dónde se encuentra el método main?",
    "options": [
      "Un archivo de texto",
      "Una carpeta",
      "Una clase",
      "Una función"
    ],
    "correctAnswerIndex": 2,
    "explanation": "En Java, todo el código debe estar encapsulado dentro de una clase, incluyendo el método main que es el punto de inicio del programa.",
    "difficulty": 3
  },
  {
    "id": "pregunta_error_sintaxis_comun",
    "text": "¿Cuál es un error de sintaxis muy común en Java que impide que el código compile?",
    "options": [
      "Usar demasiados espacios",
      "Olvidar un punto y coma al final de una instrucción",
      "Escribir comentarios muy largos",
      "Nombrar una variable con mayúsculas"
    ],
    "correctAnswerIndex": 1,
    "explanation": "El punto y coma (;) es crucial en Java para indicar el final de una instrucción. Olvidarlo es una de las causas más frecuentes de errores de compilación.",
    "difficulty": 3
  }
];

// Misiones reorganizadas con progresión pedagógica
const reorganizedMissions = [
  {
    "id": "mision_1_1",
    "title": "El Despertar del Guardián",
    "description": "Descubre tu destino como Guardián del Código y aprende qué es la programación.",
    "zone": "Bosque de los Algoritmos",
    "levelRequired": 1,
    "status": "disponible",
    "isRepeatable": false,
    "rewards": {
      "experience": 30,
      "coins": 20,
      "items": [],
      "unlocks": ["mision_1_2"]
    },
    "storyPages": [
      {
        "pageNumber": 1,
        "title": "El Despertar del Guardián",
        "text": "En las brumas del amanecer, te despiertas en el corazón de Algorithmia. El aire vibra con energía digital, y puedes sentir que algo terrible ha perturbado el equilibrio del reino. Los Errores Sintácticos han comenzado a corromper el Código Fuente.\n\nComo nuevo Guardián del Código, tu misión es clara: debes aprender las artes ancestrales de la programación para restaurar el orden.",
        "imageUrl": ""
      }
    ],
    "order": 1,
    "theory": "La programación es el arte de comunicarse con las máquinas. Imagina que eres un mago que puede hablar con los ordenadores y darles órdenes para que hagan cosas increíbles.\n\nUn programa es como una receta de cocina muy detallada: una lista de pasos que le decimos al ordenador para que realice una tarea. Por ejemplo, podríamos crear un programa que calcule cuánto dinero necesitas ahorrar cada mes para comprar algo especial.\n\nJava es uno de los lenguajes de programación más populares del mundo. Lo especial de Java es que es como un idioma universal: un programa escrito en Java puede funcionar en casi cualquier ordenador.",
    "objectives": [
      {
        "type": "theory",
        "description": "Completa la lección teórica sobre programación básica.",
        "target": 1
      },
      {
        "type": "questions",
        "description": "Responde correctamente 3 preguntas sobre programación.",
        "target": 3,
        "questionIds": [
          "pregunta_que_es_programar",
          "pregunta_que_es_un_programa",
          "pregunta_por_que_java"
        ]
      }
    ]
  },
  {
    "id": "mision_1_2",
    "title": "Los Secretos de las Variables",
    "description": "Aprende a manejar las variables, los contenedores mágicos que guardan información.",
    "zone": "Bosque de los Algoritmos",
    "levelRequired": 1,
    "status": "bloqueada",
    "isRepeatable": false,
    "requirements": {
      "completedMissionId": "mision_1_1"
    },
    "rewards": {
      "experience": 35,
      "coins": 25,
      "items": [],
      "unlocks": ["mision_1_3"]
    },
    "order": 2,
    "theory": "En Algorithmia, los magos programadores descubrieron que necesitaban cajas especiales para guardar información. Estas cajas mágicas se llaman 'variables' y pueden contener diferentes tipos de tesoros.\n\nImagina que tienes diferentes tipos de cajas:\n• Una caja para números enteros (como tu edad: 15, 20, 100)\n• Una caja para palabras y frases (como tu nombre: 'María', 'Hola mundo')\n• Una caja para números con decimales (como tu altura: 1.65, 3.14)\n• Una caja para respuestas de sí o no (como: verdadero, falso)\n\nEn Java, antes de usar una caja (variable), debemos decirle qué tipo de tesoro va a guardar.",
    "objectives": [
      {
        "type": "theory",
        "description": "Aprende sobre variables y tipos de datos.",
        "target": 1
      },
      {
        "type": "questions",
        "description": "Responde correctamente 3 preguntas sobre variables.",
        "target": 3,
        "questionIds": [
          "pregunta_que_es_una_variable",
          "pregunta_tipo_dato_edad_java",
          "pregunta_declaracion_variable_entera_java"
        ]
      }
    ]
  },
  {
    "id": "mision_1_3",
    "title": "El Arte de las Instrucciones",
    "description": "Domina las instrucciones básicas y aprende a crear tu primer programa completo en Java.",
    "zone": "Bosque de los Algoritmos",
    "levelRequired": 1,
    "status": "bloqueada",
    "isRepeatable": false,
    "requirements": {
      "completedMissionId": "mision_1_2"
    },
    "rewards": {
      "experience": 40,
      "coins": 30,
      "items": [],
      "unlocks": ["mision_batalla_1_1"]
    },
    "order": 3,
    "theory": "En el corazón de todo programa Java reside el método main, el punto de entrada donde comienza la ejecución del hechizo. Como un portal mágico, este método especial es donde el sistema invoca tu programa.\n\nLas instrucciones en Java son como conjuros individuales que se ejecutan uno tras otro. System.out.println() es uno de los hechizos más fundamentales, permitiendo que tu programa se comunique con el mundo exterior mostrando mensajes en la consola.\n\nCada instrucción debe terminar con un punto y coma, como el sello final de un conjuro.",
    "objectives": [
      {
        "type": "theory",
        "description": "Aprende sobre instrucciones y estructura de programas.",
        "target": 1
      },
      {
        "type": "questions",
        "description": "Responde correctamente 3 preguntas sobre instrucciones.",
        "target": 3,
        "questionIds": [
          "pregunta_instruccion_hola_mundo_java",
          "pregunta_estructura_principal_java_clase_main",
          "pregunta_error_sintaxis_comun"
        ]
      }
    ]
  },
  {
    "id": "mision_batalla_1_1",
    "title": "Batalla: El Bug del Punto y Coma",
    "description": "Enfrenta tu primera batalla contra las fuerzas corruptoras. Derrota al Bug del Punto y Coma con tus conocimientos básicos.",
    "zone": "Campo de Batalla",
    "levelRequired": 1,
    "status": "bloqueada",
    "isRepeatable": true,
    "requirements": {
      "completedMissionId": "mision_1_3"
    },
    "objectives": [
      {
        "type": "batalla",
        "description": "Derrota al Bug del Punto y Coma respondiendo preguntas básicas.",
        "target": 1,
        "battleConfig": {
          "enemyId": "enemigo_bug_del_punto_y_coma",
          "questionIds": [
            "pregunta_que_es_programar",
            "pregunta_que_es_un_programa",
            "pregunta_por_que_java"
          ],
          "playerHealthMultiplier": 1,
          "enemyAttackMultiplier": 0.8,
          "environment": "campo_bug"
        }
      }
    ],
    "rewards": {
      "experience": 50,
      "coins": 40,
      "items": [],
      "unlocks": ["mision_2_1"]
    },
    "order": 4
  }
];

// Guardar datos reorganizados
fs.writeFileSync(
  path.join(__dirname, 'assets', 'data', 'missions_reorganized_pedagogical.json'),
  JSON.stringify(reorganizedMissions, null, 2)
);

fs.writeFileSync(
  path.join(__dirname, 'assets', 'data', 'questions_reorganized_pedagogical.json'),
  JSON.stringify(reorganizedQuestions, null, 2)
);

console.log('✅ Datos reorganizados guardados localmente');
console.log('📁 Archivos creados:');
console.log('  - missions_reorganized_pedagogical.json');
console.log('  - questions_reorganized_pedagogical.json');
console.log('\n📚 Progresión pedagógica implementada:');
console.log('  Nivel 1: Conceptos básicos de programación');
console.log('  Nivel 2: Variables y tipos de datos');
console.log('  Nivel 3: Instrucciones y estructura básica');
console.log('\n🎯 Primera batalla ahora usa solo preguntas de nivel básico');