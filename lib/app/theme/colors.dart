import 'dart:ui';

/// Thryve brand color palette matching the website aesthetics
class ThryveColors {
  ThryveColors._();

  // ============ Primary Brand Colors ============
  /// Hermes Orange - Primary accent color
  static const Color accent = Color(0xFFF37021);

  /// Lighter variant of accent
  static const Color accentLight = Color(0xFFFF9F5E);

  /// Darker variant for pressed states
  static const Color accentDark = Color(0xFFD45F1A);

  // ============ Neutrals (Light Mode) ============
  /// Main background color
  static const Color background = Color(0xFFF8FAFC);

  /// Surface color for cards, sheets
  static const Color surface = Color(0xFFF1F5F9);

  /// Elevated surface (slightly darker)
  static const Color surfaceElevated = Color(0xFFE2E8F0);

  /// Primary text color
  static const Color textPrimary = Color(0xFF0F172A);

  /// Secondary text color
  static const Color textSecondary = Color(0xFF64748B);

  /// Tertiary/hint text color
  static const Color textTertiary = Color(0xFF94A3B8);

  /// Divider color
  static const Color divider = Color(0xFFE2E8F0);

  // ============ Neutrals (Dark Mode) ============
  /// Dark mode background
  static const Color backgroundDark = Color(0xFF0F172A);

  /// Dark mode surface
  static const Color surfaceDark = Color(0xFF1E293B);

  /// Dark mode elevated surface
  static const Color surfaceElevatedDark = Color(0xFF334155);

  /// Dark mode primary text
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  /// Dark mode secondary text
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ============ Semantic Colors ============
  /// Success/gains color
  static const Color success = Color(0xFF10B981);

  /// Success light variant
  static const Color successLight = Color(0xFFD1FAE5);

  /// Error/losses color
  static const Color error = Color(0xFFEF4444);

  /// Error light variant
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Warning color
  static const Color warning = Color(0xFFF59E0B);

  /// Warning light variant
  static const Color warningLight = Color(0xFFFEF3C7);

  /// Info color
  static const Color info = Color(0xFF3B82F6);

  /// Info light variant
  static const Color infoLight = Color(0xFFDBEAFE);

  // ============ Glassmorphism ============
  /// Glass effect background
  static Color get glass => const Color(0xFFFFFFFF).withValues(alpha: 0.6);

  /// Glass effect background (dark mode)
  static Color get glassDark => const Color(0xFF1E293B).withValues(alpha: 0.8);

  // ============ Chart Colors ============
  /// Gradient for positive trend charts
  static const List<Color> positiveGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];

  /// Gradient for negative trend charts
  static const List<Color> negativeGradient = [
    Color(0xFFEF4444),
    Color(0xFFF87171),
  ];

  /// Accent gradient for hero sections
  static const List<Color> accentGradient = [
    Color(0xFFF37021),
    Color(0xFFFF9F5E),
  ];
}
