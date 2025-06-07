# Reglas de Optimización para Respuestas Flutter - v2024

## 1. Priorizar la Utilidad - Resolver el Problema Real
- **Identificar causas raíz**: Ir más allá de los síntomas, encontrar la fuente del problema
- **Soluciones completas**: Incluir dependencias, configuración y código necesario para ejecutar inmediatamente
- **Explicaciones del "porqué"**: Justificar por qué es la mejor práctica, no solo mostrar el "cómo"

## 2. Precisión y Veracidad - Código Actualizado
- **Sintaxis moderna**: Usar Dart 3+ y Flutter 3.16+, evitar código obsoleto
- **Compatibilidad verificada**: Asegurar que paquetes y librerías sean compatibles entre sí
- **Validación de lógica**: Verificar orden de llamadas (initState/dispose), evitar efectos secundarios

## 3. Claridad y Concisión - Explicaciones que Educaban
- **Código + Contexto**: Cada fragmento debe incluir explicación del problema que resuelve
- **Ejemplos concretos**: "Widget no se actualiza" → "setState() no está en el widget con estado correcto"
- **Errores de diseño**: "Overflow en Row" → explicar restricciones de tamaño y solucionar con Expanded/Flexible

## 4. Prevención de Errores Comunes
- **Null Safety**: Preferir `?` y `late` sobre `!` para evitar runtime errors
- **Gestión de Estado**: Detectar widgets ineficientes y recomendar patrones apropiados (Provider, Riverpod, Bloc)
- **Async/Await**: Verificar manejo correcto de estados en FutureBuilder/StreamBuilder (loading, error, data)

## 5. Errores Específicos y Soluciones 2024

### 5.1 Errores de Deprecación de Flutter 3.16+

#### ✅ Radio/RadioListTile Obsoletos
**Error**: `groupValue` y `onChanged` están obsoletos en Flutter 3.32+
**Solución moderna**: Crear widget personalizado sin dependencias obsoletas

```dart
// ❌ INCORRECTO - Parámetros obsoletos
RadioListTile<String>(
  title: Text('Opción'),
  value: 'value',
  groupValue: selectedValue,    // ⚠️ Obsoleto
  onChanged: (value) {},       // ⚠️ Obsoleto
)

// ✅ CORRECTO - Widget personalizado moderno
Widget _buildModernRadio(String title, String value, String groupValue, ValueChanged<String> onChanged) {
  final isSelected = value == groupValue;
  return InkWell(
    onTap: () => onChanged(value),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? primaryColor : Colors.grey),
              color: isSelected ? primaryColor : Colors.transparent,
            ),
            child: isSelected ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white))) : null,
          ),
          SizedBox(width: 12),
          Text(title, style: TextStyle(color: isSelected ? primaryColor : null)),
        ],
      ),
    ),
  );
}
```

#### ✅ PopScope Actualizado
**Error**: `onPopInvoked` está obsoleto
**Solución**: Usar `onPopInvokedWithResult`

```dart
// ❌ Obsoleto
PopScope(
  canPop: false,
  onPopInvoked: (didPop) => _handlePop(),
)

// ✅ Actualizado
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) => _handlePop(),
)
```

### 5.2 Errores de Sintaxis y Compilación

#### ✅ Manejo de Tipos Nullable
**Error**: `A value of type 'Offset?' can't be returned`
**Solución**: Usar tipos no-nullable con validación

```dart
// ❌ INCORRECTO
Offset? calculatePosition() {
  return someValue as Offset?; // Error de tipo
}

// ✅ CORRECTO
Offset calculatePosition() {
  final value = someValue;
  if (value == null) {
    return Offset.zero; // Fallback seguro
  }
  return value as Offset;
}
```

#### ✅ Estructura de Archivo Segura
**Error**: Código suelto fuera de clases
**Solución**: Todo el código debe estar dentro de clases o funciones

