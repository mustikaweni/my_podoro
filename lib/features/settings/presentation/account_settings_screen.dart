import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/profile_provider.dart';
import '../../avatar/providers/avatar_provider.dart';
import '../../auth/presentation/login_screen.dart';
import 'change_password_screen.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    // Initialize data if already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        _nameController.text = profile.fullName;
        _emailController.text = profile.email;
        _phoneController.text = profile.phoneNumber;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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

  Color _getAvatarBg(int id) {
    switch (id) {
      case 1:
        return const Color(0xFFF3F4F8);
      case 2:
        return const Color(0xFFE5E0DA);
      case 3:
        return const Color(0xFFEAEBFA);
      default:
        return Colors.white;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(userProfileProvider.notifier).updateProfile(
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving changes: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Account?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red)),
        content: const Text(
          'Are you absolutely sure? This will permanently delete your focus progress, statistics, streaks, and shop items. This cannot be undone!',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB82315),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Delete', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(userProfileProvider.notifier).deleteAccount();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final avatarState = ref.watch(avatarNotifierProvider);

    // Listen to state to update text controllers automatically when fetched
    ref.listen<AsyncValue<UserProfileData?>>(userProfileProvider, (prev, next) {
      if (next.value != null) {
        if (_nameController.text.isEmpty) _nameController.text = next.value!.fullName;
        if (_emailController.text.isEmpty) _emailController.text = next.value!.email;
        if (_phoneController.text.isEmpty) _phoneController.text = next.value!.phoneNumber;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFB82315), size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Podoro',
                        style: TextStyle(
                          color: Color(0xFFB82315),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Top Profile Section
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFF6153FF), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6153FF).withOpacity(0.15),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color: _getAvatarBg(avatarState.activeAvatarId),
                                    child: Icon(
                                      _getAvatarIcon(avatarState.activeAvatarId),
                                      size: 64,
                                      color: avatarState.activeAvatarId == 1
                                          ? const Color(0xFF8AA19B)
                                          : (avatarState.activeAvatarId == 3 ? const Color(0xFF6153FF) : Colors.grey[700]),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                profileAsync.value?.fullName ?? 'Loading...',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF14142B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profileAsync.value?.email ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF5E4940),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Personal Info Card
                        _buildSectionCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF14142B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildInputField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline_rounded,
                                  validator: (val) => (val != null && val.trim().isNotEmpty) ? null : 'Please enter your name',
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.mail_outline_rounded,
                                  readOnly: true, // Email is generally permanent/from provider
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  hint: '+1 (555) 000-0000',
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB82315),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(27),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: _isLoading ? null : _saveChanges,
                                    child: const Text(
                                      'Save Changes',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Security Card
                        _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Security',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF14142B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSecurityTile(
                                icon: Icons.lock_outline_rounded,
                                title: 'Change Password',
                                subtitle: 'Update your login credentials',
                                onTap: _navigateToChangePassword,
                              ),
                              const SizedBox(height: 16),
                              _buildTwoFactorTile(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Danger Zone Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFFFE3E3), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.warning_amber_rounded, color: Color(0xFFB82315), size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Danger Zone',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFB82315),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Once you delete your account, there is no going back. Please be certain. All your streaks, diamonds, and history will be permanently lost.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF5E4940),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB82315),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(27),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLoading ? null : _handleDeleteAccount,
                                  child: const Text(
                                    'Delete Account',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB82315)),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6153FF).withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5E4940),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF14142B),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF5E4940), size: 20),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF5F5FA) : const Color(0xFFEFF0FA),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: readOnly ? Colors.transparent : const Color(0xFF6153FF).withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6153FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14142B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5E4940),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF5E4940)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoFactorTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF6153FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Two-Factor Auth',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14142B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Add an extra layer of security',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5E4940),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _twoFactorEnabled,
            onChanged: (val) => setState(() => _twoFactorEnabled = val),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF6153FF),
          ),
        ],
      ),
    );
  }
}
