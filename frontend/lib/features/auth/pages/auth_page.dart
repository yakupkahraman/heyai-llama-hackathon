import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/auth/components/auth_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: SizedBox(
                      width: 160,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "HeyLex",
                    style: TextStyle(
                      fontFamily: 'OpenDyslexic',
                      color: ThemeConstants.creamColor,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: AuthButton(
                      label: "Kayıt Ol",
                      onPressed: () {
                        context.go('/auth/register');
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: AuthButton(
                      label: "Giriş Yap",
                      onPressed: () {
                        context.go('/auth/login');
                      },
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
