// ignore_for_file: use_build_context_synchronously, deprecated_member_use, prefer_final_fields

import 'dart:io';

import 'package:edu_xchange/login/register/login_screen.dart';
import 'package:edu_xchange/services/auth_service.dart';
import 'package:edu_xchange/services/semester_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  File? _selectedImage;
  final AuthService _authService = AuthService();
  final SemesterService _semesterService = SemesterService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _departmentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool isSemestersLoading = true;
  List<Map<String, dynamic>> _semesters = [];
  int? _selectedSemester;

  // Formal, academic-leaning palette, matching the login screen.
  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue
  static const Color _accentColor = Color(0xFF2C5A8C);

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    try {
      final semesters = await _semesterService.fetchSemesters();

      setState(() {
        _semesters = List<Map<String, dynamic>>.from(semesters);
        isSemestersLoading = false;
      });
    } catch (e) {
      setState(() {
        isSemestersLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void register() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }
  setState(() => _isLoading = true);
  final result = await _authService.register(
    _emailController.text.trim(),
    _passwordController.text.trim(),
    _firstNameController.text.trim(),
    _lastNameController.text.trim(),
    bio: _bioController.text.trim().isNotEmpty
        ? _bioController.text.trim()
        : null,
    department: _departmentController.text.trim().isNotEmpty
        ? _departmentController.text.trim()
        : null,
    semester: _selectedSemester,
    imageFile: _selectedImage,
  );
  setState(() => _isLoading = false);

  if (!mounted) return;

  if (result.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registration successful! Please verify your email before logging in."),
      ),
    );
    Get.offNamed('/login');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }
}

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool obscureText,
    Icon icon,
    bool isDarkMode,
    Widget? suffixIcon,
    String? Function(String?) validator, {
    int maxLines = 1,
  }) {
    final bool isMultiline = maxLines > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            minLines: isMultiline ? maxLines : 1,
            maxLines: maxLines,
            textAlignVertical: isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
            style: const TextStyle(fontSize: 15, height: 1.4),
            decoration: InputDecoration(
              prefixIcon: isMultiline
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: icon,
                    )
                  : icon,
              alignLabelWithHint: isMultiline,
              labelText: label,
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 4,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0E1420) : const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF161D2B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: _primaryColor.withOpacity(
                                isDarkMode ? 0.18 : 0.08,
                              ),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : null,
                              child: _selectedImage == null
                                  ? const Icon(
                                      Icons.person_outline,
                                      size: 52,
                                      color: _primaryColor,
                                    )
                                  : null,
                            ),

                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDarkMode
                                      ? const Color(0xFF161D2B)
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Tap to choose profile picture",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: isDarkMode ? Colors.white : _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Join EduXchange to share and access resources',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Profile Image field

                    // First Name field
                    _buildTextField(
                      'First Name',
                      _firstNameController,
                      false,
                      Icon(Icons.person_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      isDarkMode,
                      null,
                      (val) {
                        if (val == null || val.isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),

                    //Last Name field
                    _buildTextField(
                      'Last Name',
                      _lastNameController,
                      false,
                      Icon(Icons.person_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),

                      isDarkMode,
                      null,
                      (val) {
                        if (val == null || val.isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),

                    // Email field
                    _buildTextField(
                      'Email',
                      _emailController,
                      false,
                      Icon(Icons.email_outlined, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
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
                      },
                    ),
                    const SizedBox(height: 4),

                    // Password field
                    _buildTextField(
                      'Password',
                      _passwordController,
                      !_isPasswordVisible,
                      Icon(Icons.lock_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      isDarkMode,
                      IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
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
                      },
                    ),
                    const SizedBox(height: 4),

                    // Confirm Password field
                    _buildTextField(
                      'Confirm Password',
                      _confirmPasswordController,
                      !_isConfirmPasswordVisible,
                      Icon(Icons.lock_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      isDarkMode,
                      IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      (val) {
                        if (val == null || val.isEmpty) {
                          return 'Confirm password is required';
                        }
                        if (val.trim() != _passwordController.text.trim()) {
                          return 'Passwords do not match';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 4),

                    // Bio field
                    _buildTextField(
                      'Bio',
                      _bioController,
                      false,
                      Icon(Icons.info_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      isDarkMode,
                      null,
                      (val) {
                        return null;
                      },
                      maxLines: 4,
                    ),
                    const SizedBox(height: 4),

                    // Department field
                    _buildTextField(
                      'Department',
                      _departmentController,
                      false,
                      Icon(Icons.work_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      isDarkMode,
                      null,
                      (val) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Semester choice field
                    if (isSemestersLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<int>(
                          value: _selectedSemester,
                          items: _semesters.map((s) {
                            return DropdownMenuItem<int>(
                              value: s['id'],
                              child: Text(s['name']),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSemester = val),
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.school_outlined,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            labelText: 'Semester',
                            labelStyle: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 4,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    // Create Account button
                    ElevatedButton(
                      // onPressed: _isLoading ? null : _login,
                      onPressed: () {
                        _isLoading ? null : register();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}