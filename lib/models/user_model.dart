class UserModel {
  final String email;
  final String password;

  UserModel({
    required this.email,
    required this.password,
  });

  // 🔁 Object → Map (SharedPreferences साठी)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }

  // 🔁 Map → Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'],
      password: map['password'],
    );
  }
}