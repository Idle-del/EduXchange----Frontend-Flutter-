class UserProfile {
    final String email;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? department;
  final int? semester;
  final String? semesterName;
  final String? profilePicture;

  UserProfile({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.department,
    required this.semester,
    required this.semesterName,
    required this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      bio: json['bio'],
      department: json['department'],
      semester: json['semester'],
      semesterName: json['semester_name'],
      profilePicture: json['profile_picture'],
    );
  }
}