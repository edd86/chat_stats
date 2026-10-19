# Chats Stats 📊💬

<p align="center">
  <img src="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/svgs/solid/chart-pie.svg" width="80" height="80" alt="Chats Stats Logo" />
</p>

<p align="center">
  <b>Tu analizador de chats de WhatsApp 100% privado, local y visualmente impresionante.</b><br>
  Descubre dinámicas de grupo, récords, roles sociales, duelos cara a cara y genera tu propio <i>Chat Wrapped</i> interactivo al estilo Spotify.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Riverpod-3.4.2-blueviolet?style=for-the-badge" alt="Riverpod" />
  <img src="https://img.shields.io/badge/SQLite-Local%20Only-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline-success?style=for-the-badge" alt="Privacy Offline" />
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge" alt="License" />
</p>

---

## 🌟 Características Principales

### 📥 Importación Rápida & Flexible
- **Archivos `.txt` y `.zip`:** Importa historiales exportados directamente desde WhatsApp (con o sin archivos multimedia).
- **Integración con el Menú Compartir:** Envía el chat desde WhatsApp o el explorador de archivos directamente a la aplicación mediante los intents del sistema operativo (`SEND` y `VIEW`).
- **Parsing Inteligente Multiplataforma:** Soporta formatos de fecha y hora tanto de **Android** (`DD/MM/AAAA, HH:MM - ...`) como de **iOS** (`[DD/MM/AAAA, HH:MM:SS] ...`), detección automática de orden de fecha y sanitización de caracteres invisibles bidi de WhatsApp.
- **Procesamiento en Isolates (`compute`):** La extracción y el análisis sintáctico se realizan en hilos de fondo sin congelar la interfaz de usuario.

---

### 📊 Dashboard Estadístico Completo
- **Indicadores Clave (KPIs):** Total de mensajes, conteo de palabras, archivos multimedia compartidos, número de participantes y longevidad del chat.
- **Filtros Temporales Dinámicos:**
  - Historial Completo.
  - Últimos 30 días.
  - Últimos 90 días.
  - Año en curso.
  - Rango de fechas personalizado.
- **Récords Históricos:** Identifica el día con más mensajes en toda la historia de la conversación.
- **Gráficos Interactivos con `fl_chart`:**
  - 📈 Actividad diaria y volumen de mensajes en el tiempo.
  - ⏰ Distribución de mensajes por hora del día (descubre las horas pico).
  - 🗓️ **Mapa de calor semanal (Heatmap 7x24):** Visualiza los momentos exactos de mayor concurrencia entre días de la semana y horas.
  - 👥 Ranking de participación con porcentaje relativo por participante.

---

### 🎭 Roles Sociales & Dinámicas de Conversación
La app detecta automáticamente los hábitos y patrones de los integrantes del chat:
- ✍️ **El Escritor:** Participante con mayor número total de palabras redactadas.
- ❓ **El Curioso / Preguntón:** Quien formula más preguntas en el grupo.
- 🦉 **El Noctámbulo:** Quien envía más mensajes en la madrugada (00:00 a 06:00).
- 🌟 **El Más Mencionado:** Integrante más etiquetado mediante `@menciones`.
- 🎤 **El Monologuista:** Mayor racha de mensajes consecutivos sin respuesta.
- ⚡ **Velocidad de Respuesta:** Ranking de tiempos promedio de respuesta (quién responde en segundos vs. quién tarda días).
- 🚀 **Iniciadores:** Quién reactiva las conversaciones tras períodos prolongados de inactividad.
- 🔥 **Rachas de Conversación:** Contador de días consecutivos con mensajes activos (racha actual y racha récord).
- 🤫 **El Silencio más Largo:** Registro del período de inactividad más extenso entre mensajes.

---

### 🎁 Chat Wrapped (Historias estilo Spotify & Instagram)
- **5 Historias Animadas:** Resumen general, dinámicas de grupo, top emojis y palabras, asignación de personalidades y tarjeta final de resumen.
- **Controles Táctiles Fluidos:** Barras de progreso temporizadas, toque para avanzar/retroceder y pulsación prolongada para pausar.
- **Exportación en PNG de Alta Resolución:** Convierte cualquier historia en una imagen PNG optimizada (`RepaintBoundary`) y compártela directamente en estados de WhatsApp, Instagram Stories u otras redes con un solo toque.

---

