import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_market_app/screens/pro_version_screen.dart';
import 'login.dart';
import 'package:stock_market_app/screens/portfolio.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final double balance;
  final String name;
  final String username;

  const ProfileScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.balance,
    this.name = "Tom Anderson",
    this.username = "@jamal1233",
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
    BuildContext? context,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context!).cardColor,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).iconTheme.color),
        title: Text(label),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // User Info Card
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/meme.png'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      Text(username,
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text(
                        '\$${balance.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Option Buttons
          _buildOption(
            icon: Icons.star_border,
            label: 'Watchlist',
            context: context,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PortfolioScreen(onBalanceUpdate: (_, __) {}),
                ),
              );
            },
          ),
          _buildOption(icon: Icons.notifications_none, label: 'Notifications', context: context),
          _buildOption(
            icon: Icons.workspace_premium_outlined,
            label: 'Pro version',
            context: context,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProVersionScreen()),
              );
            },
          ),

          _buildOption(
            icon: Icons.dark_mode_outlined,
            label: 'Dark mode',
            trailing: Switch(
              value: isDarkMode,
              onChanged: (_) => toggleTheme(),
            ),
            context: context,
          ),
          _buildOption(icon: Icons.settings, label: 'Settings', context: context),
          _buildOption(icon: Icons.help_outline, label: 'Help', context: context),
          _buildOption(
            icon: Icons.logout,
            label: 'Log Out',
            onTap: () => _logout(context),
            context: context,
          ),
        ],
      ),
    );
  }
}
