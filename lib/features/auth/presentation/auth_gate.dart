import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zona_x_16_4/core/network/dio_factory.dart';
import 'package:zona_x_16_4/features/login/presentation/login_screen.dart';
import 'package:zona_x_16_4/features/home/presentation/screens/main_screen.dart';

import 'package:zona_x_16_4/features/auth/presentation/onboarding_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    const secureStorage = FlutterSecureStorage();
    // 'PREFS_KEY_TOKEN' is defined in AuthLocalDataSourceImpl
    final token = await secureStorage.read(key: 'PREFS_KEY_TOKEN');
    
    if (mounted) {
      if (token != null && token.isNotEmpty) {
        // Restore the token in DioFactory for authenticated API calls
        DioFactory.setAuthToken(token);
      }
      setState(() {
        _isAuthenticated = token != null && token.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ZonaX_Dversion.png',
                height: 120.h,
                width: 120.w,
              ),
              SizedBox(height: 20.h),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    final onboardingCompleted = Hive.box('app_box').get('onboarding_completed', defaultValue: false) ?? false;
    if (!onboardingCompleted) {
      return const OnboardingScreen();
    }

    if (_isAuthenticated) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
