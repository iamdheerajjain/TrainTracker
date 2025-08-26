import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/train_models.dart';
import './supabase_service.dart';

class AuthService {
  static final client = SupabaseService.instance.client;

  // Get current user
  static User? get currentUser => client.auth.currentUser;

  // Get current session
  static Session? get currentSession => client.auth.currentSession;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Update user profile
  static Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );
      return response;
    } catch (error) {
      throw Exception('User update failed: $error');
    }
  }

  // Get user profile from database
  static Future<UserProfile?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      return response != null ? UserProfile.fromJson(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  // Update user profile in database
  static Future<UserProfile> updateUserProfile({
    String? fullName,
    String? phone,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      if (!isAuthenticated) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (preferences != null) updateData['preferences'] = preferences;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('user_profiles')
          .update(updateData)
          .eq('id', currentUser!.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // OAuth sign in (Google, Facebook, etc.)
  static Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      return await client.auth.signInWithOAuth(provider);
    } catch (error) {
      throw Exception('OAuth sign-in failed: $error');
    }
  }

  // Check if email is already registered
  static Future<bool> isEmailRegistered(String email) async {
    try {
      // This would require a custom function in Supabase
      // For now, we'll let the sign-up process handle duplicate detection
      return false;
    } catch (error) {
      return false;
    }
  }

  // Verify OTP
  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      final response = await client.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
      return response;
    } catch (error) {
      throw Exception('OTP verification failed: $error');
    }
  }

  // Resend OTP
  static Future<void> resendOTP({
    required String email,
    required OtpType type,
  }) async {
    try {
      await client.auth.resend(
        email: email,
        type: type,
      );
    } catch (error) {
      throw Exception('OTP resend failed: $error');
    }
  }
}
