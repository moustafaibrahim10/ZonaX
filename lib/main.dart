import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:zona_x_16_4/features/auth/presentation/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not loaded: $e');
  }

  // Initialize Mapbox only on mobile platforms
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      // Mapbox initialization would go here for mobile
      // MapboxOptions.setAccessToken(...);
    } catch (e) {
      debugPrint('Warning: Mapbox initialization failed: $e');
    }
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
        url: "https://xoiqadbokgbrnwgthzfl.supabase.co",
        anonKey: "sb_publishable_wsTLf4VUTJtr66kGcvUUaw_dM0V-Pvr");
  } catch (e) {
    debugPrint('Warning: Supabase initialization failed: $e');
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      extensions: [AppColors.light()],
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      extensions: [AppColors.dark()],
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'ZonaX',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: const AuthGate(),
        );
      },
    );
  }
}
