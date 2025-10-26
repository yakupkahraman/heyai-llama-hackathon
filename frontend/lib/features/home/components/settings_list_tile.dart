import 'package:flutter/material.dart';
import 'package:heylex/core/theme/theme_constants.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.onTap,
  });

  final String title;
  final IconData leadingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      contentPadding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
      leading: Icon(leadingIcon, color: ThemeConstants.creamColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "OpenDyslexic",
          fontSize: 14,
          color: ThemeConstants.creamColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ThemeConstants.creamColor,
      ),
      onTap: onTap,
    );
  }
}
