import '../models/user_model.dart';

/// ------------------- LOCAL USERS -------------------
/// Temporary in-memory user list
/// ❗ App restart zalya nantar reset hota
List<UserModel> users = [
  UserModel(email: "user1@gmail.com", password: "1234"),
  UserModel(email: "user2@gmail.com", password: "abcd"),
];

/// ------------------- ADD USER (SIGNUP) -------------------
bool addUser(String email, String password) {
  final e = email.trim().toLowerCase();

  // already exists?
  final exists = users.any((u) => u.email.toLowerCase() == e);
  if (exists) return false;

  users.add(
    UserModel(email: e, password: password),
  );
  return true;
}

/// ------------------- RESET PASSWORD -------------------
String resetPassword(String email, String newPassword) {
  final e = email.trim().toLowerCase();

  for (int i = 0; i < users.length; i++) {
    if (users[i].email.toLowerCase() == e) {
      // immutable model -> replace with new instance
      users[i] = UserModel(
        email: users[i].email,
        password: newPassword,
      );
      return "Password changed successfully!";
    }
  }
  return "Email not found!";
}

/// ------------------- DEBUG (optional) -------------------
void debugUsers() {
  print(users.map((u) => u.email).toList());
}