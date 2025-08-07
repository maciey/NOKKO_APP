/*
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// MP LIB
import 'package:mp_slib/mp_slib.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appVersion = '';
  final FCMService _fcmService = FCMService();
  String? _fcmToken;
  final List<String> _receivedMessages = [];

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _initializeFCM();
  }

  void _loadAppVersion() async {
    final version = await Utils.getBuildVersion("NOKKO APP");
    
    setState(() {
      appVersion = version;
    });
  }

  Future<void> _initializeFCM() async {
    try {
      // Inicjalizacja podstawowego FCM service
      await _fcmService.initialize();
      
      // Pobierz token FCM
      setState(() {
        _fcmToken = _fcmService.fcmToken;
      });

      // Nasłuchiwanie wiadomości w foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        setState(() {
          _receivedMessages.add(
            '📱 Foreground: ${message.notification?.title} - ${message.notification?.body}'
          );
        });
        
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

      print('🔥 NOKKO FCM zainicjalizowany. Token: $_fcmToken');
      
    } catch (e) {
      print('❌ Błąd inicjalizacji FCM: $e');
    }
  }

  Future<void> _showNotificationDialog(RemoteMessage message) async {
    // Użyj standardowego AlertDialog
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Colors.orange,
                size: 24,
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
                  // Tutaj można dodać obsługę URL akcji
                  print('Action URL: ${message.data['action_url']}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
    // Symulacja otrzymania powiadomienia o wysokim priorytecie
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
        body: 'To jest testowe powiadomienie o wysokim priorytecie',
      ),
    );

    // Wyświetl jako dialog w aplikacji
    await _showNotificationDialog(testMessage);
    
    setState(() {
      _receivedMessages.add(
        '🧪 Test: ${testMessage.notification?.title} - ${testMessage.notification?.body}'
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔥 NOKKO - $appVersion'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FCM Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
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
                      '✅ Wyświetlanie dialogów w aplikacji (foreground)',
                      style: TextStyle(color: Colors.green),
                    ),
                    const Text(
                      '✅ Systemowe powiadomienia (background)',
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
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ElevatedButton.icon(
                      onPressed: () async {
                        bool answer = await CustomDialog.question_dialog(
                          context,
                          'Pobrać APK?',                                                                      
                          captionColor: Colors.red,
                        );
                        if (answer) {
                          LoadingDialog.show(context, 'Pobieranie APK...');
                          await Utils.getAppApk('https://www.nokko.pl/APP/app-release.apk');
                          LoadingDialog.hide(context);
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
                              color: Colors.orange.withOpacity(0.1),
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
*/