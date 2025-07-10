import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/units_provider.dart';
import 'features/exercises/providers/workout_provider.dart';
import 'features/auth/pages/login_page.dart';
import 'navigation/main_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UnitsProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'MyGainz',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B2027)),
          useMaterial3: true,
          fontFamily: 'Manrope',
          textTheme: const TextTheme(
            // Headlines (used for page titles, large headers)
            headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            headlineMedium:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

            // Titles (used for section headers, card titles)
            titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),

            // Body text (main content, paragraphs)
            bodyLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            bodyMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            bodySmall: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),

            // Labels (buttons, form labels, small text)
            labelLarge: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            labelMedium: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            labelSmall: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF1B2027),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Color(0xFF1B2027),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Simplified debug button that's safer
                  ElevatedButton(
                    onPressed: () {
                      authProvider.forceCompleteInitialization();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show error state with recovery options
        if (authProvider.error != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading app',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      authProvider.clearError();
                      authProvider.forceCompleteInitialization();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show main app if logged in, otherwise show login
        if (authProvider.isLoggedIn) {
          return const MainFrame();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
