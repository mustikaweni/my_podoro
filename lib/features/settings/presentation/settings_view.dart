import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../avatar/providers/avatar_provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'account_settings_screen.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _notificationsEnabled = true;
  bool _soundEffectsEnabled = true;

  IconData _getAvatarIcon(int id) {
    switch (id) {
      case 1:
        return Icons.smart_toy_rounded;
      case 2:
        return Icons.shield;
      case 3:
        return Icons.self_improvement;
      default:
        return Icons.person_outline_rounded;
    }
  }

  Color _getAvatarBg(int id, bool isDark) {
    switch (id) {
      case 1:
        return isDark ? const Color(0xFF2A3430) : const Color(0xFFF3F4F8);
      case 2:
        return isDark ? const Color(0xFF3F3A34) : const Color(0xFFE5E0DA);
      case 3:
        return isDark ? const Color(0xFF303255) : const Color(0xFFEAEBFA);
      default:
        return isDark ? const Color(0xFF282E45) : Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final avatarState = ref.watch(avatarNotifierProvider);
    final isDarkMode = ref.watch(darkModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF20263F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF14142B);
    final subTextColor = isDark ? const Color(0xFF9096A5) : Colors.grey.shade600;
    final dividerColor = isDark ? const Color(0xFF2D3555) : const Color(0xFFEAEBFA);
    final shadowColor = isDark ? Colors.transparent : const Color(0xFF6153FF).withOpacity(0.05);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFB82315),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            profileAsync.when(
              loading: () => Container(
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(color: Color(0xFFB82315)),
              ),
              error: (err, _) => Container(
                height: 92,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Error fetching profile data: $err',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (profile) {
                final name = profile?.fullName ?? 'User';
                final email = profile?.email ?? '';
                return Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getAvatarBg(avatarState.activeAvatarId, isDark),
                              border: Border.all(color: const Color(0xFF6153FF).withOpacity(0.2), width: 2),
                            ),
                            child: Icon(
                              _getAvatarIcon(avatarState.activeAvatarId),
                              size: 36,
                              color: avatarState.activeAvatarId == 1
                                  ? const Color(0xFF8AA19B)
                                  : (avatarState.activeAvatarId == 3 ? const Color(0xFF6153FF) : (isDark ? const Color(0xFFC1C6D9) : Colors.grey[700])),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor),
                                ),
                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: isDark ? Colors.grey : const Color(0xFF5E4940)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFB82315),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsRow(
                    Icons.notifications_none, 
                    'Notifications', 
                    _notificationsEnabled, 
                    (val) => setState(() => _notificationsEnabled = val),
                    textColor,
                  ),
                  Divider(color: dividerColor, height: 1, thickness: 1),
                  _buildSettingsRow(
                    Icons.nightlight_outlined, 
                    'Dark Mode', 
                    isDarkMode, 
                    (val) => ref.read(darkModeProvider.notifier).state = val,
                    textColor,
                  ),
                  Divider(color: dividerColor, height: 1, thickness: 1),
                  _buildSettingsRow(
                    Icons.volume_up_outlined, 
                    'Sound Effects', 
                    _soundEffectsEnabled, 
                    (val) => setState(() => _soundEffectsEnabled = val),
                    textColor,
                  ),
                  Divider(color: dividerColor, height: 1, thickness: 1),
                  _buildLogoutRow(context),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutRow(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('Are you sure you want to log out from your account?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await ref.read(authProvider.notifier).signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: const [
              Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 24),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F)),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFFD32F2F), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, bool value, ValueChanged<bool> onChanged, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6153FF), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF6153FF),
            inactiveThumbColor: const Color(0xFF9096A5),
            inactiveTrackColor: const Color(0xFFEAEBFA).withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
