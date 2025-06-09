# 🎮 CodeQuest

**CodeQuest** es un juego educativo desarrollado en Flutter que enseña programación a través de misiones interactivas, batallas y ejercicios de código. Los jugadores aprenden conceptos de programación mientras avanzan a través de un mundo de fantasía lleno de desafíos y aventuras.

## 🌟 Características Principales

### 🎯 Sistema de Misiones
- **Misiones de Teoría**: Aprende conceptos de programación fundamentales
- **Misiones de Batalla**: Pon a prueba tus conocimientos en combates épicos
- **Progresión por Niveles**: Desbloquea nuevos contenidos al completar misiones
- **Sistema de Experiencia**: Gana XP y sube de nivel tu personaje

### ⚔️ Sistema de Batallas
- **Encuentros con Enemigos**: Enfréntate a diversos oponentes
- **Preguntas de Programación**: Responde correctamente para derrotar enemigos
- **Mecánicas de Combate**: Vida, daño y habilidades especiales
- **Recompensas**: Gana monedas y experiencia por victorias

### 💻 Playground de Código
- **Editor Interactivo**: Escribe y ejecuta código en tiempo real
- **Ejercicios Prácticos**: Resuelve problemas de programación paso a paso
- **Validación Automática**: Comprueba si tu código es correcto
- **Múltiples Lenguajes**: Soporte para diferentes lenguajes de programación

### 🏆 Sistema de Progresión
- **Tabla de Clasificación**: Compite con otros jugadores
- **Logros**: Desbloquea logros especiales por tus hazañas
- **Inventario**: Gestiona tus objetos y recompensas
- **Tienda**: Compra mejoras y objetos especiales con monedas

### 👤 Gestión de Personajes
- **Selección de Personajes**: Elige tu avatar favorito
- **Personalización**: Mejora las habilidades de tu personaje
- **Estadísticas**: Seguimiento detallado de tu progreso

## 🚀 Instalación y Configuración

### Prerequisitos

