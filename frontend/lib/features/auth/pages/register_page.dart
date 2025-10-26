import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/auth/components/auth_button.dart';
import 'package:heylex/features/auth/components/auth_textfield.dart';
import 'package:heylex/features/auth/providers/user_answers_provider.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showError("Lütfen adınızı girin");
      return;
    }

    if (_surnameController.text.trim().isEmpty) {
      _showError("Lütfen soyadınızı girin");
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError("Lütfen email adresinizi girin");
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError("Lütfen şifrenizi girin");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Şifreler eşleşmiyor");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError("Şifre en az 6 karakter olmalıdır");
      return;
    }

    // Bilgileri provider'a kaydet
    final provider = Provider.of<UserAnswersProvider>(context, listen: false);
    provider.setBasicInfo(
      _nameController.text.trim(),
      _surnameController.text.trim(),
    );
    log(
      'Temel bilgiler kaydedildi: ${_nameController.text.trim()} ${_surnameController.text.trim()}',
    );
    provider.setEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );
    log(
      'Email ve şifre kaydedildi: ${_emailController.text.trim()} ${_passwordController.text.trim()}',
    );

    // Sorulara yönlendir
    context.go('/auth/register/questions');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Haydi Kayıt Olalım!",
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: "OpenDyslexic",
                      color: ThemeConstants.creamColor,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: AuthTextfield(
                        hintText: "Ad",
                        prefixIcon: Icons.person,
                        controller: _nameController,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: AuthTextfield(
                        hintText: "Soyad",
                        prefixIcon: Icons.person_outline,
                        controller: _surnameController,
                      ),
                    ),
                    SizedBox(height: 16),
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
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: AuthTextfield(
                        hintText: "Şifreni Onayla",
                        prefixIcon: Icons.lock,
                        controller: _confirmPasswordController,
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50.0,
                    vertical: 60.0,
                  ),
                  child: AuthButton(
                    label: "Devam Et",
                    onPressed: _handleContinue,
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
