import '../core/user_data.dart';
import '../models/user_model.dart';

String resetPassword(String email, String newPassword) {
  for (int i = 0; i < users.length; i++) {
    if (users[i].email == email) {
      // Create a new UserModel with updated password
      users[i] = UserModel(email: users[i].email, password: newPassword);
      return "Password changed successfully!";
    }
  }
  return "email not found.";
}