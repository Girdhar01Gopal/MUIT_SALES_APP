import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme F - "Maroon & Gold".
///
/// One place for every colour and a few small shared widgets, so the nine
/// screens do not each carry their own copy of the palette.
/// Put this file at: lib/res/brand.dart
class Brand {
  Brand._();

  // ---------------- maroon ----------------
  static const Color maroonDarkest = Color(0xFF3F0A1A);
  static const Color maroonDeep = Color(0xFF4A0B1E);
  static const Color maroonMid = Color(0xFF6E1230);
  static const Color maroon = Color(0xFF7A1631);
  static const Color maroonLight = Color(0xFF8C1C3E);
  static const Color maroonTint = Color(0xFFF7E4E9);

  // ---------------- gold ----------------
  static const Color gold = Color(0xFFFFC72C);
  static const Color goldSoft = Color(0xFFFFD866);
  static const Color goldTint = Color(0xFFFFF6D6);
  static const Color goldTintBorder = Color(0xFFF1D98A);
  static const Color goldChip = Color(0xFFFFF3C4);
  static const Color goldText = Color(0xFF7A5A00); // readable gold on light
  static const Color goldInk = Color(0xFF4A2F00); // text on solid gold

  // ---------------- rose (Admission) ----------------
  static const Color rose = Color(0xFFE26D8A);
  static const Color roseTint = Color(0xFFFCE6EC);
  static const Color roseText = Color(0xFFA8304F);

  // ---------------- neutrals ----------------
  static const Color canvas = Color(0xFFF8F4F5);
  static const Color hairline = Color(0xFFEADFE2);
  static const Color hairlineStrong = Color(0xFFE3D3D8);
  static const Color ink = Color(0xFF2A0E17);
  static const Color inkSoft = Color(0xFF6B4A55);
  static const Color blush = Color(0xFFFBF1F4);
  static const Color blushBorder = Color(0xFFD9A9B8);

  // ---------------- semantic ----------------
  static const Color danger = Color(0xFFB42318);
  static const Color dangerTint = Color(0xFFFDECEB);
  static const Color success = Color(0xFF1E7B4F);
  static const Color successTint = Color(0xFFE3F4EB);
  static const Color warning = Color(0xFF9A6500);

  // ---------------- shapes & shadows ----------------
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    side: BorderSide(color: hairline, width: 1),
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x144A0B1E),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  // ---------------- lead status (Enquiry = Orange, Admission = Green, Follow-up = Blue) ----------------
  static const Color orange = Color(0xFFF97316);
  static const Color orangeTint = Color(0xFFFFEDD5);
  static const Color orangeText = Color(0xFFC2410C);

  static const Color green = Color(0xFF16A34A);
  static const Color greenTint = Color(0xFFDCFCE7);
  static const Color greenText = Color(0xFF15803D);

  static const Color blue = Color(0xFF2563EB);
  static const Color blueTint = Color(0xFFDBEAFE);
  static const Color blueText = Color(0xFF1D4ED8);

  /// Solid colour (gauge arcs, dots, chart bars)
  static Color statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('admission')) {
      return green;
    } else if (s.contains('follow')) {
      return blue;
    } else {
      return orange; // Enquiry
    }
  }

  /// Text colour that stays readable on [statusTint]
  static Color statusText(String status) {
    final s = status.toLowerCase();
    if (s.contains('admission')) {
      return greenText;
    } else if (s.contains('follow')) {
      return blueText;
    } else {
      return orangeText; // Enquiry
    }
  }

  /// Background tint colour for BrandChip & status cards
  static Color statusTint(String status) {
    final s = status.toLowerCase();
    if (s.contains('admission')) {
      return greenTint;
    } else if (s.contains('follow')) {
      return blueTint;
    } else {
      return orangeTint; // Enquiry
    }
  }
  static Color priorityColor(String priority) {
    switch (priority) {
      case 'Hot':
        return const Color(0xFFC62828);
      case 'Warm':
        return const Color(0xFFB26A00);
      default:
        return const Color(0xFF2F5FD0);
    }
  }

  // ---------------- shared building blocks ----------------
  static AppBar appBar(String title, {PreferredSizeWidget? bottom}) {
    return AppBar(
      backgroundColor: maroonDeep,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      bottom: bottom,
    );
  }

  static OutlineInputBorder inputBorder({
    Color color = hairlineStrong,
    double width = 1,
    double radius = 16,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputDecoration searchDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: inkSoft),
      prefixIcon: const Icon(Icons.search, color: inkSoft),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: inputBorder(),
      enabledBorder: inputBorder(),
      focusedBorder: inputBorder(color: maroon, width: 1.5),
    );
  }

  static ButtonStyle outlinedButton({double radius = 14, double vertical = 13}) {
    return OutlinedButton.styleFrom(
      foregroundColor: maroon,
      side: const BorderSide(color: hairlineStrong),
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );
  }

  static ButtonStyle maroonButton({double radius = 12, double vertical = 12}) {
    return ElevatedButton.styleFrom(
      backgroundColor: maroon,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

/// Soft warm background that replaces the blue AppBackground.
class BrandBackground extends StatelessWidget {
  final Widget child;

  const BrandBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF1E7EA), Brand.canvas],
          stops: [0.0, 0.4],
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}

/// Small rounded label (status, priority, duration ...).
class BrandChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final double fontSize;

  const BrandChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Gold call-to-action with dark text (the Upload button).
class BrandGoldButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const BrandGoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Brand.gold.withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Brand.gold,
          foregroundColor: Brand.ink,
          disabledBackgroundColor: Brand.goldSoft,
          disabledForegroundColor: Brand.goldInk,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Brand.ink,
          ),
        )
            : Text(label),
      ),
    );
  }
}
