// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:edu_xchange/profile/view_profile.dart';
import 'package:edu_xchange/services/auth_service.dart';
import 'package:edu_xchange/services/semester_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  File? _selectedImage;
  final SemesterService _semesterService = SemesterService();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController departmentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  bool _isEditingFirstName = false;
  bool _isEditingLastName = false;
  bool _isEditingBio = false;
  bool _isEditingDepartment = false;

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();
  final FocusNode _departmentFocus = FocusNode();

  bool isSemestersLoading = true;
  List<Map<String, dynamic>> _semesters = [];
  int? _selectedSemester;

  bool isLoading = true;
  bool _isSaving = false;

  final userProfile = Get.arguments;

  // Formal, academic-leaning palette, matching the rest of the app.
  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    bioController.dispose();
    departmentController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _bioFocus.dispose();
    _departmentFocus.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await Future.wait([_loadProfileData(), _loadSemesters()]);

    // Make sure the pre-selected semester actually exists in the fetched
    // list before it's ever handed to the DropdownButtonFormField —
    // otherwise Flutter throws an assertion error at build time.
    final validIds = _semesters.map((s) => s['id']).toSet();
    if (_selectedSemester != null && !validIds.contains(_selectedSemester)) {
      setState(() => _selectedSemester = null);
    }
  }

  Future<void> _loadProfileData() async {
    firstNameController.text = userProfile.firstName;
    lastNameController.text = userProfile.lastName;
    emailController.text = userProfile.email;
    bioController.text = userProfile.bio ?? '';
    departmentController.text = userProfile.department ?? '';

    final rawSemester = userProfile.semester;
    _selectedSemester = rawSemester == null
        ? null
        : (rawSemester is int
              ? rawSemester
              : int.tryParse(rawSemester.toString()));

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadSemesters() async {
    try {
      final semesters = await _semesterService.fetchSemesters();

      setState(() {
        _semesters = List<Map<String, dynamic>>.from(semesters).map((s) {
          return {
            'id': s['id'] is int ? s['id'] : int.tryParse(s['id'].toString()),
            'name': s['name'],
          };
        }).toList();
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

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final success = await AuthService().updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        bio: bioController.text.trim(),
        department: departmentController.text.trim(),
        semester: _selectedSemester,
        imageFile: _selectedImage,
      );

      if (success) {
        Get.snackbar(
          "Profile Updated",
          "Your changes have been saved successfully.",
          backgroundColor: _primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Navigator.of(context).pop(true);
      } else {
        Get.snackbar(
          "Update Failed",
          "We couldn't save your changes. Please try again.",
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stack) {
      debugPrint('$e\n$stack');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Toggles the edit state for a field. When entering edit mode, focus
  /// moves to the field's TextField. When confirming (tapping the check
  /// icon), focus is cleared and the field goes back to read-only.
  void _toggleFieldEditing(
    bool currentlyEditing,
    void Function(bool) setEditing,
    FocusNode focusNode,
  ) {
    final nowEditing = !currentlyEditing;
    setState(() => setEditing(nowEditing));

    if (nowEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
    } else {
      focusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  void showProfileOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      backgroundColor: isDark ? const Color(0xFF161D2B) : Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final hasPicture =
            userProfile.profilePicture != null &&
            userProfile.profilePicture!.isNotEmpty;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              if (hasPicture)
                ListTile(
                  leading: Icon(Icons.visibility_outlined, color: _primaryColor),
                  title: const Text('View profile picture'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewProfileImage(
                          imageUrl: userProfile.profilePicture!,
                          isDark: isDark,
                        ),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: _primaryColor),
                title: Text(
                  hasPicture ? 'Update profile picture' : 'Add profile picture',
                ),
                onTap: () {
                  pickImage();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0E1420)
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E1420) : Colors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: isDark ? Colors.white : _primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar card, styled to match ProfilePage's header card.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161D2B) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => showProfileOptions(context, isDark),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: _primaryColor.withOpacity(
                                  isDark ? 0.18 : 0.08,
                                ),
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!) as ImageProvider
                                    : (userProfile.profilePicture != null &&
                                              userProfile
                                                  .profilePicture!
                                                  .isNotEmpty
                                          ? CachedNetworkImageProvider(
                                              userProfile.profilePicture!,
                                            )
                                          : null),
                                child:
                                    _selectedImage == null &&
                                        (userProfile.profilePicture == null ||
                                            userProfile.profilePicture!.isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: _primaryColor,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF161D2B)
                                          : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to change photo',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _sectionLabel('Personal Information', isDark),
                  _editField(
                    label: 'First Name',
                    controller: firstNameController,
                    isEditing: _isEditingFirstName,
                    showEditIcon: true,
                    focusNode: _firstNameFocus,
                    onEditChanged: () => _toggleFieldEditing(
                      _isEditingFirstName,
                      (v) => _isEditingFirstName = v,
                      _firstNameFocus,
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _editField(
                    label: 'Last Name',
                    controller: lastNameController,
                    isEditing: _isEditingLastName,
                    showEditIcon: true,
                    focusNode: _lastNameFocus,
                    onEditChanged: () => _toggleFieldEditing(
                      _isEditingLastName,
                      (v) => _isEditingLastName = v,
                      _lastNameFocus,
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _editField(
                    label: 'Email',
                    controller: emailController,
                    isEditing: false,
                    showEditIcon: false,
                    onEditChanged: () => FocusScope.of(context).unfocus(),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _editField(
                    label: 'Bio',
                    controller: bioController,
                    isEditing: _isEditingBio,
                    showEditIcon: true,
                    focusNode: _bioFocus,
                    onEditChanged: () => _toggleFieldEditing(
                      _isEditingBio,
                      (v) => _isEditingBio = v,
                      _bioFocus,
                    ),
                    isDark: isDark,
                    minLines: 3,
                    maxLines: 5,
                  ),

                  const SizedBox(height: 24),

                  _sectionLabel('Academic Information', isDark),
                  _editField(
                    label: 'Department',
                    controller: departmentController,
                    isEditing: _isEditingDepartment,
                    showEditIcon: true,
                    focusNode: _departmentFocus,
                    onEditChanged: () => _toggleFieldEditing(
                      _isEditingDepartment,
                      (v) => _isEditingDepartment = v,
                      _departmentFocus,
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildSemesterField(isDark),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(
                        _isSaving ? 'Saving...' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _primaryColor.withOpacity(0.6),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Semester dropdown styled as its own card so it sits visually in line
  /// with the other formal input fields instead of using the default
  /// Material dropdown box treatment.
  Widget _buildSemesterField(bool isDark) {
    final validIds = _semesters.map((s) => s['id']).toSet();
    final safeValue = validIds.contains(_selectedSemester)
        ? _selectedSemester
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161D2B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: isSemestersLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primaryColor,
                ),
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                value: safeValue,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                dropdownColor: isDark ? const Color(0xFF161D2B) : Colors.white,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  labelText: 'Semester',
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                hint: Text(
                  'Select semester',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                items: _semesters.map((semester) {
                  return DropdownMenuItem<int>(
                    value: semester["id"],
                    child: Text(semester["name"].toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSemester = value);
                },
              ),
            ),
    );
  }
}

Widget _editField({
  required String label,
  required TextEditingController controller,
  required bool isEditing,
  bool showEditIcon = true,
  required VoidCallback onEditChanged,
  required bool isDark,
  int minLines = 1,
  int maxLines = 1,
  FocusNode? focusNode,
}) {
  const Color primaryColor = Color(0xFF1B3A6B);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF161D2B) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isEditing
            ? primaryColor.withOpacity(isDark ? 0.7 : 0.5)
            : (isDark ? Colors.grey[850]! : Colors.grey[200]!),
        width: isEditing ? 1.4 : 1,
      ),
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  minLines: minLines,
                  focusNode: focusNode,
                  readOnly: !isEditing,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (showEditIcon)
            IconButton(
              onPressed: onEditChanged,
              icon: Icon(
                isEditing ? Icons.check_circle : Icons.edit_outlined,
                color: isEditing
                    ? primaryColor
                    : (isDark ? Colors.grey[400] : Colors.grey[500]),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    ),
  );
}