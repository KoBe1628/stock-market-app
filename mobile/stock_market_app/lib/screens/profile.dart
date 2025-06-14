import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ProfileScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'This is the Profile screen',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: widget.isDarkMode,
            onChanged: (value) {
              widget.toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}
