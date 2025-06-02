# Script de Backup de Firebase

## Descripción
Este script descarga todos los datos de las colecciones de Firebase y los guarda en archivos JSON separados en la carpeta `assets/data/`.

## Requisitos previos

1. **Archivo de credenciales**: Necesitas el archivo `serviceAccountKey.json` en la carpeta `assets/data/`
   - Ve a Firebase Console
   - Project Settings > Service Accounts
   - Generate new private key
   - Guarda el archivo como `serviceAccountKey.json` en `assets/data/`

2. **Dependencias**: Asegúrate de que las dependencias estén instaladas
   ```bash
   cd scripts
   npm install
   ```

## Uso

```bash
# Desde la carpeta scripts
cd scripts
node backup_firebase_data.js
```

## Qué hace el script

1. Se conecta a Firebase usando las credenciales
2. Descarga las siguientes colecciones:
   - `missions` → `missions_data.json`
   - `questions` → `questions.json`
   - `achievements` → `achievements_data.json`
   - `enemies` → `enemies_data.json`
   - `items` → `items_data.json`
   - `rewards` → `rewards_data.json`
   - `code_exercises` → `code_exercises.json`
   - `users` → `users_data.json`
   - `leaderboard` → `leaderboard_data.json`
   - `user_progress` → `user_progress_data.json`
   - `battle_results` → `battle_results_data.json`

3. Guarda cada colección en un archivo JSON separado en `assets/data/`
4. Muestra un resumen del proceso

## Estructura de archivos resultante

```
assets/data/
├── missions_backup.json      # Backup manual existente
├── missions_data.json        # Datos actuales de misiones
├── questions.json           # Preguntas
├── achievements_data.json   # Logros
├── enemies_data.json        # Enemigos
├── items_data.json          # Objetos/Items
├── rewards_data.json        # Recompensas
├── code_exercises.json      # Ejercicios de código
├── users_data.json          # Datos de usuarios
├── leaderboard_data.json    # Tabla de clasificación
├── user_progress_data.json  # Progreso de usuarios
├── battle_results_data.json # Resultados de batallas
└── serviceAccountKey.json   # Credenciales (no subir a git)
```

## Notas importantes

- El archivo `serviceAccountKey.json` contiene credenciales sensibles y **NO debe subirse a git**
- Asegúrate de que esté en `.gitignore`
- El script sobrescribe los archivos existentes en `assets/data/`
- Cada archivo incluye el ID del documento y todos sus datos

## Solución de problemas

### Error: "serviceAccountKey.json no encontrado"
- Verifica que el archivo esté en `assets/data/serviceAccountKey.json`
- Verifica que el archivo tenga el formato JSON correcto

### Error de conexión a Firebase
- Verifica que las credenciales sean correctas
- Verifica que el proyecto de Firebase esté activo
- Verifica tu conexión a internet

### Error de permisos
- Verifica que la cuenta de servicio tenga permisos de lectura en Firestore