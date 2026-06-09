import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Validate Egyptian phone number (+20 followed by 10 digits)
  bool _isValidPhoneEgypt(String phone) {
    return RegExp(r'^\+20\d{10}$').hasMatch(phone.trim());
  }

  // Get password strength (0-3)
  int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    if (password.length < 8) return 2;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) {
      return 3;
    }
    return 2;
  }

  // Format phone number
  String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('20')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }

  // SIGN IN
  Future<String?> signIn(String email, String pass) async {
    if (email.trim().isEmpty || pass.trim().isEmpty) {
      return "Email and password cannot be empty";
    }

    if (!_isValidEmail(email)) {
      return "Invalid email format";
    }

    try {
      // Try to sign in
      await _supabaseClient.auth.signInWithPassword(
        email: email.trim(),
        password: pass.trim(),
      );

      return null; // success
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();

      // Handle different error cases
      if (message.contains('email not confirmed')) {
        return "Please confirm your email before signing in";
      } else if (message.contains('invalid login credentials')) {
        // Supabase returns this for both wrong password and non-existent accounts
        return "Invalid email or password. Please check your credentials or sign up if you don't have an account.";
      } else if (message.contains('user not found') ||
          message.contains('no user found')) {
        return "This account doesn't exist. Please sign up first.";
      } else if (message.contains('too many')) {
        return "Too many login attempts. Please try again later.";
      } else {
        return "Authentication error: ${e.message}";
      }
    } catch (e) {
      return "Unexpected error occurred: ${e.toString()}";
    }
  }

  // SIGN UP
  Future<String?> signUp(
    String email,
    String pass,
    String name,
    String phone,
    String vehicleType,
  ) async {
    if (email.trim().isEmpty ||
        pass.trim().isEmpty ||
        name.trim().isEmpty ||
        phone.trim().isEmpty ||
        vehicleType.trim().isEmpty) {
      return "All fields cannot be empty";
    }

    if (!_isValidEmail(email)) {
      return "Invalid email format";
    }

    if (pass.length < 6) {
      return "Password must be at least 6 characters";
    }

    // Basic phone validation (adjust as needed)
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(phone.trim())) {
      return "Invalid phone number format";
    }

    // Specific validation for phone numbers
    if (!_isValidPhoneEgypt(phone)) {
      return "Invalid Egyptian phone number format. It should start with +20 followed by 10 digits.";
    }

    try {
      final response = await _supabaseClient.auth.signUp(
        email: email.trim(),
        password: pass.trim(),
      );

      if (response.user != null) {
        try {
          // Insert profile data
          await _supabaseClient.from('profiles').insert({
            'id': response.user!.id,
            'name': name.trim(),
            'phone': phone.trim(),
            'email': email.trim(),
            'vehicle_type': vehicleType.trim(),
          });
        } on PostgrestException {
          // Profile insert failed, but user is created
          return "Account created, but profile setup failed. Please contact support.";
        }
      }

      return null; // success
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        return "An account with this email already exists. Please sign in instead.";
      } else {
        return "Sign up failed: ${e.message}";
      }
    } catch (e) {
      return "Unexpected error occurred: ${e.toString()}";
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // FORGOT PASSWORD
  Future<String?> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      return "Email cannot be empty";
    }

    if (!_isValidEmail(email)) {
      return "Invalid email format";
    }

    try {
      await _supabaseClient.auth.resetPasswordForEmail(email.trim());
      return null; // success
    } on AuthException catch (e) {
      return "Failed to send reset email: ${e.message}";
    } catch (e) {
      return "Unexpected error: ${e.toString()}";
    }
  }

  String? getCurrentUserEmail() {
    final session = _supabaseClient.auth.currentSession;
    return session?.user.email;
  }
}
