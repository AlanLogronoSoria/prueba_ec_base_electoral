# Conexión con Appwrite — Guía paso a paso

## 1. Levantar Appwrite Server

### Opción A — Docker (recomendada)

```bash
# Descargar e iniciar Appwrite
docker run -it --rm \,   
  --name appwrite \
  -p 80:80 \
  -p 443:443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v appwrite_data:/storage/uploads:rw \
  appwrite/appwrite:latest
```

Acceder a `http://localhost/` y crear la cuenta de administrador.

### Opción B — Appwrite Cloud

Registrarse en [cloud.appwrite.io](https://cloud.appwrite.io), crear un proyecto nuevo.

## 2. Crear proyecto en Appwrite Console

1. Ir a **Projects** > **Create Project**
2. Nombre: `control-electoral`
3. Anotar el **Project ID** que aparece en Settings > Project > Project ID

## 3. Configurar constantes en el código

Editar `lib/core/constants/appwrite_constants.dart`:

```dart
static const String endpoint = 'http://localhost/v1';  // URL de tu servidor
static const String projectId = 'control-electoral';    // Project ID
static const String databaseId = 'control_electoral_db';
```

Si usas Appwrite Cloud, el endpoint será `https://cloud.appwrite.io/v1`.

## 4. Crear la base de datos

En Appwrite Console:
1. Ir a **Databases** > **Create Database**
2. Database ID: `control_electoral_db`
3. Name: `Control Electoral DB`

## 5. Crear colecciones

### Colección: `usuarios`

| Atributo | Tipo | Tamaño | Requerido | Array? |
|---|---|---|---|---|
| cedula | string | 255 | sí | no |
| nombres | string | 255 | sí | no |
| apellidos | string | 255 | sí | no |
| telefono | string | 255 | sí | no |
| correo | string | 255 | sí | no |
| rol | string | 255 | sí | no |
| primer_login | boolean | — | sí | no |
| recinto_id | string | 255 | no | no |
| creado_por | string | 255 | no | no |
| auth_user_id | string | 255 | no | no |

### Colección: `recintos`

| Atributo | Tipo | Tamaño | Requerido | Array? |
|---|---|---|---|---|
| canton | string | 255 | sí | no |
| parroquia | string | 255 | sí | no |
| nombre | string | 255 | sí | no |
| coordinador_recinto_id | string | 255 | no | no |

### Colección: `mesas`

| Atributo | Tipo | Tamaño | Requerido | Array? |
|---|---|---|---|---|
| numero_jrv | string | 255 | sí | no |
| recinto_id | string | 255 | sí | no |
| veedor_id | string | 255 | no | no |

### Colección: `organizaciones_politicas`

| Atributo | Tipo | Tamaño | Requerido | Array? |
|---|---|---|---|---|
| nombre | string | 255 | sí | no |
| candidato | string | 255 | sí | no |
| dignidad | string | 255 | sí | no |

### Colección: `actas`

| Atributo | Tipo | Tamaño | Requerido | Array? |
|---|---|---|---|---|
| mesa_id | string | 255 | sí | no |
| dignidad | string | 255 | sí | no |
| total_sufragantes | integer | — | sí | no |
| votos_nulos | integer | — | sí | no |
| votos_blancos | integer | — | sí | no |
| foto_url | string | 2048 | no | no |
| gps_lat | double | — | no | no |
| gps_lng | double | — | no | no |
| created_by | string | 255 | sí | no |
| estado | string | 255 | no | no (default: 'pendiente') |
| ultima_modificacion_por | string | 255 | no | no |
| updated_at | string | 255 | no | no |

### Colección: `votos_por_organizacion`

| Atributo | Tipo | Tamaño | Requerido | Array? |
|---|---|---|---|---|
| acta_id | string | 255 | sí | no |
| organizacion_id | string | 255 | sí | no |
| votos | integer | — | sí | no |

## 6. Configurar índices

Para rendimiento, crear los siguientes índices en cada colección:

**usuarios**: `cedula` (único), `rol`, `recinto_id`
**recintos**: `canton`, `coordinador_recinto_id`
**mesas**: `numero_jrv`, `recinto_id`, `veedor_id`
**actas**: `mesa_id`, `dignidad`, `registrado_por`
**votos_por_organizacion**: `acta_id`, `organizacion_id`

## 7. Configurar permisos por colección

### `usuarios`
- **Create**: solo admin/coordinador_provincial
- **Read**: solo usuarios autenticados (el propio usuario)
- **Update**: solo el propio usuario
- **Delete**: solo admin

### `recintos`
- **Create**: coordinador_provincial
- **Read**: cualquier usuario autenticado
- **Update**: coordinador_provincial
- **Delete**: solo admin

### `mesas`
- **Create**: coordinador_recinto
- **Read**: veedor (solo donde veedor_id == su ID), coordinador_recinto (solo donde recinto_id == su recinto_id)
- **Update**: coordinador_recinto (solo donde recinto_id == su recinto_id)
- **Delete**: solo admin

### `organizaciones_politicas`
- **Read**: cualquier usuario autenticado
- **Write**: solo admin

### `actas`
- **Create**: veedor
- **Read**: veedor (solo las suyas), coordinador_recinto (solo mesas de su recinto), coordinador_provincial (todas)
- **Update**: veedor (solo las suyas), coordinador_recinto (solo mesas de su recinto — sin restricción de creador)
- **Delete**: solo admin

### `votos_por_organizacion`
- **Create**: veedor (al registrar acta)
- **Read**: cualquier usuario autenticado
- **Update**: veedor/coordinador_recinto (al corregir acta)
- **Delete**: solo admin

### Reglas de permisos a nivel de documento para Coordinador de Recinto

El rol `coordinador_recinto` debe poder **leer y escribir** documentos de `mesas` y `actas` únicamente cuando pertenezcan a su `recinto_id`. Para configurar esto en Appwrite:

#### Opción 1: Usar API Key + lógica en backend (recomendada para producción)

Crear un **API Key** en Appwrite Console (`Settings > API Keys`) con permisos de lectura/escritura en las colecciones necesarias, y usar un **Appwrite Function** o un backend intermedio que valide que `mesa.recinto_id == usuario.recinto_id` antes de permitir la operación.

#### Opción 2: Document-level Security usando etiquetas (Appwrite 1.5+)

Agregar un atributo `recinto_id` en las colecciones `mesas` y `actas`, y configurar reglas de seguridad por documento:

```
// Appwrite Console > Database > mesas > Settings > Security
// Regla de lectura: si el usuario tiene rol coordinador_recinto,
// solo puede leer documentos donde recinto_id coincide con su recinto_id asignado

Rule: Read
  Assign: role:coordinador_recinto
  When:  doc.recinto_id == user.recinto_id

// Regla de escritura (update):
Rule: Update
  Assign: role:coordinador_recinto  
  When:  doc.recinto_id == user.recinto_id
```

Para `actas`, como no tiene `recinto_id` directamente, la validación debe hacerse a través de la mesa relacionada. La alternativa práctica es:

1. Dar permisos `read:any` y `update:any` sobre la colección `actas` al rol `coordinador_recinto`
2. Filtrar desde el código (`getMesas` ya filtra por `recinto_id`, luego `getActaPorMesa` solo accede a actas de esas mesas)

#### Opción 3: Permisos abiertos en desarrollo + validación en código

Para simplificar durante el desarrollo, puedes usar permisos abiertos (`role:all` con CRUD completo) y confiar en que las consultas en el datasource ya filtran por `recinto_id`. Esto es lo que hace el código actual:

```dart
// El datasource ya filtra por recinto_id
Query.equal('recinto_id', recintoId)
```

**Importante**: En producción, combina las consultas filtradas con reglas a nivel de documento o API Key para seguridad en capas.

## 8. Crear bucket de Storage

1. Ir a **Storage** > **Create Bucket**
2. Bucket ID: `actas_fotos`
3. Name: `Fotos de Actas`
4. Maximum file size: 10 MB
5. Allowed file extensions: `jpg`, `jpeg`, `png`
6. Permissions: solo usuarios autenticados

## 9. Configurar reglas de permiso en Appwrite

Para que los permisos por rol funcionen correctamente, necesitas configurar reglas de permiso a nivel de documento usando **Appwrite Security Rules** o creando un **API Key** desde Settings > API Keys.

La forma más sencilla para desarrollo es usar los permisos por defecto con `role:all` y manejar la seguridad desde la aplicación. Para producción, se recomienda:

### Document-level security (Appwrite Attribute-based permissions)

Ejemplo para colección `mesas`:
```javascript
// Appwrite Security Rule (console > Database > mesas > Settings > Security)
// Los veedores solo pueden leer mesas donde veedor_id == su userId
```

## 10. Precargar organizaciones políticas

```bash
cd scripts
# Primero crear un usuario admin en la consola de Appwrite
# Email: admin@electoral.ec, Password: Admin123!
# Luego ejecutar:
dart precargar_organizaciones.dart
```

Esto crea 10 organizaciones políticas:
- 5 para dignidad **alcalde**: Fuerza Ecuador, Social Cristiano, Revolución Ciudadana, CREO, Izquierda Democrática
- 5 para dignidad **prefecto**: mismas organizaciones con diferentes candidatos

## 11. Crear usuarios de prueba

Usar la consola de Appwrite o el SDK para crear 3 usuarios:

```dart
// Ejemplo con Appwrite Server SDK (Node.js)
const sdk = new Appwrite.SDK();

// Coordinador Provincial
await sdk.account.create('1234567890@electoral.ec', 'Cambiar123!');
await sdk.database.createDocument('usuarios', {
  'cedula': '1234567890',
  'nombres': 'Carlos',
  'apellidos': 'Provincial',
  'telefono': '0999000001',
  'correo': 'carlos@electoral.ec',
  'rol': 'coordinador_provincial',
  'primer_login': true,
});

// Coordinador Recinto
await sdk.account.create('0987654321@electoral.ec', 'Cambiar123!');
await sdk.database.createDocument('usuarios', {
  'cedula': '0987654321',
  'nombres': 'María',
  'apellidos': 'Recinto',
  'telefono': '0999000002',
  'correo': 'maria@electoral.ec',
  'rol': 'coordinador_recinto',
  'primer_login': true,
  'recinto_id': '{ID_DEL_RECINTO}',
});

// Veedor
await sdk.account.create('1112223334@electoral.ec', 'Cambiar123!');
await sdk.database.createDocument('usuarios', {
  'cedula': '1112223334',
  'nombres': 'José',
  'apellidos': 'Veedor',
  'telefono': '0999000003',
  'correo': 'jose@electoral.ec',
  'rol': 'veedor',
  'primer_login': true,
});
```

## 12. Iniciar la app

```bash
flutter pub get
flutter run
```

La app tiene `primer_login = true` para todos los usuarios nuevos, por lo que al iniciar sesión por primera vez pedirá cambiar la contraseña.

## Solución de problemas comunes

### Error: "AppwriteException: Project not found"
→ Verifica que el `projectId` en `appwrite_constants.dart` coincida con el Project ID de la consola.

### Error: "Collection not found"
→ Verifica que todos los Collection IDs en `appwrite_constants.dart` coincidan con los creados.

### Error: "SSL certificate required"
→ Si usas HTTP en lugar de HTTPS, asegúrate de que `selfSigned: true` esté configurado (solo desarrollo local). En Appwrite Cloud siempre usa HTTPS.

### Error: "Permission denied"
→ Revisa las reglas de permiso en cada colección. Para desarrollo puedes usar `role:all` con permisos completos temporalmente.

### Error: "GPS permission denied"
→ En Android: verifica `android/app/src/main/AndroidManifest.xml` incluya:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```
En iOS: verifica `ios/Runner/Info.plist` incluya:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Se necesita acceso a la ubicación para registrar actas</string>
```
