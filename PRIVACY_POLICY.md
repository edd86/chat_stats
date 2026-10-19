# Prompt: Crear página de Privacy Policy para "Chats Stats"

> **Cómo usarlo:** copia este archivo completo al proyecto de tu sitio web y
> pega su contenido como prompt a la IA (o ejecútalo con opencode). La IA
> debe crear la página de *Privacy Policy* dentro de ese proyecto, en la misma
> estructura/estilo que el resto del sitio, para publicarla y obtener la URL.

---

Crea la página de **Privacy Policy** (Política de Privacidad) de la app móvil **Chats Stats**, como sección de la *User Data policy* de mi sitio web.

## Contexto del producto

- **App:** Chats Stats (nombre visible en Android e iOS)
- **Desarrollador:** {{DEVELOPER_NAME}}
- **Package ID:** `dev.codedd.chat_stats`
- **Plataformas:** Android e iOS
- **Qué hace:** importa un chat de WhatsApp exportado (`.txt` o `.zip`) y genera estadísticas, rankings, heatmaps, análisis de palabras/emojis, "Chat Wrapped", búsqueda y modo "versus" entre participantes.
- **Procesamiento:** 100 % local en el dispositivo. **No hay backend ni servidores propios.** Ningún dato de los chats sale del dispositivo.

## Datos que maneja la app (inventario verificado en el código fuente)

| Categoría | Detalle |
|---|---|
| Datos introducidos por el usuario | Contenido completo del chat exportado de WhatsApp: texto de cada mensaje, fecha/hora, remitente (nombre o número), mensajes del sistema, indicadores de edición/borrado, nombre del chat/archivo |
| Almacenamiento | Solo local: SQLite (`chat_stats.db`) con tablas `chats`, `messages`, `participants`; caché interna con la copia del archivo importado; SharedPreferences (flag del bloqueo) |
| Transmisiones a servidores propios | **Ninguna** |
| Contactos, ubicación, cámara, micrófono, fotos, SMS | **No accedidos** (no hay permisos) |
| Permisos | `INTERNET` (anuncios y fuentes), `USE_BIOMETRIC` (bloqueo opcional con huella/clave) |
| Terceros | **Google Mobile Ads (AdMob)** — anuncios banner e intersticiales; **Google Fonts** — descarga de tipografías |
| Compartir | Solo imágenes PNG del "Chat Wrapped" que el usuario comparte voluntariamente vía `share_plus` |
| Cuenta de usuario / registro | No existe |
| Analytics / Firebase / Crashlytics | No existen |
| Bloqueo de privacidad | Opcional, con biometría o clave del dispositivo (`local_auth`) |

## Requisitos de la página

1. **Idioma:** español (versión inglés opcional si el sitio es bilingüe).
2. **Secciones obligatorias:**
   1. Introducción (quién trata los datos y finalidad)
   2. Datos que recopilamos (tabla: dato / finalidad / base legal / retención)
   3. Cómo usamos los datos
   4. Almacenamiento y seguridad (local, sin cifrado de la BD — {{ENCRYPTION_STATUS}})
   5. Compartición con terceros (solo AdMob y Google Fonts; **no vendemos datos**)
   6. Anuncios (AdMob, identificadores de publicidad, cómo hacer opt-out / reset del ID)
   7. Derechos del usuario (GDPR art. 15–22: acceso, rectificación, supresión, portabilidad, oposición; CCPA si aplica)
   8. Datos de menores (no dirigida a menores de 14 años)
   9. Cambios en la política (fecha de última actualización)
   10. Contacto ({{CONTACT_EMAIL}} para ejercer derechos)
3. **Tono:** claro y formal, sin rodeos legales innecesarios.
4. **Extensión:** 800–1200 palabras.
5. **Menciones clave que no pueden faltar:**
   - El contenido de los chats **nunca sale del dispositivo** ni se sube a servidores.
   - No se accede a contactos, ubicación, cámara, micrófono ni fotos.
   - AdMob es el único tercero con fines publicitarios.
   - El usuario puede eliminar sus datos desde la app (Ajustes → {{DELETE_PATH}}).
6. **Estilo:** sigue el design system del sitio (mismos tokens/colores/tipografía que el resto de páginas legales o el layout existente).
7. **Integración:**
   - Crea la ruta/endpoint público (ej. `/privacy` o `/legal/privacy-policy`) — necesito la **URL publicada**.
   - Enlázala desde el footer del sitio.
   - Indica dónde debo añadir el enlace dentro de la app (onboarding o pantalla de Ajustes).

## Antes de terminar

- Si te falta algún dato (nombre legal del desarrollador, email de contacto, URL de la app), pregúntamelo antes de generar la página.
- Al final, responde con: ruta del archivo creado, URL resultante y cualquier hueco legal que deba revisar (p. ej. consentimiento UMP de Google para EEA/UK).
