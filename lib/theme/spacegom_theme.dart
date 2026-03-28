import 'package:flutter/material.dart';

class SpacegomTheme {
  static const _background = Color(0xFF0D1117);
  static const _surface = Color(0xFF161B22);
  static const _surfaceVariant = Color(0xFF1C2333);
  static const _primary = Color(0xFF58A6FF);
  static const _onBackground = Color(0xFFE6EDF3);
  static const _onSurface = Color(0xFFB0BAC6);
  static const _success = Color(0xFF2EA043);
  static const _error = Color(0xFFDA3633);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _background,
    colorScheme: const ColorScheme.dark(
      surface: _surface,
      surfaceContainerHighest: _surfaceVariant,
      primary: _primary,
      onSurface: _onBackground,
      onSurfaceVariant: _onSurface,
      error: _error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _surface,
      foregroundColor: _onBackground,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: _surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: Color(0xFF30363D)),
      ),
    ),
    extensions: const [
      SpacegomColors(
        success: _success,
        danger: _error,
        teal: Color(0xFF2DD4BF),
      ),
    ],
  );
}

@immutable
class SpacegomColors extends ThemeExtension<SpacegomColors> {
  final Color success;
  final Color danger;
  final Color teal;

  const SpacegomColors({
    required this.success,
    required this.danger,
    required this.teal,
  });

  @override
  SpacegomColors copyWith({Color? success, Color? danger, Color? teal}) {
    return SpacegomColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      teal: teal ?? this.teal,
    );
  }

  @override
  SpacegomColors lerp(SpacegomColors? other, double t) {
    if (other is! SpacegomColors) return this;

    return SpacegomColors(
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
    );
  }
}
