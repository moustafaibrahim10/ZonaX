import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zona_x_16_4/features/profile/domain/models/profile_model.dart';

class ProfileService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Get current user profile with all data
  Future<ProfileModel?> getUserProfile() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Fetch profile data from profiles table
      final profileResponse = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Fetch statistics
      final statsResponse = await _supabaseClient
          .from('user_statistics')
          .select()
          .eq('user_id', user.id)
          .single();

      // Fetch achievements
      final achievementsResponse = await _supabaseClient
          .from('user_achievements')
          .select()
          .eq('user_id', user.id);

      // Combine all data
      final profileMap = {
        ...profileResponse,
        ...statsResponse,
        'achievements': achievementsResponse,
      };

      return ProfileModel.fromJson(profileMap);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Update profile information
  Future<bool> updateProfile({
    required String name,
    required String vehicleModel,
    required String vehiclePlate,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return false;

      await _supabaseClient.from('profiles').update({
        'name': name,
        'vehicle_model': vehicleModel,
        'vehicle_plate': vehiclePlate,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Get user's monthly statistics
  Future<Map<String, dynamic>?> getMonthlyStats() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      final response = await _supabaseClient
          .from('user_statistics')
          .select()
          .eq('user_id', user.id)
          .single();

      return response;
    } catch (e) {
      print('Error fetching stats: $e');
      return null;
    }
  }

  // Get achievements
  Future<List<Achievement>> getAchievements() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await _supabaseClient
          .from('user_achievements')
          .select()
          .eq('user_id', user.id)
          .order('unlocked_at', ascending: false);

      return (response as List)
          .map((a) => Achievement.fromJson(a))
          .toList();
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  // Export user data
  Future<bool> exportUserData() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return false;

      // Call a backend function or endpoint to generate export
      // This could be a CSV, PDF, or JSON file
      final response = await _supabaseClient.functions.invoke(
        'export_user_data',
        body: {'user_id': user.id},
      );

      return response != null;
    } catch (e) {
      print('Error exporting data: $e');
      return false;
    }
  }
}

