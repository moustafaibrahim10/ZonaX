import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zona_x_16_4/features/auth/presentation/auth_gate.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';

void main() async {
  await Supabase.initialize(
      url: "https://xoiqadbokgbrnwgthzfl.supabase.co",
      anonKey: "sb_publishable_wsTLf4VUTJtr66kGcvUUaw_dM0V-Pvr");
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
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: AuthGate(),
        );
      },
    );
  }
}
