import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mp_slib/mp_slib.dart';

// Instancja local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Custom handler dla NOKKO - logika specyficzna dla tej aplikacji
@pragma('vm:entry-point')
Future<void> nokkoBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔥 NOKKO Custom logic: ${message.notification?.title}');
  // Tutaj można dodać specyficzną logikę dla NOKKO
  // np. zapisywanie do lokalnej bazy danych, specjalne akcje, itp.
}

// GlobalKey dla dostępu do Navigator - eksportowany
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicjalizacja Firebase tylko na platformach wspieranych
  if (!kIsWeb) {
    await Firebase.initializeApp();
    
    // Inicjalizacja local notifications
    await _initializeLocalNotifications();
    
    // Ustaw custom handler dla NOKKO z mp_slib
    setMPBackgroundHandler(nokkoBackgroundHandler);
    
    // Użyj uniwersalnego handlera z mp_slib
    FirebaseMessaging.onBackgroundMessage(mpUniversalBackgroundHandler);
  }
  
  runApp(const MyApp());
}

// Funkcja inicjalizacji local notifications
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      debugPrint('Local notification clicked: ${response.payload}');
    },
  );
  
  // Stwórz channel z własnym dźwiękiem
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'nokko_channel',
    'NOKKO Notifications',
    description: 'Powiadomienia NOKKO z własnym dźwiękiem',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('nokko_signal'),
    enableVibration: true,
  );
  
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NOKKO',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF20571)),
      ),
      home: _HomePage(),      
    );
  }
}

class _HomePage extends StatefulWidget {
  @override
  State<_HomePage> createState() => __HomePageState();
}

class __HomePageState extends State<_HomePage> {
  String appVersion = 'NOKKO 1.0.0';
  String? _fcmToken;
  final List<String> _receivedMessages = [];

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      // Inicjalizacja Firebase Messaging
      final messaging = FirebaseMessaging.instance;
      
      // Żądanie uprawnień
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true, // Krytyczne powiadomienia
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('🔥 NOKKO: Uprawnienia do powiadomień przyznane');
      }
      
      // Pobierz token FCM
      final token = await messaging.getToken();
      setState(() {
        _fcmToken = token;
      });

      // Nasłuchiwanie wiadomości w foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        setState(() {
          _receivedMessages.add(
            '📱 Foreground: ${message.notification?.title} - ${message.notification?.body}'
          );
        });
        
        // Wyświetl lokalne powiadomienie z własnym dźwiękiem
        await _showLocalNotification(message);
        
        // Wyświetl niestandardowy dialog zamiast systemowego powiadomienia
        await _showNotificationDialog(message);
      });

      // Obsługa kliknięć w powiadomienia
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        setState(() {
          _receivedMessages.add(
            '👆 Clicked: ${message.notification?.title} - ${message.notification?.body}'
          );
        });
      });

      debugPrint('🔥 NOKKO FCM zainicjalizowany. Token: $token');
      
    } catch (e) {
      debugPrint('❌ Błąd inicjalizacji FCM: $e');
    }
  }

  // Funkcja do wyświetlania lokalnych powiadomień z własnym dźwiękiem
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'nokko_channel',
      'NOKKO Notifications',
      channelDescription: 'Powiadomienia NOKKO z własnym dźwiękiem',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('nokko_signal'),
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      sound: 'nokko_signal.mp3',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? 'NOKKO',
      message.notification?.body ?? 'Nowe powiadomienie',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<void> _showNotificationDialog(RemoteMessage message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Image.asset(
                'assets/NOKKO_logo_white.png',
                height: 20,
                width: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.notification?.title ?? 'Powiadomienie NOKKO',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.notification?.body?.isNotEmpty == true) ...[
                  Text(
                    message.notification!.body!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                ],
                if (message.data.isNotEmpty) ...[
                  const Text(
                    'Dodatkowe informacje:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...message.data.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zamknij'),
            ),
            if (message.data.containsKey('action_url')) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  debugPrint('Action URL: ${message.data['action_url']}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF20571),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Otwórz'),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _sendTestNotification() async {
    final testMessage = RemoteMessage(
      messageId: 'test-${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'priority': 'high',
        'test': 'true',
        'action_url': 'nokko://home',
        'source': 'test',
      },
      notification: const RemoteNotification(
        title: '🔥 NOKKO Test',
        body: 'To jest testowe powiadomienie z własnym dźwiękiem NOKKO',
      ),
    );

    // Wyświetl lokalne powiadomienie z własnym dźwiękiem
    await _showLocalNotification(testMessage);
    
    await _showNotificationDialog(testMessage);
    
    if (mounted) {
      setState(() {
        _receivedMessages.add(
          '🧪 Test: ${testMessage.notification?.title} - ${testMessage.notification?.body}'
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/NOKKO_logo_white.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            Text('NOKKO - $appVersion'),
          ],
        ),
        backgroundColor: const Color(0xFFF20571),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo Section
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Image.asset(
                  'assets/NOKKO_logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // FCM Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/NOKKO_logo.png',
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Push Notifications Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'FCM Token:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      _fcmToken ?? 'Ładowanie...',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '✅ Obsługa powiadomień o wysokim priorytecie',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '✅ Własny dźwięk powiadomień NOKKO',
                      style: TextStyle(color: Colors.green),
                    ),
                    const Text(
                      '✅ Wyświetlanie dialogów w aplikacji (foreground)',
                      style: TextStyle(color: Colors.green),
                    ),
                    const Text(
                      '✅ Systemowe powiadomienia (background)',
                      style: TextStyle(color: Colors.green),
                    ),
                    const Text(
                      '✅ Wybudzanie urządzenia z uśpienia',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Funkcje Testowe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ElevatedButton.icon(
                      onPressed: _sendTestNotification,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Test Powiadomienia'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF20571),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ElevatedButton.icon(
                      onPressed: () async {
                        bool? result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Potwierdzenie'),
                            content: const Text('Pobrać APK?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Nie'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Tak'),
                              ),
                            ],
                          ),
                        );
                        
                        if (result == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pobieranie APK... (symulacja)'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('APK Reinstall'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Messages History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historia Powiadomień',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (_receivedMessages.isEmpty)
                      const Text(
                        'Brak otrzymanych powiadomień. Użyj przycisku "Test Powiadomienia" powyżej.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ...(_receivedMessages.reversed.take(5)).map((message) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF20571).withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      
                    if (_receivedMessages.length > 5)
                      Text(
                        '...i ${_receivedMessages.length - 5} więcej',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
