class User {
  final String id;
  final String name;
  final String lastName;
  final DateTime dateOfBirth;
  final String email;
  final String password; // In production, this should be hashed
  final double height; // in cm
  final double weight; // in kg
  final double fatPercentage; // %
  final double musclePercentage; // %
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    required this.password,
    required this.height,
    required this.weight,
    required this.fatPercentage,
    required this.musclePercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? lastName,
    DateTime? dateOfBirth,
    String? email,
    String? password,
    double? height,
    double? weight,
    double? fatPercentage,
    double? musclePercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      password: password ?? this.password,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      musclePercentage: musclePercentage ?? this.musclePercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'email': email,
      'password': password,
      'height': height,
      'weight': weight,
      'fatPercentage': fatPercentage,
      'musclePercentage': musclePercentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      email: json['email'],
      password: json['password'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      fatPercentage: json['fatPercentage'].toDouble(),
      musclePercentage: json['musclePercentage'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get fullName => '$name $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, lastName: $lastName, email: $email)';
  }
}
