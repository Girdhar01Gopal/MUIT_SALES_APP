class FormatHelper {
  static String rupees(int n) {
    final s = n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+\d$)'),
          (m) => '${m[1]},',
    );
    return '₹$s';
  }
}