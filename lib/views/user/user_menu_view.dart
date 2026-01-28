import 'package:flutter/material.dart';

class UserMenuView extends StatelessWidget {
  const UserMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.category),
            title: Text("Shop by Category"),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text("Help & Support"),
          ),
        ],
      ),
    );
  }
}
