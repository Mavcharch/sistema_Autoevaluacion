# 🧑‍⚖️ CodeJudge

**Sistema de evaluación automática de código para estudiantes de programación.**

Aplicación móvil desarrollada en **Flutter/Dart** que analiza la **lógica**, la
**eficiencia** y el **estilo** del código fuente y brinda retroalimentación
detallada al instante, con gráficos profesionales y una interfaz dinámica.

![CodeJudge](https://img.shields.io/badge/Flutter-3.27-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.6-0175C2?logo=dart)

---

## ✨ Características

- **Análisis multi-lenguaje**: Python, JavaScript, Java, C++ y Dart.
- **Tres dimensiones de evaluación**:
  - 🧠 **Lógica** — complejidad ciclomática, anidamiento, casos límite, bucles
    infinitos, cobertura de retornos.
  - ⚡ **Eficiencia** — estimación de complejidad Big-O, detección de bucles
    anidados, recursión y memoización, operaciones costosas en bucles.
  - 🎨 **Estilo** — convenciones de nombres, longitud de líneas/funciones,
    densidad de comentarios, números mágicos, indentación, espacios en blanco.
- **Retroalimentación accionable**: cada hallazgo incluye severidad, línea y
  sugerencia concreta de mejora.
- **Visualizaciones profesionales**:
  - Gauge circular animado del puntaje global.
  - Gráfico radar de distribución de habilidades.
  - Gráfico de barras de severidad de hallazgos.
  - Gráfico de tendencia del progreso en el dashboard.
- **Historial persistente** (SharedPreferences) con resumen de promedios.
- **Dashboard analítico** con KPIs y distribución por lenguaje.
- **Modo claro/oscuro** con persistencia de preferencia.
- **Visor de código** con resaltado de sintaxis ligero y líneas marcadas.

---

## 🚀 Cómo ejecutarlo desde Visual Studio Code

### 1. Requisitos previos

Instala lo siguiente en tu máquina:

- **Flutter SDK** (3.27 o superior) → https://docs.flutter.dev/get-started/install
- **VS Code** → https://code.visualstudio.com/
- Extensiones de VS Code:
  - **Flutter** (Dart-Code.flutter) — incluye soporte para Dart.
  - **Dart** (Dart-Code.dart-code)

Verifica la instalación ejecutando en una terminal:

```bash
flutter doctor
```

Para desarrollo móvil necesitarás además:
- **Android Studio** (con Android SDK) para emulador Android, o
- **Xcode** (solo macOS) para simulador iOS.

> ℹ️ Si solo quieres probarlo rápido sin emulador, puedes ejecutarlo en **Chrome**
> (web) sin instalar nada adicional.

### 2. Abrir el proyecto

1. Abre VS Code.
2. Menú **Archivo → Abrir carpeta…** (File → Open Folder…).
3. Selecciona la carpeta `codejudge` (esta carpeta).
4. VS Code detectará automáticamente el proyecto Flutter y mostrará la
   configuración recomendada.

### 3. Instalar dependencias

Abre la terminal integrada de VS Code (**Terminal → Nueva terminal**) y ejecuta:

```bash
flutter pub get
```

### 4. Seleccionar un dispositivo

- Presiona **Ctrl/Cmd + Shift + P** → escribe `Flutter: Select Device`.
- Elige un emulador Android, simulador iOS, o **Chrome** (para web).

También puedes ver los dispositivos disponibles con:

```bash
flutter devices
```

### 5. Ejecutar la app

Tienes tres formas:

#### Opción A — Botón Run (más fácil)
Abre `lib/main.dart` y pulsa el botón **Run** (▶) que aparece en la esquina
superior derecha del editor, o presiona **F5**.

#### Opción B — Panel de depuración
1. Ve al panel **Run and Debug** (ícono ▶️ con un insecto) en la barra lateral.
2. Elige una configuración del archivo `.vscode/launch.json`:
   - **CodeJudge (Flutter)** — dispositivo seleccionado (debug).
   - **CodeJudge (Chrome - web)** — lanza en el navegador.
   - **CodeJudge (Release)** — modo release (más rápido).
3. Pulsa el botón verde **Start Debugging** (o **F5**).

#### Opción C — Terminal

```bash
# En un emulador/dispositivo
flutter run

# En Chrome (web)
flutter run -d chrome

# En modo release
flutter run --release
```

### 6. Hot reload 🔥

Mientras la app corre, guarda cualquier archivo (`Ctrl/Cmd + S`) para hacer
**Hot Reload** al instante. Para reiniciar el estado usa **R** mayúscula en la
terminal o el comando `Flutter: Hot Restart`.

---

## 📁 Estructura del proyecto

```
lib/
├── main.dart                     # Entry point + navegación + tema
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # Paleta de colores (esmeralda/ámbar/teal)
│   │   └── app_theme.dart        # Tema claro/oscuro + tipografía
│   └── constants/
│       └── app_constants.dart
├── models/
│   ├── programming_language.dart # Enum de lenguajes + metadatos
│   ├── issue.dart                # Hallazgo (severidad, línea, sugerencia)
│   ├── category_score.dart       # Resultado por categoría
│   ├── evaluation_result.dart    # Resultado completo
│   └── history_entry.dart        # Entrada de historial (persistencia)
├── services/
│   ├── code_analyzer_service.dart # Orquestador
│   ├── logic_analyzer.dart        # Análisis de lógica
│   ├── efficiency_analyzer.dart   # Análisis de eficiencia (Big-O)
│   ├── style_analyzer.dart        # Análisis de estilo
│   ├── code_samples.dart          # Ejemplos precargados
│   └── storage_service.dart       # SharedPreferences
├── widgets/
│   ├── score_gauge.dart          # Gauge circular animado
│   ├── radar_chart_widget.dart   # Gráfico radar (fl_chart)
│   ├── trend_chart.dart          # Gráfico de línea (fl_chart)
│   ├── severity_bar_chart.dart   # Gráfico de barras (fl_chart)
│   ├── category_score_card.dart  # Tarjeta de categoría
│   ├── issue_tile.dart           # Tile de hallazgo
│   ├── code_view.dart            # Visor de código con resaltado
│   ├── stat_card.dart            # Tarjeta de KPI
│   └── language_selector.dart    # Selector horizontal de lenguaje
└── screens/
    ├── home_screen.dart          # Inicio + CTA
    ├── editor_screen.dart        # Editor de código
    ├── results_screen.dart       # Resultados detallados
    ├── history_screen.dart       # Historial de evaluaciones
    ├── dashboard_screen.dart     # Dashboard analítico
    └── settings_screen.dart      # Ajustes + modo oscuro
```

---

## 🧪 Cómo funciona el análisis

El análisis es **100% local** (sin conexión a internet ni backend). Se basa en
**análisis estático heurístico** mediante expresiones regulares y recorrido del
árbol de tokens:

1. **Lógica** — cuenta puntos de decisión (if/for/while/&&/||) para la
   complejidad ciclomática, mide la profundidad de anidamiento, busca
   validaciones de casos límite (vacío, nulo, longitud) y detecta bucles
   `while(true)` sin `break`.

2. **Eficiencia** — mide la profundidad de bucles anidados para estimar la
   complejidad temporal (O(1), O(n), O(n²), O(n³), O(2ⁿ)), detecta recursión
   (incluida recursión exponencial sin memoización), `.sort()` dentro de bucles
   y concatenación de strings en bucles.

3. **Estilo** — verifica convenciones de nombres (camelCase vs snake_case según
   el lenguaje), longitud de líneas y funciones, densidad de comentarios,
   números mágicos, indentación mixta y espacios en blanco al final.

Cada hallazgo contribuye al puntaje (0–100) con penalizaciones por severidad.
El puntaje global es el promedio de las tres categorías.

---

## 🎨 Diseño

- **Paleta**: esmeralda/teal (primario) + ámbar (acento) + rosa (errores).
  Sin uso de azul/índigo, siguiendo estándares de accesibilidad.
- **Tipografía**: Inter (UI) + JetBrains Mono (código), vía `google_fonts`.
- **Gráficos**: `fl_chart` (radar, líneas, barras) + gauge circular con
  `CustomPainter`.
- **Animaciones**: gauge animado, barras de progreso animadas, transiciones.
- **Responsive**: mobile-first, probado en viewport 412×915.

---

## 🛠️ Comandos útiles

```bash
# Verificar calidad del código
flutter analyze

# Compilar APK (Android)
flutter build apk --release

# Compilar para web
flutter build web --release

# Compilar para iOS (requiere macOS + Xcode)
flutter build ios --release

# Limpiar build cache
flutter clean && flutter pub get
```

---

## 📦 Dependencias principales

| Paquete              | Uso                                    |
|----------------------|----------------------------------------|
| `fl_chart`           | Gráficos radar, líneas y barras        |
| `google_fonts`       | Tipografía Inter + JetBrains Mono      |
| `shared_preferences` | Persistencia del historial y tema      |
| `flutter_animate`    | Animaciones (disponible)               |
| `intl`               | Utilidades de formato                  |

---

## 👨‍🎓 Para estudiantes

CodeJudge está pensado como una herramienta de **autoaprendizaje**: escribe tu
código, evalúalo, lee las sugerencias y vuelve a iterar. El objetivo no es solo
"aprobar", sino **entender** por qué cierto patrón es más eficiente o legible.

¡Feliz programación! 🚀
