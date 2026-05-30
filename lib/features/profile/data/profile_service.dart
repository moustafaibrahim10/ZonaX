import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zona_x_16_4/features/profile/domain/models/profile_model.dart';

class ProfileService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Get current user profile with all data
  Future<ProfileModel?> getUserProfile() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      // TODO: Replace with actual API calls when backend is ready
      // For now, return dummy data for testing
      return _getDummyProfile(user.email ?? 'user@example.com');
      
      // Uncomment below when backend tables are ready:
      /*
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
      */
    } catch (e) {
      print('Error fetching profile: $e');
      // Return dummy data on error
      return _getDummyProfile('user@example.com');
    }
  }

  // Dummy profile data for testing
  ProfileModel _getDummyProfile(String email) {
    return ProfileModel(
      id: 'dummy-id-123',
      name: 'Ahmed Hassan',
      email: email,
      rating: 4.8,
      rank: 5,
      vehicleModel: 'Toyota Camry 2023',
      vehiclePlate: 'ABC 1234',
      earnedThisMonth: 14500,
      tripsThisMonth: 324,
      onlineHoursThisMonth: 186,
      achievements: [
        Achievement(
          id: '1',
          title: 'Rising Star',
          description: 'Earnings increased by 20% this week',
          icon: 'star',
          unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Achievement(
          id: '2',
          title: '5-Star Service',
          description: 'Maintained 4.8+ rating for 30 days',
          icon: 'grade',
          unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
    );
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

