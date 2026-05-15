import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

part 'profile_provider.g.dart';

class UserProfileData {
  final String fullName;
  final String email;
  final String phoneNumber;

  UserProfileData({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  UserProfileData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) {
    return UserProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<UserProfileData?> build() async {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    if (user == null) return null;

    String fullName = user.userMetadata?['full_name'] ?? 'User';
    final String email = user.email ?? '';
    String phoneNumber = user.userMetadata?['phone_number'] ?? '';

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        fullName = data['full_name'] as String? ?? fullName;
        phoneNumber = data['phone_number'] as String? ?? phoneNumber;
      }
    } catch (e) {
      // Fallback to user metadata if DB fetch fails or doesn't have the column
    }

    return UserProfileData(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    // Keep old data to avoid flashing
    final previousState = state.value;

    try {
      // 1. Update user metadata in Supabase auth
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'phone_number': phoneNumber,
          },
        ),
      );

      // 2. Update profiles table - full_name (which definitely exists)
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'full_name': fullName})
            .eq('id', user.id);
      } catch (_) {
        // Silently catch database failures
      }

      // 3. Update profiles table - phone_number (separately in case column doesn't exist)
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'phone_number': phoneNumber})
            .eq('id', user.id);
      } catch (_) {
        // Silently catch column missing error
      }

      // 4. Manually update local state immediately for instantaneous UI response
      state = AsyncValue.data(
        UserProfileData(
          fullName: fullName,
          email: user.email ?? '',
          phoneNumber: phoneNumber,
        ),
      );

      // 5. Tell AuthNotifier to fetch the latest user object so ref.watch(authProvider)
      // yields the updated user metadata if widgets build later.
      ref.read(authProvider.notifier).refreshUser();

      // 6. Refresh the user profile provider to fetch the definitive database state
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      if (previousState != null) {
        state = AsyncValue.data(previousState);
      }
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.email == null) {
      throw 'User session not found';
    }

    try {
      // 1. Verify the current password by performing a silent sign-in
      await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );
    } catch (e) {
      throw 'The current password you entered is incorrect.';
    }

    try {
      // 2. Once verified, update the password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw 'Failed to update password: ${e.toString()}';
    }
  }

  Future<void> deleteAccount() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      // Delete the profile row
      await Supabase.instance.client.from('profiles').delete().eq('id', user.id);
    } catch (_) {
      // Catch block to proceed even if deletion of profile fails
    }
    
    // Finally sign out
    await ref.read(authProvider.notifier).signOut();
  }
}
