class User {
  final String email;
  final String name;

  User({
    required this.email,
    required this.name,
  });

  String get displayName => name;

  User copyWith({
    String? email,
    String? name,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] as String,
      name: map['name'] as String,
    );
  }
}
