// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:edu_xchange/controller/navigation_controller.dart';
import 'package:edu_xchange/controller/theme_controller.dart';
import 'package:edu_xchange/model/user_model.dart';
import 'package:edu_xchange/services/profile_service.dart';
import 'package:edu_xchange/services/token_servce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  bool isLoading = true;

  UserProfile? userProfile;

  // Formal, academic-leaning palette, matching the rest of the app.
  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await _profileService.fetchUserProfile();

      setState(() {
        userProfile = userData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() => isLoading = false);
    }
  }

  void _logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await TokenService().logout();

        if (Get.isRegistered<NavigationController>()) {
          Get.delete<NavigationController>();
        }
        Get.offAllNamed('/login');
      },
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161D2B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(isDark ? 0.18 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: _primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E1420) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E1420) : Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: isDark ? Colors.white : _primaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          GetBuilder<ThemeController>(
            builder: (controller) {
              return IconButton(
                onPressed: () {
                  controller.toggleTheme();
                },
                icon: Icon(
                  isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                  color: isDark ? Colors.white : _primaryColor,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : userProfile == null
          ? Center(
              child: Text(
                "Failed to load profile",
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: _primaryColor.withOpacity(isDark ? 0.18 : 0.08),
                          backgroundImage:
                              userProfile?.profilePicture?.isNotEmpty == true
                              ? NetworkImage(userProfile!.profilePicture!)
                              : null,
                          child: userProfile?.profilePicture == null
                              ? const Icon(Icons.person, size: 50, color: _primaryColor)
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "${userProfile?.firstName ?? 'N/A'} ${userProfile?.lastName ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userProfile?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userProfile?.bio ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to the edit profile page
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildDetailTile(
                    Icons.work_outline,
                    'Department',
                    userProfile?.department ?? 'N/A',
                    isDark,
                  ),
                  _buildDetailTile(
                    Icons.school_outlined,
                    'Semester',
                    '${userProfile?.semesterName ?? 'N/A'}',
                    isDark,
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Logout',
        onPressed: _logout,
        backgroundColor: Colors.red[700],
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}