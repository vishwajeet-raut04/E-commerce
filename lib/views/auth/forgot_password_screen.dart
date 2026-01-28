import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter your email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Enter new password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String msg = resetPassword(
                  emailController.text,
                  passwordController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              },
              child: Text("Change Password"),
            )
          ],
        ),
      ),
    );
  }
}