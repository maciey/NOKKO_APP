import 'package:flutter/material.dart';
// MP LIB
import 'package:mp_slib/mp_slib.dart'; 


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();    
  }

  void _loadAppVersion() async {
    final version = await Utils.getBuildVersion("NOKKO APP");
    
    setState(() {
      appVersion = version;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home - $appVersion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔥 NOKKO 🔥'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Z niestandardowym nagłówkiem i kolorem
                bool answer = await CustomDialog.question_dialog(
                                                                      context,
                                                                      'Pobrać APK?',                                                                      
                                                                      captionColor: Colors.red,
                );
                if (answer) {
                  // Wait
                  LoadingDialog.show(context, 'Pobieranie APK...');
                  // Download APK
                  await Utils.getAppApk('https://www.nokko.pl/APP/app-release.apk');

                  // Hide loading dialog
                  LoadingDialog.hide (context);
                }
              },
              child: const Text('APK Reinstall'),
            ),
          ],
        ),
      ),
    );
  }
}
