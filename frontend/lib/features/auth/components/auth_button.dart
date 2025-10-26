import 'package:flutter/material.dart';
import 'package:heylex/core/theme/theme_constants.dart';

/// A small reusable button used in auth flows.
///
/// Features:
/// - `label`: text shown on the button
/// - `onPressed`: callback when tapped (disabled while `isLoading` is true)
/// - `isLoading`: shows a small circular indicator and disables the button
/// - `leading`: optional widget placed before the label (eg. Icon)
/// - `style`: optional `ButtonStyle` to override appearance
class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.creamColor,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontFamily: "OpenDyslexic",
            color: ThemeConstants.darkGreyColor,
          ),
        ),
      ),
    );
  }
}
