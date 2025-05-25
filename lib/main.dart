import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini untuk SystemChrome

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter terinisialisasi
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // Ini yang membuat full screen
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Fullscreen App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Anda juga bisa memanggilnya di sini jika Anda ingin mengontrol full screen per halaman
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Penting: Kembalikan ke mode normal saat keluar dari layar ini
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Atau SystemUiMode.manual, overlays: SystemUiOverlay.values
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Screen App'),
      ),
      body: Center(
        child: Text('Aplikasi Anda sekarang full screen!'),
      ),
    );
  }
}