### ⚔️ Duelo: Cara a Cara (Versus)
- Compara a dos participantes seleccionados lado a lado.
- Enfrentamiento directo de métricas: total de mensajes, volumen de palabras, multimedia, emojis predilectos, velocidad de respuesta y mensajes nocturnos.
- Barras de progreso comparativas y medallas al vencedor de cada categoría.

---

### 🔍 Búsqueda Rápida de Mensajes
- Motor de búsqueda local en SQLite con debounce de 300 ms.
- Busca palabras o frases específicas con contexto inmediato (remitente, fecha, hora, estado editado o multimedia).

---

### 🔒 Privacidad Radical (100% Offline)
- **Cero Servidores / Cero Nube:** Ningún mensaje, dato o estadística sale de tu teléfono. Todos los datos residen en la base de datos SQLite interna de la app.
- **Bloqueo Biométrico Opcional:** Protege el acceso a tus chats mediante huella dactilar, Face Unlock o el código de bloqueo de tu dispositivo (`local_auth`).
- **Eliminación Total:** Puedes eliminar cualquier chat importado en cualquier momento con borrado en cascada y optimización `VACUUM`.

---

## 🏗️ Arquitectura y Tecnologías

El proyecto sigue una arquitectura limpia orientada a features (**Feature-First Architecture**):

```
lib/
├── app.dart                   # Configuración global de MaterialApp, temas y enrutador
├── main.dart                  # Punto de entrada de la aplicación
├── core/                      # Módulos transversales compartidos
│   ├── constants/             # Constantes de configuración y publicidad
│   ├── local/                 # DatabaseHelper (SQLite), esquemas e índices
│   ├── router/                # Enrutador GoRouter declarativo
│   ├── services/              # AdService (AdMob no bloqueante), PrivacyService (biometría)
│   ├── theme/                 # Paleta de colores Dark Material 3 y tipografías
│   └── widgets/               # Banners, snackbars y componentes compartidos
└── features/
    ├── chat_import/           # Importación, descompresión (.zip), parsing regex e historial
    └── chat_dashboard/        # KPIs, gráficos fl_chart, dinámica de grupo, Wrapped y Versus
```

### Tecnologías Destacadas:
- **Gestión de Estado:** [Flutter Riverpod](https://riverpod.dev) (`Notifier`, `AsyncNotifier`, `FutureProvider.family`).
- **Enrutamiento:** [GoRouter](https://pub.dev/packages/go_router) con transiciones personalizadas y parámetros de ruta.
- **Base de Datos:** [sqflite](https://pub.dev/packages/sqflite) con índices optimizados en `chat_id`, `timestamp`, `sender` y `is_system`.
- **Concurrencia:** Dart Isolates vía `compute()` para parsing y procesamiento estadístico.
- **Diseño Visual:** Paleta oscura Material 3 con verde esmeralda WhatsApp (`#25D366`), superficies escalonadas y fuentes *Inter* y *Space Grotesk*.

---

## 🚀 Instalación y Puesta en Marcha

### Requisitos Previos
- **Flutter SDK:** `>= 3.12.2` ([Instrucciones de instalación](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** `>= 3.12.2`
- Dispositivo Android, emulador o dispositivo iOS configurado.

### Pasos para Ejecutar

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tu-usuario/chat_stats.git
   cd chat_stats
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar pruebas unitarias:**
   ```bash
   flutter test
   ```

4. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

---

## 🤖 Contexto para Agentes de IA

Si eres un modelo de lenguaje o agente autónomo (Gemini, Claude, GPT, Cursor, etc.) trabajando en este repositorio, **no necesitas escanear todos los archivos del proyecto**.

Consulta el archivo [AI_CONTEXT.md](file:///d:/FlutterProjects/chat_stats/AI_CONTEXT.md) en la raíz del proyecto para obtener el mapa completo de:
- Flujo de comunicación entre componentes y providers.
- Modelos de datos y esquemas DDL de SQLite.
- Reglas de desarrollo y manejo de segundo plano con isolates.
- Convenciones de rutas e índices.

---

## 📄 Política de Privacidad

Consulta el documento [PRIVACY_POLICY.md](file:///d:/FlutterProjects/chat_stats/PRIVACY_POLICY.md) para más detalles sobre el tratamiento de datos y la garantía de procesamiento 100% en el dispositivo.

---

## 📝 Licencia

Este proyecto se distribuye bajo la licencia **MIT**. Consulta el archivo `LICENSE` para más información.
