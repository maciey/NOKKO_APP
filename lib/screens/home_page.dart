import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mp_slib/mp_slib.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      // Użyj EnhancedFCMService z mp_slib
      await EnhancedFCMService.initialize(
        foregroundHandler: (message) async {
          setState(() {
            _receivedMessages.add(
              '📱 Foreground: ${message.notification?.title} - ${message.notification?.body}'
            );
          });
          
          // Użyj dialogu z mp_slib z customowymi ustawieniami NOKKO
          await showMPFCMDialog(
            context,
            message,
            accentColor: Colors.orange,
            defaultTitle: 'Powiadomienie NOKKO',
            closeButtonText: 'Zamknij',
            openButtonText: 'Otwórz',
            onActionPressed: () {
              // Custom akcja dla NOKKO
              print('NOKKO Action URL: ${message.data['action_url']}');
            },
          );
        },
        openedAppHandler: (message) {
          setState(() {
            _receivedMessages.add(
              '� Clicked: ${message.notification?.title} - ${message.notification?.body}'
            );
          });
        },
        initialMessageHandler: (message) {
          setState(() {
            _receivedMessages.add(
              '� App opened by: ${message.notification?.title} - ${message.notification?.body}'
            );
          });
        },
        tokenHandler: (token) {
          setState(() {
            _fcmToken = token;
          });
          print('🔥 NOKKO FCM Token: $token');
        },
      );
      
    } catch (e) {
      print('❌ Błąd inicjalizacji FCM: $e');
    }
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

    // Użyj dialogu z mp_slib
    await showMPFCMDialog(
      context,
      testMessage,
      accentColor: Colors.orange,
      defaultTitle: 'NOKKO Test',
      onActionPressed: () {
        print('NOKKO Test Action: ${testMessage.data['action_url']}');
      },
    );
    
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
                    const Text(
                      '✅ Wybudzanie urządzenia z uśpienia',
                      style: TextStyle(color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🔧 Powered by mp_slib - Enhanced FCM Service',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
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
                        // Prosty dialog potwierdzenia
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
                        
                        if (result == true) {
                          // Pokazanie prostego SnackBar zamiast LoadingDialog
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
                              color: Colors.orange.withAlpha(25),
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
