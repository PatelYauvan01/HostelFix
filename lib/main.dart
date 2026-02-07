import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'screens/warden_dashboard.dart';
import 'auth/screens/login_screen.dart';

void main() {
  runApp(const HostelFixApp());
}

class HostelFixApp extends StatelessWidget {
  const HostelFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HostelFix',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D31FA),
          primary: const Color(0xFF2D31FA),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}