- [Flutter](https://flutter.dev/docs/get-started/install) (versión 3.0 o superior)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- Cuenta de [Firebase](https://firebase.google.com/) (para funciones en línea)

### Configuración del Proyecto

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/tuusuario/CodeQuest.git
   cd CodeQuest
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura Firebase**
   - Crea un nuevo proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Habilita Authentication (Email/Password)
   - Habilita Firestore Database
   - Descarga el archivo `google-services.json` (Android) y colócalo en `android/app/`
   - Descarga el archivo `GoogleService-Info.plist` (iOS) y colócalo en `ios/Runner/`

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

### Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  provider: ^6.1.1
  http: ^1.1.2
  shared_preferences: ^2.2.2
  flutter_animate: ^4.5.0
  google_fonts: ^6.1.0
```

## 🎮 Cómo Jugar

### Primeros Pasos
1. **Registro**: Crea una cuenta con tu email o nombre de usuario
2. **Tutorial**: Completa el tutorial interactivo para aprender los controles
3. **Selección de Personaje**: Elige tu avatar y personalízalo
4. **Primera Misión**: Comienza con las misiones básicas de programación

### Mecánicas de Juego

#### 📚 Aprendizaje
- Lee las teorías de programación en las misiones de teoría
- Practica conceptos en el playground de código
- Resuelve ejercicios progresivos de dificultad creciente

#### ⚔️ Combate
- Encuentra enemigos en tu aventura
- Responde preguntas de programación para atacar
- Gestiona tu vida y recursos durante las batallas
- Derrota jefes para obtener recompensas especiales

#### 🏅 Progresión
- Gana experiencia completando misiones y derrotando enemigos
- Sube de nivel para desbloquear nuevas áreas y habilidades
- Colecciona logros completando desafíos especiales
- Compra mejoras en la tienda con las monedas ganadas

## 🏗️ Arquitectura del Proyecto

### Estructura de Directorios

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── user.dart
│   ├── mission.dart
│   ├── enemy.dart
│   ├── achievement.dart
│   └── inventory_item.dart
├── screens/                  # Pantallas de la aplicación
│   ├── auth/                # Autenticación
│   ├── game/                # Pantallas de juego
│   ├── missions/            # Sistema de misiones
│   └── ui/                  # Interfaz principal
├── services/                 # Servicios y lógica de negocio
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── mission_service.dart
│   ├── battle_service.dart
│   └── tutorial_service.dart
├── widgets/                  # Componentes reutilizables
│   ├── code_playground.dart
│   ├── mission_card.dart
│   └── enemy_card.dart
└── utils/                    # Utilidades y constantes
    ├── constants.dart
    └── validators.dart
```

### Tecnologías Utilizadas

- **Frontend**: Flutter & Dart
- **Backend**: Firebase (Authentication, Firestore)
- **Estado**: Provider Pattern
- **UI**: Material Design con tema personalizado
- **Animaciones**: Flutter Animate
- **Tipografía**: Google Fonts
- **Persistencia Local**: SharedPreferences

## 🔥 Funcionalidades de Firebase

### Authentication
- Registro con email y contraseña
- Inicio de sesión
- Recuperación de contraseña
- Validación de email único

### Firestore Database
- Almacenamiento de datos de usuario
- Progreso de misiones
- Estadísticas de juego
- Tabla de clasificación global
- Sistema de logros

### Estructura de Datos

```
users/
  {userId}/
    - email: string
    - username: string
    - level: number
    - experience: number
    - coins: number
    - selectedCharacter: string
    - completedMissions: array
    - achievements: array
    - inventory: array

missions/
  {missionId}/
    - title: string
    - description: string
    - type: string (theory/battle)
    - difficulty: number
    - content: object

leaderboard/
  {userId}/
    - username: string
    - level: number
    - totalScore: number
```

## 🎨 Temas y Diseño

El juego utiliza un tema visual pixel-art con:
- **Paleta de Colores**: Tonos fantasía con acentos vibrantes
- **Tipografía**: Google Fonts para una lectura clara
- **Iconografía**: Iconos temáticos de programación y fantasía
- **Animaciones**: Transiciones fluidas y efectos visuales

## 🧪 Testing

```bash
# Ejecutar todas las pruebas
flutter test

# Pruebas específicas
flutter test test/models/
flutter test test/services/
flutter test test/widgets/
```

## 📱 Plataformas Soportadas

- ✅ Android (API 21+)
- ✅ iOS (iOS 11.0+)
- 🔄 Web (en desarrollo)
- 🔄 Desktop (planificado)

## 🤝 Contribuir

1. **Fork** el proyecto
2. Crea una **rama** para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. Abre un **Pull Request**

### Directrices de Contribución

- Sigue las convenciones de código de Dart/Flutter
- Escribe tests para nuevas funcionalidades
- Actualiza la documentación si es necesario
- Mantén commits claros y descriptivos

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo de Desarrollo

- **Desarrollador Principal**: [Tu Nombre]
- **Diseño UI/UX**: [Nombre del Diseñador]
- **Content Creator**: [Nombre del Creador de Contenido]

## 📞 Contacto

- **Email**: contact@codequest.dev
- **GitHub**: [https://github.com/tuusuario/CodeQuest](https://github.com/tuusuario/CodeQuest)
- **Discord**: [Servidor de CodeQuest](https://discord.gg/codequest)

## 🔮 Roadmap

### Versión 1.1
- [ ] Modo multijugador
- [ ] Nuevos lenguajes de programación
- [ ] Sistema de clanes/guilds
- [ ] Misiones diarias

### Versión 1.2
- [ ] Editor de código avanzado
- [ ] Modo sandbox
- [ ] Compartir creaciones
- [ ] Torneos competitivos

### Versión 2.0
- [ ] Realidad aumentada
- [ ] IA personalizada para tutorías
- [ ] Certificaciones oficiales
- [ ] Marketplace de contenido

---

**¡Únete a la aventura de aprender programación con CodeQuest!** 🚀

*"Donde el código se convierte en aventura"*
