import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/profile_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(userProfileProvider.notifier).changePassword(
            currentPassword: _currentPassController.text.trim(),
            newPassword: _newPassController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password successfully updated!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14142B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ensure your account stays secure.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5E4940),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Main Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6153FF).withOpacity(0.03),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPasswordField(
                                  label: 'Current Password',
                                  controller: _currentPassController,
                                  hint: 'Enter current password',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _hideCurrent,
                                  onToggleObscure: () => setState(() => _hideCurrent = !_hideCurrent),
                                  validator: (val) =>
                                      (val != null && val.isNotEmpty) ? null : 'Please enter your current password',
                                ),
                                const SizedBox(height: 20),
                                _buildPasswordField(
                                  label: 'New Password',
                                  controller: _newPassController,
                                  hint: 'Enter new password',
                                  icon: Icons.vpn_key_outlined,
                                  obscure: _hideNew,
                                  onToggleObscure: () => setState(() => _hideNew = !_hideNew),
                                  validator: (val) =>
                                      (val != null && val.length >= 6) ? null : 'Password must be at least 6 characters',
                                ),
                                const SizedBox(height: 20),
                                _buildPasswordField(
                                  label: 'Confirm New Password',
                                  controller: _confirmPassController,
                                  hint: 'Confirm new password',
                                  icon: Icons.vpn_key_outlined,
                                  obscure: _hideConfirm,
                                  onToggleObscure: () => setState(() => _hideConfirm = !_hideConfirm),
                                  validator: (val) => val == _newPassController.text ? null : 'Passwords do not match',
                                ),
                                const SizedBox(height: 36),
                                // Buttons
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB82315),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: _isLoading ? null : _handleUpdatePassword,
                                    child: const Text(
                                      'Update Password',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFF9F9),
                                      foregroundColor: const Color(0xFF14142B),
                                      side: BorderSide(color: const Color(0xFFB82315).withOpacity(0.2), width: 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB82315)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF14142B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF14142B),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF5E4940), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF5E4940),
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: const Color(0xFFEFF0FA),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF6153FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
