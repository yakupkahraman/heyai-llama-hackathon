import 'dart:ui';
import 'package:flutter/material.dart';

class GlassEffectContainer extends StatelessWidget {
  const GlassEffectContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              // Inner shadow - beyaz (üstten)
              BoxShadow(
                color: Color(0xFFFFFFFF).withOpacity(0.1), // #FFFFFF66
                offset: Offset(0, -2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
              // Inner shadow - siyah (alttan)
              BoxShadow(
                color: Color(0x00000000).withOpacity(0.2), // #00000033
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
