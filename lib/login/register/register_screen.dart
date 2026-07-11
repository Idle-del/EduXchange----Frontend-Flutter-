// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:edu_xchange/login/register/login_screen.dart';
import 'package:edu_xchange/services/auth_service.dart';
import 'package:edu_xchange/services/semester_service.dart';
import 'package:flutter/material.dart';
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
  final _isLoading = false;
  bool isSemestersLoading = true;
  List<Map<String, dynamic>> _semesters = [];
  int? _selectedSemester;

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
      print('Error loading semesters: $e');

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
    final success = await _authService.register(
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
      // Assuming image is optional
    );
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registration successful")));
      Navigator.pop(context);
    } else {
      print('Registration failed');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registration failed")));
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool obscureText,
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
            obscureText: obscureText,
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
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: _selectedImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                  
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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

                const SizedBox(height: 8),

                const Text(
                  "Tap to choose profile picture",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Profile Image field

                // First Name field
                _buildTextField(
                  'First Name',
                  _firstNameController,
                  false,
                  const Icon(Icons.person),
                  isDarkMode,
                  null,
                  (val) {
                    if (val == null || val.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                //Last Name field
                _buildTextField(
                  'Last Name',
                  _lastNameController,
                  false,
                  const Icon(Icons.person),

                  isDarkMode,
                  null,
                  (val) {
                    if (val == null || val.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                _buildTextField(
                  'Password',
                  _passwordController,
                  !_isPasswordVisible,
                  const Icon(Icons.lock_outline),
                  isDarkMode,
                  IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                const SizedBox(height: 16),

                // Confirm Password field
                _buildTextField(
                  'Confirm Password',
                  _confirmPasswordController,
                  !_isConfirmPasswordVisible,
                  const Icon(Icons.lock_outline),
                  isDarkMode,
                  IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                const SizedBox(height: 16),

                // Bio field
                _buildTextField(
                  'Bio',
                  _bioController,
                  false,
                  const Icon(Icons.info_outline),
                  isDarkMode,
                  null,
                  (val) {
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Department field
                _buildTextField(
                  'Department',
                  _departmentController,
                  false,
                  const Icon(Icons.work_outline),
                  isDarkMode,
                  null,
                  (val) {
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Semester choice field
                if (isSemestersLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<int>(
                    value: _selectedSemester,
                    items: _semesters.map((s) {
                      return DropdownMenuItem<int>(
                        value: s['value'],
                        child: Text(s['label']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSemester = val),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.school_outlined),
                      labelText: 'Semester',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 16),
                // Create Account button
                ElevatedButton(
                  // onPressed: _isLoading ? null : _login,
                  onPressed: () {
                    if (!_isLoading) {
                      register();
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
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Already have an account? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
