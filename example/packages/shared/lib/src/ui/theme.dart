import 'package:flutter/material.dart';

/// Colors of the example apps, the same as the React Native and NativeScript examples'. The accent is the red of the
/// SDK's own illustrations, so the host screens and the SDK screens they open look like one product.
///
abstract final class IaColors {
  static const accent = Color(0xFFE73439);
  static const accentSoft = Color(0xFFFDECEC);
  static const accentOnSoft = Color(0xFFB3262A);
  static const ink = Color(0xFF16181D);
  static const inkSecondary = Color(0xFF5A606B);
  static const inkTertiary = Color(0xFF8B919B);
  static const background = Color(0xFFF4F2EF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSunken = Color(0xFFF0EEEA);
  static const border = Color(0xFFE7E4DF);

  /// The track of a switch that's off: dark enough for its white thumb.
  static const switchOff = Color(0xFFCDC8C1);
  static const success = Color(0xFF1E8E5A);
  static const successSoft = Color(0xFFE5F4EC);
}

abstract final class IaRadius {
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const pill = 999.0;
}

abstract final class IaSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Text styles. Each sets its letter spacing, as Material's text theme, which text inherits from, spaces body text wider
/// than the system's.
///
abstract final class IaTextStyles {
  static const title = TextStyle(fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: IaColors.ink);
  static const headline = TextStyle(fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600, letterSpacing: 0, color: IaColors.ink);
  static const body = TextStyle(fontSize: 15, height: 21 / 15, fontWeight: FontWeight.w400, letterSpacing: 0, color: IaColors.ink);
  static const caption = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: IaColors.inkSecondary,
  );

  /// The small capitalized heading above a card. Uppercase the text itself.
  static const overline = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: IaColors.inkSecondary,
  );

  /// Log entries and results.
  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['Menlo', 'Courier'],
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
}

/// The card shadow: soft and warm on iOS, a low elevation's on Android.
///
const iaCardShadow = [BoxShadow(color: Color(0x122B1B12), blurRadius: 14, offset: Offset(0, 6))];

/// The theme of the example apps. Their own widgets use [IaColors] and [IaTextStyles]; this styles the Material widgets
/// they still use, such as dialogs, snack bars and progress indicators.
///
ThemeData iaExampleTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: IaColors.accent,
    primary: IaColors.accent,
    onPrimary: Colors.white,
    surface: IaColors.surface,
    onSurface: IaColors.ink,
    onSurfaceVariant: IaColors.inkSecondary,
    outline: IaColors.border,
    error: IaColors.accentOnSoft,
  );
  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: IaColors.background,
    dividerColor: IaColors.border,
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: IaColors.accent),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: IaColors.accent, textStyle: IaTextStyles.headline.copyWith(fontSize: 15)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: IaColors.ink,
      contentTextStyle: IaTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
      shape: const StadiumBorder(),
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: IaColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IaRadius.lg)),
      titleTextStyle: IaTextStyles.title,
      contentTextStyle: IaTextStyles.body.copyWith(color: IaColors.inkSecondary),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: IaColors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: IaColors.border,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(IaRadius.xl))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IaColors.surfaceSunken,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: IaSpacing.md, vertical: IaSpacing.md - 1),
      hintStyle: IaTextStyles.body.copyWith(color: IaColors.inkTertiary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(IaRadius.md), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IaRadius.md),
        borderSide: const BorderSide(color: IaColors.accent),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: IaColors.accent, selectionHandleColor: IaColors.accent),
  );
}
