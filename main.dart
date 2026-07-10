import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_service.dart';
import 'home_screen.dart';

const kAccent   = Color(0xFF7C5CFC);
const kBg       = Color(0xFF0F1724);
const kSurface  = Color(0xFF1A2436);
const kSurface2 = Color(0xFF223048);
const kBorder   = Color(0xFF2E3F58);
const kGreen    = Color(0xFF4ADE80);
const kYellow   = Color(0xFFFBBF24);
const kRed      = Color(0xFFF87171);
const kTextMuted = Color(0xFF7A8FA6);
const kText     = Color(0xFFE8EEF7);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const EstudiaYaApp());
}

class EstudiaYaApp extends StatelessWidget {
  const EstudiaYaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'EstudiaYa',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: const ColorScheme.dark(primary: kAccent),
      scaffoldBackgroundColor: kBg,
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}
