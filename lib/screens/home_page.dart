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
              onPressed: () {
                Utils.getAppApk('https://www.nokko.pl/APP/app-release.apk');
              },
              child: const Text('APK Reinstall'),
            ),
          ],
        ),
      ),
    );
  }
}
