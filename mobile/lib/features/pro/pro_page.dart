import 'package:flutter/material.dart';
import 'package:bestox/core/theme/app_colors.dart';
import 'package:bestox/core/theme/app_fonts.dart';

class ProPage extends StatelessWidget {
  const ProPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 12),


              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  'Upgrade',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Get BeStox Pro
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Get ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'BeStox ',
                      style: TextStyle(
                        fontFamily: 'ChangaOne',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightGreen,
                      ),
                    ),
                    TextSpan(
                      text: 'Pro',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Image.asset(
                'assets/images/gift_box.png',
                height: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // Yearly Plan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEB5757), Color(0xFFD65A3A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 8),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: const [
                    Text(
                      'Yearly 59.99 \$ - Per month 6\$',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Save 50% off',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Monthly Plan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Monthly 9.99\$',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Upgrade Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Checkbox + Terms
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(value: false, onChanged: (_) {}),
                  const Expanded(
                    child: Text(
                      'By placing this order, you agree to the Terms of Service and Privacy Policy. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
