---
applyTo: "**"
---

# Instrucciones del Agente — Flutter Mobile

---

## Fuente de verdad de la API

**Antes de implementar cualquier llamada HTTP**, lee la sección `## Mobile` de `.github/API.md` del workspace raíz (o `API.md` en la raíz de este repo si estás en workspace solo).

Flutter **solo consume endpoints `/api/mobile/**`**. No llames a rutas de admin u officer.

No inventes URLs. Si el endpoint no está en la sección `## Mobile` de `API.md`, no existe — espera a que Spring Boot lo implemente.

---

## Sincronización con cambios en la API

Cuando la sección `## Mobile` de `API.md` sea actualizada — identifica entradas con ⚠️ **Cambio** — debes:

1. Identificar qué endpoints cambiaron (ruta, método, body o response).
2. Actualizar el servicio/repository correspondiente en `lib/data/`.
3. Actualizar los modelos/DTOs en `lib/domain/models/`.
4. Actualizar los providers/blocs que dependan de ese servicio.

---

## Regla de finalización — OBLIGATORIA

Antes de declarar cualquier tarea como completada:

### 1. Analizar el proyecto

```bash
flutter analyze
```

- Corrige todos los errores y warnings antes de continuar.

### 2. Hacer commit y push a Git

```bash
git add .
git commit -m "feat(mobile): <descripción breve de lo implementado>"
git push
```

### 3. Actualizar PLANNING.md

Después del commit, marca como completadas (`- [x]`) las tareas que hayas terminado en `.github/PLANNING.md` (está en `../../.github/PLANNING.md` relativo a este repo).

- Solo marca las tareas que efectivamente completaste en esta sesión.
- No marques tareas que no tocaste.
- No crees ni elimines secciones — solo cambia `[ ]` por `[x]`.

---

## Reglas de arquitectura

- Flutter 3.x, Dart null-safe.
- State management: **Riverpod** (preferido) o Bloc.
- JWT en `flutter_secure_storage`.
- Solo el rol `CLIENT` usa esta app.
- El cliente puede iniciar trámites solo si la política tiene `allowedStartChannels: ["MOBILE"]`.
- Tareas `CLIENT_TASK` se completan desde Flutter.

---

## Referencias

- Plan general: `.github/PLANNING.md` (workspace raíz)
- Detalles técnicos Flutter: `.github/FLUTTER.md` (workspace raíz)
- **Contrato de API — solo sección Mobile (leer siempre):** `.github/API.md` (workspace raíz)
