import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'screens/warden_dashboard.dart';
import 'auth/screens/login_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://wphtumqntjdlbtjjrvig.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwaHR1bXFudGpkbGJ0ampydmlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMzkwNTksImV4cCI6MjA4NjYxNTA1OX0.FqP1nugwugjJ9MFMap86e3mQj-mBBk5V8EnoDE06r58',
  );

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