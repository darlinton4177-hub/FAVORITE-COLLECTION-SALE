class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final String country;

  const UserProfile({
    this.name = 'Alex Morgan',
    this.email = 'alex.morgan@example.com',
    this.phone = '+1 (555) 234-5678',
    this.address = '742 Evergreen Terrace',
    this.city = 'Springfield',
    this.postalCode = '97477',
    this.country = 'United States',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'postalCode': postalCode,
    'country': country,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Alex Morgan',
      email: json['email'] as String? ?? 'alex.morgan@example.com',
      phone: json['phone'] as String? ?? '+1 (555) 234-5678',
      address: json['address'] as String? ?? '742 Evergreen Terrace',
      city: json['city'] as String? ?? 'Springfield',
      postalCode: json['postalCode'] as String? ?? '97477',
      country: json['country'] as String? ?? 'United States',
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? country,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }
}
