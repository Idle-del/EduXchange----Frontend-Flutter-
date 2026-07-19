// // ignore_for_file: use_build_context_synchronously, deprecated_member_use

// import 'package:edu_xchange/controller/navigation_controller.dart';
// import 'package:edu_xchange/controller/theme_controller.dart';
// import 'package:edu_xchange/model/user_model.dart';
// import 'package:edu_xchange/profile/profile_edit.dart';
// import 'package:edu_xchange/profile/view_profile.dart';
// import 'package:edu_xchange/services/profile_service.dart';
// import 'package:edu_xchange/services/token_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final _profileService = ProfileService();
//   final TokenService _tokenService = TokenService();
//   bool isLoading = true;
//   int? _currentUserId;

//   UserProfile? userProfile;

//   // Formal, academic-leaning palette, matching the rest of the app.
//   static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//     _loadCurrentUserId();
//   }

//   Future<void> _loadCurrentUserId() async {
//     final userId = await _tokenService.getUserId();
//     if (mounted) {
//       setState(() => _currentUserId = userId);
//     }
//   }

//   Future<void> _loadUserProfile() async {
//     try {
//       final userData = await _profileService.fetchUserProfile();

//       setState(() {
//         userProfile = userData;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   void _logout() {
//     // Get.defaultDialog(
//     //   title: 'Logout',
//     //   middleText: 'Are you sure you want to logout?',
//     //   textCancel: 'Cancel',
//     //   textConfirm: 'Logout',
//     //   confirmTextColor: Colors.white,
//     //   onConfirm: () async {
//     //     await _tokenService.logout();

//     //     if (Get.isRegistered<NavigationController>()) {
//     //       Get.delete<NavigationController>();
//     //     }
//     //     Get.offAllNamed('/login');
//     //   },
//     // );
//     showDialog(context: context, builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await _tokenService.logout();

//               if (Get.isRegistered<NavigationController>()) {
//                 Get.delete<NavigationController>();
//               }
//               Get.offAllNamed('/login');
//             },
//             child: const Text('Logout', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       );
//     });
//   }

//   Widget _buildDetailTile(
//     IconData icon,
//     String label,
//     String value,
//     bool isDark,
//   ) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF161D2B) : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: _primaryColor.withOpacity(isDark ? 0.18 : 0.08),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 18, color: _primaryColor),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isDark ? Colors.grey[500] : Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 14.5,
//                     fontWeight: FontWeight.w600,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor: isDark
//           ? const Color(0xFF0E1420)
//           : const Color(0xFFF4F6F9),
//       appBar: AppBar(
//         backgroundColor: isDark ? const Color(0xFF0E1420) : Colors.white,
//         elevation: 0,
//         title: Text(
//           'Profile',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.3,
//             color: isDark ? Colors.white : _primaryColor,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           GetBuilder<ThemeController>(
//             builder: (controller) {
//               return IconButton(
//                 onPressed: () {
//                   controller.toggleTheme();
//                 },
//                 icon: Icon(
//                   isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
//                   color: isDark ? Colors.white : _primaryColor,
//                 ),
//               );
//             },
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: _primaryColor))
//           : userProfile == null
//           ? Center(
//               child: Text(
//                 "Failed to load profile",
//                 style: TextStyle(
//                   color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   fontSize: 15,
//                 ),
//               ),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 28,
//                       horizontal: 20,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isDark ? const Color(0xFF161D2B) : Colors.white,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                           blurRadius: 16,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             if (userProfile?.profilePicture != null && userProfile!.profilePicture!.isNotEmpty) {
//                               Get.to(
//                                 () => ViewProfileImage(
//                                   imageUrl: userProfile!.profilePicture!,
//                                   isDark: isDark,
//                                 ),
//                               );
//                             }
//                           },
//                           child: CircleAvatar(
//                             radius: 50,
//                             backgroundColor: _primaryColor.withOpacity(
//                               isDark ? 0.18 : 0.08,
//                             ),
//                             backgroundImage:
//                                 userProfile?.profilePicture?.isNotEmpty == true
//                                 ? NetworkImage(userProfile!.profilePicture!)
//                                 : null,
//                             child: userProfile?.profilePicture == null
//                                 ? const Icon(
//                                     Icons.person,
//                                     size: 50,
//                                     color: _primaryColor,
//                                   )
//                                 : null,
//                           ),
//                         ),
//                         const SizedBox(height: 14),
//                         Text(
//                           "${userProfile?.firstName ?? 'N/A'} ${userProfile?.lastName ?? 'N/A'}",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: isDark ? Colors.white : Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           userProfile?.email ?? '',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           userProfile?.bio ?? '',
//                           style: TextStyle(
//                             fontSize: 14,
//                             height: 1.4,
//                             color: isDark ? Colors.grey[300] : Colors.grey[700],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: () async {
//                               final updated = await Get.to(
//                                 () => const ProfileEdit(),
//                                 arguments: userProfile,
//                               );

//                               if (updated == true) {
//                                 _loadUserProfile();
//                               }
//                             },
//                             icon: const Icon(Icons.edit_outlined, size: 18),
//                             label: const Text(
//                               'Edit Profile',
//                               style: TextStyle(
//                                 fontSize: 14.5,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _primaryColor,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   _buildDetailTile(
//                     Icons.work_outline,
//                     'Department',
//                     userProfile?.department ?? 'N/A',
//                     isDark,
//                   ),
//                   _buildDetailTile(
//                     Icons.school_outlined,
//                     'Semester',
//                     userProfile?.semesterName ?? 'N/A',
//                     isDark,
//                   ),

