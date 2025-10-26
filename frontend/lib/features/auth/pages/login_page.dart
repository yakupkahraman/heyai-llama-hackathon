import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/auth/components/auth_button.dart';
import 'package:heylex/features/auth/components/auth_textfield.dart';
import 'package:heylex/features/auth/providers/user_provider.dart';
import 'package:heylex/features/auth/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      _showError("Lütfen email adresinizi girin");
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError("Lütfen şifrenizi girin");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError("Şifre en az 6 karakter olmalıdır");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);
          await prefs.setBool('questions_completed', true);
          if (!mounted) return;
          final userProvider = context.read<UserProvider>();
          await userProvider.loadFromSupabase();

          if (mounted) {
            context.go('/');
          }
        } else {
          _showError("Giriş başarısız");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError("Hata: ${e.toString()}");
        log("Hata: $e");
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: ThemeConstants.darkGreyColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'app_logo',
              child: Image.asset('assets/images/logo.png', height: 32),
            ),
            SizedBox(width: 8),
            Text(
              "HeyLex",
              style: TextStyle(
                fontFamily: "OpenDyslexic",
                fontSize: 16,
                color: ThemeConstants.creamColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Hoş Geldiniz!",
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: "OpenDyslexic",
                    color: ThemeConstants.creamColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: AuthTextfield(
                  hintText: "Email",
                  prefixIcon: Icons.email,
                  controller: _emailController,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: AuthTextfield(
                  hintText: "Şifre",
                  prefixIcon: Icons.lock,
                  controller: _passwordController,
                  obscureText: true,
                  onSubmitted: (value) => _handleLogin(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 60,
                ),
                child: AuthButton(
                  label: _isLoading ? "Giriş Yapılıyor..." : "Giriş Yap",
                  onPressed: _isLoading ? null : _handleLogin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
