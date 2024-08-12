import 'package:flutter/material.dart';
import 'package:restaurante/layouts/pages/caja.dart';
import 'package:restaurante/layouts/pages/host.dart';
import 'package:restaurante/layouts/pages/mesero.dart';
import 'package:restaurante/layouts/pages/cocina.dart';
import 'package:restaurante/layouts/pages/corredor.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restaurante/layouts/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://wohdnaoemqhfncasmtaq.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvaGRuYW9lbXFoZm5jYXNtdGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI5OTMyNDksImV4cCI6MjAzODU2OTI0OX0.ju9Vm0B6XD935ZaZEKFVscilJ-CvMa-EppyfzsjbyXg",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/host': (context) => HostPage(),
        '/mesero': (context) => MeseroPage(),
        '/cocina': (context) => CocinaPage(),
        '/corredor': (context) => CorredorPage(),
        '/caja': (context) => CajaPage(),
        /*'/admin': (context) => AdminScreen(),*/
      },
    );
  }
}