```dart
// ❌ INCORRECTO - Código suelto
var globalVariable = "esto causará errores";

// ✅ CORRECTO - Dentro de clase
class MyWidget extends StatelessWidget {
  final String variable = "correcto";
  
  @override
  Widget build(BuildContext context) {
    return Text(variable);
  }
}
```

### 5.3 Errores de Layout y Posicionamiento

#### ✅ Sistema de Posicionamiento Defensivo
**Implementación completa con fallback seguro:**

```dart
Offset _calculateTooltipPosition(Size screenSize) {
  const double margin = 20.0;
  const double tooltipWidth = 300.0;
  const double tooltipHeight = 200.0;

  // Fallback inmediato si no hay target
  if (_targetRect == null) {
    return Offset(
      (screenSize.width - tooltipWidth) / 2,
      (screenSize.height - tooltipHeight) / 2,
    );
  }

  final targetRect = _targetRect!;
  
  // Cálculo seguro con límites
  double left = targetRect.left.clamp(margin, screenSize.width - tooltipWidth - margin);
  double top = (targetRect.bottom + 10).clamp(margin, screenSize.height - tooltipHeight - margin);
  
  return Offset(left, top);
}
```

#### ✅ Scroll Automático Defensivo
```dart
Future<void> _ensureTargetVisible() async {
  if (!mounted) return;

  try {
    final targetContext = _targetKey?.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        setState(() => _targetRect = _getWidgetBounds(targetContext));
      }
    }
  } catch (e) {
    debugPrint('Error scroll: $e');
  }
}
```

## 6. Validación Inmediata - Checklist

### ✅ Antes de Finalizar Cualquier Cambio
- [ ] Ejecutar `flutter analyze` - debe mostrar 0 issues
- [ ] Verificar `flutter run` compila sin errores
- [ ] Probar en al menos 2 plataformas (web + móvil)
- [ ] Validar que no hay código suelto fuera de clases
- [ ] Confirmar que todos los widgets actualizan correctamente

### ✅ Testing Visual
```bash
# Comandos de validación
flutter analyze --no-pub
flutter run -d chrome --debug
flutter run -d [device_id] --debug
```

## 7. Patrones de Código Seguros

### ✅ Gestión de Estado Local
```dart
// Estado con validación
class _TutorialState extends State<TutorialScreen> {
  Rect? _targetRect;
  
  void updateTargetRect(Rect? rect) {
    if (mounted && rect != _targetRect) {
      setState(() => _targetRect = rect);
    }
  }
}
```

### ✅ Prevención de Memory Leaks
```dart
@override
void dispose() {
  _scrollController?.dispose();
  _animationController?.dispose();
  super.dispose();
}
```

### ✅ Manejo de Errores Defensivo
```dart
T? safeGet<T>(T? value, T fallback) {
  return value ?? fallback;
}

// Uso:
final position = safeGet(calculatePosition(), Offset.zero);
```

### 5.4 Errores de Flutter Analyze - Validación Estática

**Problema:** `flutter analyze` detecta errores de sintaxis y código no utilizado.

**Errores Comunes y Soluciones:**

#### ✅ Parámetros Inválidos en Widgets Personalizados
```dart
// ❌ INCORRECTO - Parámetro no existe
PixelButton(
  onPressed: _onPressed,
  padding: EdgeInsets.all(8), // Error: padding no es un parámetro válido
)

// ✅ CORRECTO - Verificar documentación del widget
PixelButton(
  onPressed: _onPressed,
  width: 48,
  height: 36,
  // Usar solo parámetros válidos según la definición
)

// Para verificar parámetros válidos:
// 1. Buscar la definición de la clase
// 2. Revisar el constructor
// 3. Usar solo parámetros documentados
```

#### ✅ Código No Utilizado - Variables y Métodos
```dart
// ❌ INCORRECTO - Variables declaradas pero no usadas
final isLargeScreen = screenSize.width >= 1200; // Eliminar
final spaceLeft = targetRect.left - margin; // Eliminar

// ✅ CORRECTO - Mantener solo código necesario
final spaceAbove = targetRect.top - margin;
final spaceBelow = screenSize.height - targetRect.bottom - margin;

// ❌ Método no utilizado - ELIMINAR
Widget _buildUnusedMethod() {
  return Container();
}
```

