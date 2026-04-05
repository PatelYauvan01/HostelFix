import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/screens/role_selection_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/warden_dashboard.dart';
import 'services/remember_me_service.dart';

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
      home: const StartupGate(),
    );
  }
}

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  Future<Widget> _resolveHome() async {
    final rememberMeService = RememberMeService();
    final isRemembered = await rememberMeService.isRemembered();
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      return const RoleSelectionScreen();
    }

    if (!isRemembered) {
      await Supabase.instance.client.auth.signOut();
      await rememberMeService.clear();
      return const RoleSelectionScreen();
    }

    final role = await rememberMeService.rememberedRole();
    if (role == 'warden') {
      return const WardenDashboard();
    }

    if (role == 'student') {
      return const StudentDashboard();
    }

    return const RoleSelectionScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolveHome(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data ?? const RoleSelectionScreen();
      },
    );
  }
}