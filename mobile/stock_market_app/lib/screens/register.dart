import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? confirmError;
  String? usernameError;

  bool isLoading = false;

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  final Color background = const Color(0xFFF5F6FA);
  final Color inputBackground = const Color(0xFFE9EDF4);
  final Color green = const Color(0xFF195C2F);
  final Color textDark = const Color(0xFF111111);

  bool get isFormValid =>
      emailRegex.hasMatch(emailController.text) &&
          passwordController.text.length >= 8 &&
          passwordController.text == confirmPasswordController.text &&
          usernameController.text.isNotEmpty;

  void validateInputs() {
    setState(() {
      emailError = emailRegex.hasMatch(emailController.text) ? null : 'Invalid email';
      passwordError = passwordController.text.length >= 8 ? null : 'Password too short';
      confirmError = confirmPasswordController.text == passwordController.text
          ? null
          : 'Passwords do not match';
      usernameError = usernameController.text.isNotEmpty ? null : 'Username required';
    });
  }

  Future<void> registerUser() async {
    validateInputs();
    if (!isFormValid) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://stocks-backend-9lwx.onrender.com/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const LoginPage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      } else {
        showError(data['error'] ?? 'Something went wrong');
      }
    } catch (e) {
      showError('Connection error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String hint,
    required String? errorText,
    bool obscure = false,
    void Function()? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: (_) => validateInputs(),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                const Text(
                  'BeStox',
                  style: TextStyle(
                    fontFamily: 'ChangaOne',
                    fontSize: 54,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF195C2F),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Register',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                buildField(
                  controller: usernameController,
                  hint: 'Username',
                  errorText: usernameError,
                ),
                buildField(
                  controller: emailController,
                  hint: 'Email',
                  errorText: emailError,
                ),
                buildField(
                  controller: passwordController,
                  hint: 'Password',
                  errorText: passwordError,
                  obscure: true,
                ),
                buildField(
                  controller: confirmPasswordController,
                  hint: 'Confirm Password',
                  errorText: confirmError,
                  obscure: true,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFormValid && !isLoading ? registerUser : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (_, __, ___) => const LoginPage(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
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