#### ✅ Imports Faltantes
```dart
// ❌ Error: kDebugMode no está definido
if (kDebugMode) {
  print('Debug info');
}

// ✅ Agregar import necesario
import 'package:flutter/foundation.dart';
```

#### ✅ Sintaxis de If Statement
```dart
// ❌ INCORRECTO - Falta de llaves
if (condition)
  return value;

// ✅ CORRECTO - Llaves explícitas
if (condition) {
  return value;
}
```

### 5.5 Problemas con Tutorial Overlay y Resaltado

**Problema:** El tutorial no muestra correctamente las áreas resaltadas o el resaltado es muy tenue.

**Solución Completa:**
```dart
// 1. Aumentar la opacidad del fondo oscuro
backgroundColor: Colors.black.withValues(alpha: 0.9)

// 2. Hacer el brillo más intenso y visible
glowColor: Colors.blueAccent.withValues(alpha: 0.8)
glowRadius: 25.0 // Aumentar el radio de brillo

// 3. Agregar márgenes al cálculo del rectángulo
final illuminationRect = Rect.fromLTRB(
  targetRect!.left - 8.0,  // Margen óptimo
  targetRect!.top - 8.0,
  targetRect!.right + 8.0,
  targetRect!.bottom + 8.0,
);

// 4. Agregar bordes brillantes adicionales
final borderGlowPaint = Paint()
  ..color = glowColor.withValues(alpha: 1.0) // Máxima intensidad
  ..style = PaintingStyle.stroke
  ..strokeWidth = 3.0 // Borde grueso
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);
```

**Efectos Visuales Mejorados:**
- Fondo oscuro más opaco (90% opacidad)
- Brillo azul más intenso (80% opacidad)
- Bordes blancos brillantes para máximo contraste
- Efectos de pulso en las esquinas
- Múltiples capas de brillo para profundidad

**Verificación:**
- [x] El fondo oscuro tiene suficiente contraste
- [x] El área resaltada es claramente visible
- [x] Los bordes brillantes resaltan el elemento
- [x] Los efectos de animación son suaves
- [x] No hay problemas de z-index con otros elementos

### 5.6 Validación de Flutter Analyze

**Comandos de validación obligatorios:**
```bash
# 1. Siempre ejecutar después de cualquier cambio
flutter analyze --no-pub

# 2. Resultado esperado:
# "Analyzing codequest..."
# "No issues found!"

# 3. Si hay errores, corregir inmediatamente antes de continuar
```

**Checklist de validación:**
- [x] Ejecutar `flutter analyze` después de cada cambio
- [x] Corregir todos los warnings antes de hacer commit
- [x] Verificar que no hay variables no utilizadas
- [x] Confirmar que todos los métodos son usados
- [x] Validar parámetros de widgets personalizados
- [x] Revisar imports faltantes
- [x] Verificar sintaxis de control flow

---

## 📋 Notas de Actualización
- **Última actualización**: Diciembre 2024
- **Versión de Flutter**: 3.16.0+
- **Dart SDK**: 3.2.0+
- **Cambios principales**: 
  - Eliminación de parámetros obsoletos en Radio widgets
  - Actualización de PopScope
  - Corrección de errores de flutter analyze (8 issues resueltos)
  - Limpieza de código no utilizado
  - Validación de parámetros en widgets personalizados

## 🚀 Recursos Adicionales
- [Flutter Deprecation Guide](https://docs.flutter.dev/release/deprecation)
- [Dart Null Safety Guide](https://dart.dev/null-safety)
- [Effective Dart](https://dart.dev/effective-dart)
- [Flutter Analyze Documentation](https://docs.flutter.dev/testing/debugging#the-dart-analyzer)