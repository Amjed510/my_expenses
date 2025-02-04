class User {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String joinDate;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.joinDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'joinDate': joinDate,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      joinDate: map['joinDate'] ?? '',
    );
  }
}