//                   const SizedBox(height: 20),

//                   GestureDetector(
//                     onTap: () {
//                       Get.toNamed('/manage_resources');
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                       margin: const EdgeInsets.only(bottom: 10),
//                       decoration: BoxDecoration(
//                         color: isDark ? const Color(0xFF161D2B) : Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('My Resources',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: isDark ? Colors.white : Colors.black87,
//                               )),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 16,
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
                  

//                   const SizedBox(height: 80),
//                 ],
//               ),
//             ),
//       floatingActionButton: FloatingActionButton.extended(
//         tooltip: 'Logout',
//         onPressed: _logout,
//         backgroundColor: Colors.red[700],
//         icon: const Icon(Icons.logout, size: 18),
//         label: const Text(
//           'Logout',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }


// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/controller/navigation_controller.dart';
import 'package:edu_xchange/controller/theme_controller.dart';
import 'package:edu_xchange/model/user_model.dart';
import 'package:edu_xchange/profile/profile_edit.dart';
import 'package:edu_xchange/profile/view_profile.dart';
import 'package:edu_xchange/services/profile_service.dart';
import 'package:edu_xchange/services/token_service.dart';
import 'package:edu_xchange/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  /// Pass a userId to view someone ELSE's profile (e.g. a resource's
  /// uploader) — read only, no edit, no logout.
  /// Leave null (default) to show the logged-in user's OWN profile.
  final int? userId;
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  final _userService = UserService();
  final TokenService _tokenService = TokenService();
  bool isLoading = true;
  bool hasError = false;

  bool get _isOwnProfile => widget.userId == null;

  // Unified local display fields, populated from whichever source applies.
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _bio = '';
  String _department = 'N/A';
  String _semesterLabel = 'N/A';
  String? _profileImageUrl;

  UserProfile? _ownProfile; // kept so "Edit Profile" can pass it along

  // Formal, academic-leaning palette, matching the rest of the app.
  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      if (_isOwnProfile) {
        final userData = await _profileService.fetchUserProfile();
        setState(() {
          _ownProfile = userData;
          _firstName = userData.firstName;
          _lastName = userData.lastName;
          _email = userData.email;
          _bio = userData.bio ?? '';
          _department = userData.department ?? 'N/A';
          _semesterLabel = userData.semesterName ?? 'N/A';
          // Own-profile endpoint already returns a fully-qualified URL.
          _profileImageUrl =
              (userData.profilePicture != null &&
                      userData.profilePicture!.isNotEmpty)
                  ? userData.profilePicture
                  : null;
          isLoading = false;
        });
      } else {
        final user = await _userService.getUserDetails(widget.userId!);
        setState(() {
          _firstName = user.firstName;
          _lastName = user.lastName;
          _email = user.email ?? '';
          _bio = user.bio ?? '';
          _department = user.department ?? 'N/A';
          _semesterLabel = user.semester != null
              ? 'Semester ${user.semester}'
              : 'N/A';
          // This endpoint returns a relative path, so it needs the prefix.
          _profileImageUrl =
              (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                  ? '${ApiConstants.serverUrl}${user.profilePicture}'
                  : null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _tokenService.logout();

                if (Get.isRegistered<NavigationController>()) {
                  Get.delete<NavigationController>();
                }
                Get.offAllNamed('/login');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailTile(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
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
      backgroundColor: isDark
          ? const Color(0xFF0E1420)
          : const Color(0xFFF4F6F9),
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
        actions: _isOwnProfile
            ? [
                GetBuilder<ThemeController>(
                  builder: (controller) {
                    return IconButton(
                      onPressed: () => controller.toggleTheme(),
                      icon: Icon(
                        isDark
                            ? Icons.wb_sunny_outlined
                            : Icons.nightlight_round,
                        color: isDark ? Colors.white : _primaryColor,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : hasError
          ? Center(
              child: Text(
                'Failed to load profile',
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 20,
                    ),
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
                          onTap: _profileImageUrl != null
                              ? () {
                                  Get.to(
                                    () => ViewProfileImage(
                                      imageUrl: _profileImageUrl!,
                                      isDark: isDark,
                                    ),
                                  );
                                }
                              : null,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: _primaryColor.withOpacity(
                              isDark ? 0.18 : 0.08,
                            ),
                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : null,
                            child: _profileImageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: _primaryColor,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '$_firstName $_lastName',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        if (_bio.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _bio,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        if (_isOwnProfile) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final updated = await Get.to(
                                  () => const ProfileEdit(),
                                  arguments: _ownProfile,
                                );

                                if (updated == true) {
                                  _loadProfile();
                                }
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildDetailTile(
                    Icons.work_outline,
                    'Department',
                    _department,
                    isDark,
                  ),
                  _buildDetailTile(
                    Icons.school_outlined,
                    'Semester',
                    _semesterLabel,
                    isDark,
                  ),

                  const SizedBox(height: 20),

                  if (_isOwnProfile)
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/manage_resources');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF161D2B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[850]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Resources',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: _isOwnProfile
          ? FloatingActionButton.extended(
              tooltip: 'Logout',
              onPressed: _logout,
              backgroundColor: Colors.red[700],
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }
}