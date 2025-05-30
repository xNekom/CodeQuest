# Scripts de Análisis y Mejora de CodeQuest

Este directorio contiene scripts para analizar y mejorar los datos de las misiones y preguntas de CodeQuest.

## 📋 Scripts Disponibles

### 1. `verify_and_enhance_missions.js`
**Propósito**: Script completo para verificar, analizar y mejorar los datos de misiones y teoría.

**Funcionalidades**:
- ✅ Analiza la alineación entre teoría y preguntas
- 📚 Amplía automáticamente la teoría con contenido paginado
- 🔍 Detecta brechas en el contenido teórico
- 🔥 Actualiza datos en Firebase (opcional)
- 📊 Genera reportes detallados
- 💡 Proporciona recomendaciones de mejora

**Uso**:
```bash
cd scripts
npm install
node verify_and_enhance_missions.js
```

**Características especiales**:
- Teoría paginada para mejor digestión del contenido
- Ejemplos prácticos en cada página
- Navegación progresiva del aprendizaje
- Actualización segura de Firebase con confirmación

### 2. `analyze_theory_alignment.js`
**Propósito**: Script de análisis rápido sin modificaciones, ideal para desarrollo y testing.

**Funcionalidades**:
- 🔍 Analiza alineación entre teoría y preguntas
- 📈 Calcula métricas de cobertura y alineación
- 📋 Genera reportes detallados por misión
- 💾 Guarda reportes en formato JSON
- ⚠️ Identifica problemas sin hacer cambios

**Uso**:
```bash
cd scripts
node analyze_theory_alignment.js
```

**Ventajas**:
- Ejecución rápida
- No modifica datos existentes
- Ideal para análisis frecuentes
- Reportes detallados por misión

## 🚀 Instalación y Configuración

### Prerrequisitos
- Node.js (versión 14 o superior)
- Acceso a Firebase (para el script completo)
- Archivo `serviceAccountKey.json` en `assets/data/`

### Instalación
```bash
cd scripts
npm install
```

### Configuración de Firebase
1. Asegúrate de tener el archivo `serviceAccountKey.json` en `assets/data/`
2. Verifica que las reglas de Firestore permitan escritura
3. Confirma la URL de la base de datos en el script

## 📊 Métricas y Análisis

### Puntuación de Alineación
- **90-100%**: Excelente alineación
- **70-89%**: Buena alineación
- **50-69%**: Alineación regular (requiere mejoras)
- **<50%**: Alineación deficiente (requiere revisión urgente)

### Cobertura Teórica
- **Cobertura**: % de temas de las preguntas cubiertos en la teoría
- **Temas faltantes**: Conceptos en preguntas pero no en teoría
- **Temas extra**: Conceptos en teoría pero no evaluados

### Temas Analizados
- **Fundamentos**: Conceptos básicos de programación
- **Java Básico**: JVM, multiplataforma, bytecode
- **Estructura**: Clases, métodos, main
- **Variables**: Tipos de datos, declaración
- **Operadores**: Operaciones matemáticas
- **Control de Flujo**: if/else, bucles
- **Arrays**: Arreglos y colecciones
- **POO**: Programación orientada a objetos
- **Excepciones**: Manejo de errores
- **Sintaxis**: Reglas del lenguaje
- **Entrada/Salida**: Interacción con usuario

## 📁 Archivos Generados

### Por `verify_and_enhance_missions.js`:
- `missions_data_enhanced.json`: Misiones con teoría ampliada
- `theory_analysis_report.json`: Reporte completo de análisis

### Por `analyze_theory_alignment.js`:
- `theory_alignment_report.json`: Reporte de alineación detallado

## 🔧 Personalización

### Añadir Nuevos Temas
En `extractTopicsFromText()`, añade nuevas entradas al objeto `topicKeywords`:

```javascript
const topicKeywords = {
  'nuevo_tema': ['palabra1', 'palabra2', 'palabra3'],
  // ... otros temas
};
```

### Modificar Umbrales
Cambia los umbrales de alineación en las funciones de análisis:

```javascript
if (alignment < 0.7) { // Cambiar umbral aquí
  // Lógica para baja alineación
}
```

### Ampliar Teoría
En `enhanceTheory()`, añade nuevas misiones al objeto `enhancedTheories`:

```javascript
const enhancedTheories = {
  'nueva_mision_id': {
    title: 'Título de la Teoría',
    pages: [
      {
        title: 'Página 1: Concepto Principal',
        content: 'Contenido detallado...',
        examples: ['Ejemplo 1', 'Ejemplo 2']
      }
    ]
  }
};
```

## 🐛 Solución de Problemas

### Error de Firebase
```
Error: Could not load the default credentials
```
**Solución**: Verifica que `serviceAccountKey.json` esté en la ubicación correcta.

### Error de Módulos
```
Error: Cannot find module 'firebase-admin'
```
**Solución**: Ejecuta `npm install` en el directorio scripts.

### Datos No Encontrados
```
Error: ENOENT: no such file or directory
```
**Solución**: Verifica que los archivos JSON estén en `assets/data/`.

## 📈 Mejores Prácticas

1. **Ejecuta análisis regularmente**: Usa `analyze_theory_alignment.js` frecuentemente
2. **Revisa reportes**: Analiza las métricas antes de hacer cambios
3. **Backup antes de Firebase**: Siempre respalda antes de actualizar
4. **Prueba localmente**: Verifica cambios antes de subir a producción
5. **Documenta cambios**: Mantén registro de modificaciones importantes

## 🤝 Contribución

Para contribuir con mejoras a los scripts:

1. Crea una rama para tu feature
2. Añade tests si es necesario
3. Documenta cambios en este README
4. Envía pull request con descripción detallada

## 📞 Soporte

Si encuentras problemas o tienes sugerencias:
- Revisa la sección de solución de problemas
- Verifica los logs de error
- Consulta la documentación de Firebase
- Contacta al equipo de desarrollo

---

**Última actualización**: $(date)
**Versión**: 1.0.0
**Mantenedor**: Equipo CodeQuest