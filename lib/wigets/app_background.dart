import 'package:flutter/material.dart';
import 'package:muit_sales_app/infrastructures/constant/image_constant.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double imageWidth;

  const AppBackground({
    super.key,
    required this.child,
    this.opacity = 0.15,
    this.imageWidth = 390,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ---------- WATERMARK BACKGROUND ----------
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: opacity,
                child: Image.asset(
                  ImageConstants.bgLogo, // Path called from central Constant
                  width: imageWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // ---------- SCREEN CONTENT ----------
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}