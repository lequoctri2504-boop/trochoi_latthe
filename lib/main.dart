import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/services/firebase_service.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Safe Firebase initialization
  await FirebaseService().initialize();
  
  // Set portrait orientation lock (+1 UX!)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'IntelliFlip AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto', // Premium elegant standard font
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.cardBg,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
