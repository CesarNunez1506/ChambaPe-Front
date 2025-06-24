// ignore_for_file: non_constant_identifier_names

enum UserType { client, worker, unknown }

class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final UserType userType;
  final String? profilePictureUrl;
  final bool isVerified; // For Certijoven, Certiadulto
  final double averageRating;
  final int totalRatings;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.userType,
    this.profilePictureUrl,
    this.isVerified = false,
    this.averageRating = 0.0,
    this.totalRatings = 0,
  });

  // Factory constructor for creating a new User instance from a map (e.g., JSON from API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      userType: _userTypeFromString(json['user_type'] as String?),
      profilePictureUrl: json['profile_picture_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
    );
  }

  // Method to convert a User instance to a map (e.g., for sending to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'user_type': userType.name,
      'profile_picture_url': profilePictureUrl,
      'is_verified': isVerified,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
    };
  }

  // Helper to convert string to UserType enum
  static UserType _userTypeFromString(String? typeStr) {
    if (typeStr == 'client') return UserType.client;
    if (typeStr == 'worker') return UserType.worker;
    return UserType.unknown;
  }

  // Example of a placeholder user for UI development
  static User get placeholderClient => User(
        id: 'client_placeholder_id',
        name: 'Cliente Ejemplo',
        email: 'cliente@example.com',
        userType: UserType.client,
        address: 'Av. Lima 123, Miraflores',
        phoneNumber: '987654321',
        profilePictureUrl: 'https://via.placeholder.com/150/0D47A1/FFFFFF?Text=C', // Blue background, white text
      );

  static User get placeholderWorker => User(
        id: 'worker_placeholder_id',
        name: 'Trabajador Ejemplo',
        email: 'trabajador@example.com',
        userType: UserType.worker,
        address: 'Jr. Puno 456, Surco',
        phoneNumber: '912345678',
        profilePictureUrl: 'https://via.placeholder.com/150/2E7D32/FFFFFF?Text=T', // Green background, white text
        isVerified: true,
        averageRating: 4.8,
        totalRatings: 75,
      );
}
