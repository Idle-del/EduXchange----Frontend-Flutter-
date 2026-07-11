// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:edu_xchange/login/register/register_screen.dart';
import 'package:edu_xchange/services/auth_service.dart';
import 'package:edu_xchange/screens/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool _isVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isPassword,
    Icon icon,
    bool isDarkMode,
    Widget? suffixIcon,
    String? Function(String?) validator,

  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? !_isVisible : false,
            decoration: InputDecoration(
              prefixIcon: icon,
              labelText: label,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    bool success = await _authService.login(email, password);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid email or password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Email field
                _buildTextField(
                  'Email',
                  _emailController,
                  false,
                  const Icon(Icons.email_outlined),
                  isDarkMode,
                  null,
                  (val) {
                    if (val == null || val.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                    ).hasMatch(val.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  } // No suffix icon for email field
                ),
                
                const SizedBox(height: 16),

                // Password field
                _buildTextField(
                  'Password',
                  _passwordController,
                  true,
                  const Icon(Icons.lock_outline),
                  isDarkMode,
                  IconButton(
                    icon: Icon(
                      _isVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                  ),
                  (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password is required';
                    }
                    if (val.trim().length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 16),

                // Login button
                ElevatedButton(
                  // onPressed: _isLoading ? null : _login,
                  onPressed: () {
                    if (!_isLoading) {
                      login();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Log In', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Don\'t have an account? Sign Up'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
