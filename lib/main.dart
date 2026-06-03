import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:zona_x_16_4/core/theme/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:io' show Platform;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zona_x_16_4/features/auth/presentation/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preserve splash screen while initializing
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('app_box');

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not loaded: $e');
  }

  // Initialize Mapbox only on mobile platforms
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
      if (mapboxToken != null && mapboxToken.isNotEmpty) {
        mapbox.MapboxOptions.setAccessToken(mapboxToken);
        debugPrint('Mapbox initialized with access token');
      } else {
        debugPrint('Warning: MAPBOX_ACCESS_TOKEN not found in .env file');
      }
    } catch (e) {
      debugPrint('Warning: Mapbox initialization failed: $e');
    }
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: "https://xoiqadbokgbrnwgthzfl.supabase.co",
      anonKey: "sb_publishable_wsTLf4VUTJtr66kGcvUUaw_dM0V-Pvr",
    );
  } catch (e) {
    debugPrint('Warning: Supabase initialization failed: $e');
  }

  // Initialize theme provider
  try {
    final themeProvider = ThemeProvider();
    await themeProvider.init();

    runApp(MyApp(themeProvider: themeProvider));
  } catch (e) {
    debugPrint('Error initializing theme provider: $e');
    // Fallback in case of theme provider initialization failure
    runApp(MyApp(themeProvider: ThemeProvider()));
  }
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
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
              // Dismiss splash screen when app is ready
              FlutterNativeSplash.remove();

              return MaterialApp(
                title: 'ZonaX',
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                initialRoute: '/',
                routes: {
                  '/': (context) => const AuthGate(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
