class User {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? bio;
  final String? department;
  final int? semester;
  final String? profilePicture;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.bio,
    this.department,
    this.semester,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      department: json['department'] as String?,
      semester: json['semester'] as int?,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';
}