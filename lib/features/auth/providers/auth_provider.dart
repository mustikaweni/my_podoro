import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.data(null)) {
    _checkCurrentUser();
  }

  final _supabase = Supabase.instance.client;

  void _checkCurrentUser() {
    final user = _supabase.auth.currentUser;
    state = AsyncValue.data(user);
    
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      state = AsyncValue.data(data.session?.user);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      state = AsyncValue.data(response.user);
      
      // Jika session null, artinya email confirmation dibutuhkan.
      return response.session == null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'mypodoro://login-callback',
      );
    } catch (e) {
      rethrow;
    }
  }

  void refreshUser() {
    final user = _supabase.auth.currentUser;
    state = AsyncValue.data(user);
  }
}
