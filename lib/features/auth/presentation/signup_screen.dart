import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../timer/presentation/home_screen.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  bool _obscurePassword = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final requiresVerification = await ref
          .read(authProvider.notifier)
          .signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
      if (mounted) {
        if (requiresVerification) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Check Your Email'),
              content: const Text(
                'We have sent a confirmation link to your email. Please verify your account before logging in.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to Login Screen
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC), // Background matching mockup
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB82315)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Podoro',
          style: TextStyle(
            color: Color(0xFFB82315),
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFEAEBFA), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 64),
                        // Create Account
                        const Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: Color(0xFF14142B),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Start your journey to better focus today.',
                            style: TextStyle(
                              color: Color(0xFF5E4940),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Full Name Field
                        Container(
                          color: const Color(
                            0xFFF4F5FB,
                          ), // slightly lighter than EAEBFA, matching mockup
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Color(0xFF14142B)),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Color(0xFF5E4940),
                              ),
                              hintText: 'Full Name',
                              hintStyle: TextStyle(
                                color: Color(0xFF8A8A9E),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            keyboardType: TextInputType.name,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        Container(
                          color: const Color(0xFFF4F5FB),
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Color(0xFF14142B)),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                color: Color(0xFF5E4940),
                              ),
                              hintText: 'Email Address',
                              hintStyle: TextStyle(
                                color: Color(0xFF8A8A9E),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Container(
                          color: const Color(0xFFF4F5FB),
                          child: TextField(
                            controller: _passwordController,
                            style: const TextStyle(color: Color(0xFF14142B)),
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF5E4940),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF5E4940),
                                ),
                              ),
                              hintText: 'Password',
                              hintStyle: const TextStyle(
                                color: Color(0xFF8A8A9E),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Sign Up Button
                        SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB82315),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                              shadowColor: const Color(
                                0xFFB82315,
                              ).withValues(alpha: 0.3),
                            ),
                            onPressed: _isLoading ? null : _handleSignup,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),

                        const Spacer(),

                        // Footer
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 24.0,
                            top: 48.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Color(0xFF5E4940),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFFB82315),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
