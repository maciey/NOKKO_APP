# Implementacja Własnego Dźwięku Powiadomień NOKKO

## Przegląd
Aplikacja NOKKO została zaktualizowana aby używać własnego pliku dźwiękowego `nokko_signal.mp3` dla powiadomień push zarówno w trybie foreground jak i background.

## Zmiany w Plikach

### 1. pubspec.yaml
- Dodano `assets/nokko_signal.mp3` do sekcji assets
- Dodano dependency `flutter_local_notifications: ^17.2.3`

### 2. Struktura Plików
```
assets/
  nokko_signal.mp3                    # Plik źródłowy

android/app/src/main/res/raw/
  nokko_signal.mp3                    # Kopia dla Androida

ios/Runner/
  nokko_signal.mp3                    # Kopia dla iOS
```

### 3. AndroidManifest.xml
- Dodano meta-data dla domyślnego dźwięku powiadomień:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_sound"
    android:resource="@raw/nokko_signal" />
```
- Zmieniono domyślny channel na `nokko_channel`

### 4. main.dart
- Dodano import `flutter_local_notifications`
- Dodano globalną instancję `FlutterLocalNotificationsPlugin`
- Dodano funkcję `_initializeLocalNotifications()` która:
  - Inicjalizuje local notifications
  - Tworzy notification channel "nokko_channel" z własnym dźwiękiem
  - Konfiguruje RawResourceAndroidNotificationSound('nokko_signal')
- Dodano funkcję `_showLocalNotification()` dla wyświetlania powiadomień z własnym dźwiękiem
- Zaktualizowano obsługę powiadomień w foreground aby używać lokalnych powiadomień
- Zaktualizowano funkcję testową

## Funkcjonalność

### Tryb Foreground
- Aplikacja wyświetla lokalne powiadomienie z własnym dźwiękiem
- Następnie wyświetla dialog w aplikacji
- Oba wydarzenia są logowane w historii

### Tryb Background
- Firebase używa konfiguracji z AndroidManifest.xml
- Powiadomienia systemowe odtwarzają dźwięk `nokko_signal.mp3`
- Domyślny channel to `nokko_channel` z wysokim priorytetem

### Obsługiwane Platformy
- **Android**: Używa pliku z `/res/raw/nokko_signal.mp3`
- **iOS**: Używa pliku z bundle `nokko_signal.mp3`
- **Web**: Brak obsługi (ograniczenia przeglądarki)

## Testowanie
1. Uruchom aplikację na urządzeniu/emulatorze
2. Użyj przycisku "Test Powiadomienia"
3. Sprawdź czy słyszysz własny dźwięk NOKKO
4. Przetestuj powiadomienia background wysyłając przez Firebase Console

## Konfiguracja Notification Channel

### Android
```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'nokko_channel',
  'NOKKO Notifications',
  description: 'Powiadomienia NOKKO z własnym dźwiękiem',
  importance: Importance.high,
  sound: RawResourceAndroidNotificationSound('nokko_signal'),
  enableVibration: true,
);
```

### iOS
```dart
const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
  sound: 'nokko_signal.mp3',
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
);
```

## Uwagi Implementacyjne
- Plik dźwiękowy musi być w formacie obsługiwanym przez obie platformy (MP3 działa)
- Na Androidzie używamy RawResourceAndroidNotificationSound
- Na iOS plik musi być w bundle aplikacji
- Channel ID musi być konsystentny między AndroidManifest.xml a kodem Dart
