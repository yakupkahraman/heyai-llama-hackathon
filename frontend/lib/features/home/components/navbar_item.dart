import 'package:flutter/material.dart';
import 'package:heylex/core/theme/theme_constants.dart';

class NavItem extends StatefulWidget {
  final int index;
  final IconData unSelectedIcon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.unSelectedIcon,
    required this.selectedIcon,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          Color backgroundColor;
          if (widget.isSelected) {
            backgroundColor = ThemeConstants.darkGreyColor;
          } else if (_isPressed) {
            backgroundColor = Colors.white.withOpacity(0.3);
          } else {
            backgroundColor = Colors.transparent;
          }

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Icon(
                widget.isSelected ? widget.selectedIcon : widget.unSelectedIcon,
                color: widget.isSelected
                    ? ThemeConstants.creamColor
                    : Colors.white,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}
