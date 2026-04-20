import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zona_x_16_4/features/login/presentation/login_screen.dart';
import 'package:zona_x_16_4/features/profile/presentation/profile_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //Listen to auth state changes
        stream: Supabase.instance.client.auth.onAuthStateChange,
        // build appropriate page based on auth state
        builder: (context, snapshot) {
          // If Loading..
          if (snapshot.connectionState == ConnectionState.waiting) {
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
          // check if there is a valid session currently
          final session = snapshot.hasData ? snapshot.data!.session : null;
          if (session != null) {
            return const ProfilePage();
          }
          else {
            return const LoginScreen();
          }
        }
    );
  }
}

