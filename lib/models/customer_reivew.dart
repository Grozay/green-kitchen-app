class Customer {
  final int id;
  final String? avatar;
  final String firstName;
  final String lastName;
  final String fullName;
  final String gender;
  final String email;
  final String? phone;

  Customer({
    required this.id,
    this.avatar,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.email,
    this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      avatar: json['avatar'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      gender: json['gender'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'avatar': avatar,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
    'gender': gender,
    'email': email,
    'phone': phone,
  };
}
}