import 'package:flutter/material.dart';
import 'package:bestox/core/theme/app_colors.dart';
import 'package:bestox/core/theme/app_fonts.dart';
import 'package:bestox/widgets/custom_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6), // 🔼 biraz daha yukarı
                Text(
                  'BeStox',
                  style: const TextStyle(
                    fontFamily: 'ChangaOne',
                    fontSize: 54,
                    fontStyle: FontStyle.italic, // ✅ italic yapıldı
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Login',
                  style: AppFonts.body.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'E-mail',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot your password?',
                    style: AppFonts.caption.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Login',
                  onPressed: () {},
                ),
                const SizedBox(height: 32),
                Text(
                  'Create new account',
                  style: AppFonts.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
