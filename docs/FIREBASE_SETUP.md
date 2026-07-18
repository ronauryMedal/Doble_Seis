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

## Estado actual (Android)

- [x] Proyecto Firebase `doble-seis-6788b`
- [x] `android/app/google-services.json`
- [x] Plugin Gradle `com.google.gms.google-services`
- [x] Paquetes: `firebase_core`, `firebase_auth`, `firebase_database`
- [x] `FirebaseCloudSync` + `GameRepository(cloudSync: …)`
- [ ] Activar **Authentication → Anónimo**
- [ ] Crear **Realtime Database** (si aún no)
- [ ] Pegar reglas de seguridad (abajo)
- [ ] (Opcional) App iOS + `flutterfire configure`

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
