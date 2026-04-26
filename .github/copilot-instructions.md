# Instrucciones para GitHub Copilot — App Móvil (Flutter)
## Configurable Workflow System · SW1 2026

> Este repositorio contiene la **aplicación móvil del cliente externo**.
> Para el plan detallado de pantallas y endpoints ver `../.github/FLUTTER.md`.

---

## Stack

- Flutter 3.x / Dart (null-safe)
- State management: **Riverpod** (preferido) o Bloc
- HTTP: `dio` o `http`
- JWT: `flutter_secure_storage`
- Notificaciones: polling o `firebase_messaging`

## Rol Único

Este repositorio es **exclusivamente para el rol `CLIENT`**.

El cliente externo puede:
- Autenticarse con email y contraseña
- Ver sus trámites y su estado actual
- **Iniciar trámites** donde la política incluya `"MOBILE"` en `allowedStartChannels`
- Completar `CLIENT_TASK`: subir documentos, responder observaciones, enviar formularios
- Recibir y leer notificaciones

El cliente **no puede**:
- Ver ni editar políticas de workflow
- Completar tareas internas (`taskAudience: INTERNAL`)
- Acceder a datos de otros clientes

## Comunicación

- Flutter solo consume **Spring Boot** en `/api/mobile/**`
- **Nunca** llamar a FastAPI directamente
- JWT almacenado en `flutter_secure_storage` (no en SharedPreferences)

## Endpoints Base

```
POST  /api/mobile/auth/login
GET   /api/mobile/workflow-policies/available   ← políticas con MOBILE habilitado
POST  /api/mobile/procedures                    ← iniciar trámite
GET   /api/mobile/procedures/my
GET   /api/mobile/procedures/{id}
GET   /api/mobile/tasks/my                      ← CLIENT_TASK pendientes
GET   /api/mobile/tasks/{id}
POST  /api/mobile/tasks/{id}/complete           ← completar CLIENT_TASK
POST  /api/mobile/tasks/{id}/attachments        ← subir documento
GET   /api/mobile/notifications
PATCH /api/mobile/notifications/{id}/read
```

## Estructura

```
lib/
├── core/
│   ├── api/          ← api_client.dart, endpoints.dart
│   ├── auth/         ← auth_service.dart, secure_storage.dart
│   └── models/       ← procedure.dart, task.dart, notification.dart
└── features/
    ├── auth/
    ├── procedures/   ← incluye new_procedure_screen.dart
    ├── tasks/        ← CLIENT_TASK: list + detail/complete
    └── notifications/
```

## Seguridad

- Validar siempre que la tarea pertenece al cliente autenticado antes de enviar
- No mostrar trámites de otros clientes
- El backend valida `task.assignedClientId == currentUser.clientId`

## Formularios Dinámicos

- Los campos vienen de `task.form.fields[]` o del `startConfig.initialForm` de la política
- Tipos: `TEXT`, `NUMBER`, `DATE`, `BOOLEAN`, `FILE`, `SELECT`, `TEXTAREA`
- Campo `FILE`: selector de archivo con preview (imagen/PDF)
- Validar campos `required` antes de enviar

## Estados de Trámite (colores)

| Estado         | Color                  |
|----------------|------------------------|
| CREATED        | Gris                   |
| IN_PROGRESS    | Azul                   |
| WAITING_CLIENT | Amarillo/Naranja claro |
| OBSERVED       | Naranja                |
| APPROVED       | Verde                  |
| REJECTED       | Rojo                   |
| COMPLETED      | Verde oscuro           |
| CANCELLED      | Gris oscuro            |
