# Estándares de Codificación - Flutter Tutorial

## Guía de Prevención de Errores

### Estructura de Archivos

#### 1. Organización de Clases
- **Nunca declarar clases dentro de otras clases** (excepto clases privadas muy específicas)
- **Clases auxiliares** deben estar al final del archivo o en archivos separados
- **Orden recomendado**:
  1. Imports
  2. Clases principales
  3. Clases auxiliares
  4. Widgets de utilidad

#### 2. Convenciones de Nomenclatura
- **Clases privadas**: Usar prefijo `_` (ej: `_PositionScore`)
- **Constructores**: Preferir parámetros nombrados para claridad
- **Métodos auxiliares**: Documentar su propósito con comentarios

### Prevención de Errores Comunes

#### Errores de Importación
```yaml
# analysis_options.yaml
linter:
  rules:
    - always_declare_return_types
    - always_require_non_null_named_parameters
    - annotate_overrides
    - avoid_relative_lib_imports
    - avoid_returning_null
    - avoid_types_as_parameter_names
    - camel_case_types
    - cancel_subscriptions
    - close_sinks
    - constant_identifier_names
    - control_flow_in_finally
    - directives_ordering
    - empty_catches
    - empty_constructor_bodies
    - empty_statements
    - hash_and_equals
    - implementation_imports
    - invariant_booleans
    - iterable_contains_unrelated_type
    - library_names
    - library_prefixes
    - list_remove_unrelated_type
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - non_constant_identifier_names
    - null_closures
    - omit_local_variable_types
    - package_api_docs
    - package_names
    - package_prefixed_library_names
    - prefer_adjacent_string_concatenation
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_final_fields
    - prefer_for_elements_to_map_fromIterable
    - prefer_function_declarations_over_variables
    - prefer_if_null_operators
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_iterable_whereType
    - prefer_single_quotes
    - prefer_typing_uninitialized_variables
    - recursive_getters
    - slash_for_doc_comments
    - test_types_in_equals
    - throw_in_finally
    - type_init_formals
    - unawaited_futures
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_getters_setters
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_in_if_null_operators
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_statements
    - unnecessary_this
    - unrelated_type_equality_checks
    - use_rethrow_when_possible
    - valid_regexps
    - void_checks
```

### Checklist de Verificación

#### Antes de hacer commit:
- [ ] Ejecutar `flutter analyze`
- [ ] Ejecutar `flutter test` (si hay pruebas)
- [ ] Verificar que no hay clases anidadas
- [ ] Confirmar que todas las importaciones necesarias están presentes
- [ ] Validar que los constructores usan parámetros nombrados cuando sea apropiado

#### Validación de Código
```bash
# Comandos útiles para validación
flutter analyze
flutter pub run build_runner build
flutter test
flutter run --debug
```

### Plantillas de Código

#### Clase Auxiliar Estándar
```dart
// Clase auxiliar para [propósito específico]
class _NombreClaseAuxiliar {
  final Tipo propiedad1;
  final Tipo propiedad2;
  
  _NombreClaseAuxiliar({
    required this.propiedad1,
    required this.propiedad2,
  });
}
```

#### Importaciones Recomendadas
```dart
// Siempre incluir para funciones matemáticas
import 'dart:math' as math;

// Para operaciones de UI
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
```

### Documentación de Errores

#### Proceso de Documentación
1. **Identificar el error** con `flutter analyze`
2. **Describir el problema** en lenguaje claro
3. **Documentar la solución** implementada
4. **Crear recomendaciones** para prevenir
5. **Actualizar estándares** si es necesario

#### Formato de Documentación
```markdown
### Error: [Nombre del Error]
- **Descripción**: [Explicación breve]
- **Ubicación**: [Archivo y líneas]
- **Solución**: [Cambios realizados]
- **Prevención**: [Cómo evitar en el futuro]
```

### Herramientas de Desarrollo

#### Extensiones VS Code Recomendadas
- Dart
- Flutter
- Error Lens
- Bracket Pair Colorizer
- GitLens

#### Configuración de IDE
```json
// .vscode/settings.json
{
  "dart.previewLsp": true,
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.checkForSdkUpdates": true,
  "dart.showInspectorNotificationsForWidgetErrors": true,
  "dart.triggerSignatureHelpAutomatically": true,
  "dart.completeFunctionCalls": true
}
```

### Pruebas Automatizadas

#### Script de Pre-commit
```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running Flutter analysis..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "Flutter analysis failed. Please fix the issues before committing."
    exit 1
fi

echo "Running tests..."
flutter test
if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix the issues before committing."
    exit 1
fi

echo "Pre-commit checks passed!"
```

### Recursos Adicionales

- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Dart Linter Rules](https://dart-lang.github.io/linter/lints/)