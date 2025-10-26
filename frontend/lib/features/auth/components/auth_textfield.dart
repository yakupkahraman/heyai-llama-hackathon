import 'package:flutter/material.dart';
import 'package:heylex/core/theme/theme_constants.dart';

class AuthTextfield extends StatelessWidget {
  const AuthTextfield({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      style: TextStyle(
        color: ThemeConstants.darkGreyColor,
        fontFamily: "OpenDyslexic",
        fontSize: 14,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon),
        hintText: hintText,
        filled: true,
        fillColor: ThemeConstants.creamColor,
        prefixIconColor: ThemeConstants.darkGreyColor,
        hintStyle: TextStyle(
          color: ThemeConstants.darkGreyColor.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    );
  }
}
