# Scripts de CodeQuest

## Importar Datos a Firebase

Para importar todos los datos JSON de la carpeta `assets/data` a Firebase Firestore, sigue estos pasos:

1. Asegúrate de que tienes instalado Node.js en tu sistema
2. Verifica que el archivo `scripts/serviceAccountKey.json` contiene las credenciales válidas de Firebase
3. Ejecuta el siguiente comando en la terminal:

```
node scripts/importar_datos.js
```

Este script importará los siguientes datos:
- Preguntas (`questions.json`) 
- Ítems (`items_data.json`)
- Misiones (`missions_data.json`)
- Enemigos (`enemies_data.json`)
- Logros (`achievements_data.json`)
- Recompensas (`rewards_data.json`)

### Solución de problemas

Si encuentras algún error durante la importación:

1. Verifica que todos los archivos JSON son válidos
2. Asegúrate de que cada objeto en los archivos JSON tiene un campo `id`
3. Revisa las reglas de seguridad de Firestore para asegurarte de que permiten escritura desde el SDK de administración
