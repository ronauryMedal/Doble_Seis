# Firebase — checklist (Doble Seis)

Mientras implementas la cuenta, el código ya tiene:

- `lib/data/sync/cloud_sync.dart` — contrato
- `lib/data/sync/noop_cloud_sync.dart` — por defecto (solo Hive)
- `lib/data/sync/firebase_cloud_sync.dart` — Auth anónimo + Realtime Database
- `GameRepository` — Hive + push/pull de historial
- `lib/firebase_options.dart` + `Firebase.initializeApp` en `main.dart`

## 1. Crear proyecto

1. Entra a https://console.firebase.google.com
2. Crear proyecto (ej. `doble-seis`)
3. Añadir app **Android** (package name del `applicationId` en Gradle)
4. Descargar `google-services.json` → `android/app/`
5. (Opcional) Añadir app **iOS** + `GoogleService-Info.plist`

## 2. Activar productos

- **Authentication** → método **Anónimo** (para empezar)
- **Realtime Database** (recomendado para salas + historial) **o** Firestore

## 3. Dependencias (cuando tengas los archivos)

```yaml
# pubspec.yaml
firebase_core: ^3.x
firebase_auth: ^5.x
firebase_database: ^11.x   # o cloud_firestore
```

```bash
flutter pub get
flutterfire configure   # opcional, genera firebase_options.dart
```

## 4. Inicializar en `main.dart`

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

final repository = GameRepository(
  cloudSync: FirebaseCloudSync(), // cuando isConfigured => true
);
await repository.init();
```

## 5. Rutas sugeridas (Realtime Database)

```text
users/{uid}/history/{entryId}   ← GameHistoryEntry.toMap()
rooms/{roomCode}/session        ← sala en vivo (fase siguiente)
rooms/{roomCode}/status         ← open | closed
```

## 6. Cablear `FirebaseCloudSync`

1. Pon `isConfigured => true` tras `Firebase.initializeApp`
2. Completa `ensureSignedIn` / `pushHistoryEntry` / `pullHistoryEntries`
3. En Historial/Stats: `await repository.syncHistoryFromCloud()` antes de pintar

## Alerta GitHub: “Clave API de Google” en el repo

Las API keys de **Firebase cliente** no dan acceso de admin, pero GitHub las
marca igual. En este proyecto:

- `lib/firebase_options.dart` **ya no** incluye la key
- La key vive en `lib/core/config/firebase_api_key.local.dart` (gitignored)
- `android/app/google-services.json` también está gitignored
  (usa `google-services.json.example` como plantilla)

### Cerrar la alerta (hazlo tú en la consola)

1. [Google Cloud Console → Credenciales](https://console.cloud.google.com/apis/credentials?project=doble-seis-6788b)
2. Abre la API key expuesta → **Rotar clave** (o restringir a app Android
   `com.domino.score.domino_score` + tu SHA-1)
3. Descarga de nuevo `google-services.json` desde Firebase → `android/app/`
4. Actualiza `firebase_api_key.local.dart` con la key nueva
5. En GitHub → Security → Secret scanning → marca la alerta como **revocada**
6. Haz commit/push de estos cambios (sin volver a subir la key)

## Login con Google (historial entre dispositivos)

1. Firebase Console → **Authentication** → **Agregar proveedor** → **Google** → Habilitar
2. Anota el **ID de cliente web** que muestra Firebase
3. **Configuración del proyecto** → tu app Android → **Agregar huella digital**:
   - SHA-1 debug de este PC:
     `3D:03:FA:7B:3D:B0:39:77:74:FD:79:AE:41:C9:14:A2:D8:45:CD:F6`
   - Comando por si regeneras el keystore:
   ```bash
   keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
   ```
4. Descarga de nuevo `google-services.json` → `android/app/`
5. Pasa el Web client ID al arrancar (recomendado):
   ```bash
   flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
   ```
   o edita el `defaultValue` en `FirebaseCloudSync.webClientId`.

En la app: menú (☰) o **Partidas ganadas** → **Continuar con Google**.

## Reglas Realtime Database (empezar)

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
}
```

Si la URL de la DB no es `…-default-rtdb.firebaseio.com`, edita
`lib/firebase_options.dart` → `databaseURL`.
