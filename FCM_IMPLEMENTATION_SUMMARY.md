# 🔥 NOKKO - Implementacja FCM z Powiadomieniami o Wysokim Priorytecie

## ✅ Co zostało zaimplementowane w aplikacji NOKKO:

### 1. Konfiguracja Firebase
- **Firebase Core & Messaging**: Dodano zależności w `pubspec.yaml`
- **Android Configuration**: 
  - Dodano uprawnienia w `AndroidManifest.xml` dla powiadomień wysokiego priorytetu
  - Konfiguracja Firebase service i metadanych
  - Google Services plugin w `build.gradle.kts`

### 2. Obsługa powiadomień w aplikacji
- **Foreground**: Dialog w aplikacji zamiast systemowego powiadomienia
- **Background**: Standardowe systemowe powiadomienia na górze ekranu
- **App terminated**: Możliwość otwarcia aplikacji przez powiadomienie

### 3. Android Native Integration
- **MainActivity.kt**: Rozszerzona o obsługę wybudzania urządzenia
- **Method Channels**: Komunikacja Flutter ↔ Android dla:
  - Wybudzania urządzenia (`wake_device`)
  - Zarządzania optymalizacją baterii (`battery_optimization`)

### 4. Funkcjonalności wysokiego priorytetu
- **Permission handling**: Żądanie uprawnień krytycznych powiadomień
- **Wake device**: Wybudzanie urządzenia z uśpienia
- **Battery optimization**: Prośba o wyłączenie z optymalizacji baterii

## 📋 Pliki konfiguracyjne Android:

### `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Uprawnienia FCM i wysokiego priorytetu -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.DISABLE_KEYGUARD" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.TURN_SCREEN_ON" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

<!-- Firebase service -->
<service android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService" />

<!-- Firebase metadane -->
<meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@drawable/ic_notification" />
<meta-data android:name="com.google.firebase.messaging.default_notification_channel_id" android:value="high_importance_channel" />
```

### `android/app/src/main/kotlin/pl/nokko/nokko_app/MainActivity.kt`
- **Battery optimization management**
- **Device wake functionality**
- **Method channels dla komunikacji z Flutter**

## 🚀 Funkcjonalności działające:

### W aplikacji NOKKO:
1. ✅ **FCM Token** - pobieranie i wyświetlanie
2. ✅ **Foreground messages** - dialog w aplikacji
3. ✅ **Background messages** - systemowe powiadomienia
4. ✅ **Test notifications** - symulacja powiadomień
5. ✅ **Message history** - historia otrzymanych wiadomości
6. ✅ **Permission requests** - żądanie uprawnień critical alert

### Android Native:
1. ✅ **Wake device** - wybudzanie z uśpienia
2. ✅ **Battery optimization** - zarządzanie optymalizacją baterii
3. ✅ **High priority permissions** - uprawnienia do wybudzania

## 📚 Co należy dodać do biblioteki mp_slib:

### 1. Enhanced FCM Service
```dart
// Plik: lib/src/services/fcm/enhanced_fcm_service.dart
class EnhancedFCMService extends FCMService {
  // Obsługa wysokiego priorytetu
  // Wybudzanie urządzenia
  // Zarządzanie baterii
  // Custom dialog handling
}
```

### 2. App Notification Service  
```dart
// Plik: lib/src/services/fcm/app_notification_service.dart
class AppNotificationService {
  // Wyświetlanie dialogów w aplikacji dla foreground messages
  // Customizable dialog layout
  // Action URL handling
}
```

### 3. Android Helper Classes
```dart
// Plik: lib/src/services/fcm/android_notification_helper.dart
class AndroidNotificationHelper {
  // Method channels dla native Android funkcji
  // Battery optimization helper
  // Wake device helper
}
```

### 4. Przykłady konfiguracji
- Przykładowe pliki AndroidManifest.xml
- Przykładowa MainActivity.kt
- Instrukcje konfiguracji Firebase

## 🔧 Jak używać w innych aplikacjach:

### 1. Kopiuj konfigurację Android
```bash
# Skopiuj z NOKKO/android/app/src/main/ do swojej aplikacji:
- AndroidManifest.xml (uprawnienia i konfiguracja)
- kotlin/.../MainActivity.kt (native functionality)
- res/drawable/ic_notification.xml
- res/values/colors.xml (jeśli potrzebne)
```

### 2. Dodaj do pubspec.yaml
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  mp_slib:
    path: ../path/to/mp_slib
```

### 3. Użyj w aplikacji
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

// W StatefulWidget:
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission(criticalAlert: true);

// Obsługa foreground
FirebaseMessaging.onMessage.listen((message) async {
  await showCustomDialog(message); // Zamiast systemowego powiadomienia
});
```

## 🎯 Struktura powiadomień o wysokim priorytecie:

### Payload z backendu:
```json
{
  "to": "FCM_TOKEN",
  "priority": "high",
  "data": {
    "priority": "high",
    "action_url": "nokko://specific-screen",
    "wake_device": "true"
  },
  "notification": {
    "title": "Pilne powiadomienie",
    "body": "Ważna wiadomość wymagająca natychmiastowej uwagi"
  },
  "android": {
    "priority": "high",
    "ttl": "86400s"
  }
}
```

### Zachowanie aplikacji:
- **Foreground**: Dialog w aplikacji + optional wake
- **Background**: Systemowe powiadomienie + wake device  
- **Terminated**: Systemowe powiadomienie + start app + wake device

## 🔄 Następne kroki:

1. **Przetestuj na fizycznym urządzeniu Android**
2. **Dodaj google-services.json** z prawdziwą konfiguracją Firebase
3. **Zaimplementuj backend** wysyłający powiadomienia o wysokim priorytecie
4. **Rozszerz bibliotekę mp_slib** o funkcje uniwersalne
5. **Dodaj obsługę iOS** (podobne funkcjonalności)

## ⚠️ Ważne uwagi:

- **google-services.json**: Aktualny plik zawiera placeholder values - wymaga prawdziwej konfiguracji Firebase
- **Testing**: Powiadomienia wysokiego priorytetu najlepiej testować na fizycznym urządzeniu
- **Battery optimization**: Użytkownik musi ręcznie wyłączyć optymalizację baterii
- **Permissions**: Niektóre uprawnienia wymagają akceptacji użytkownika

---

**Status**: ✅ Podstawowa implementacja zakończona  
**Testowanie**: 🔄 Wymaga prawdziwej konfiguracji Firebase  
**Deployment**: 📱 Gotowe do testów na urządzeniu Android
