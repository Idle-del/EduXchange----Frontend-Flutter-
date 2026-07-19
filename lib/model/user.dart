class User{
  final int id;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';
}