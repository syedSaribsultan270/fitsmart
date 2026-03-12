import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

/// Convenience accessor so screens can write `context.colors.bgPrimary`
/// instead of `Theme.of(context).extension<AppColorsExtension>()!`.
extension ThemeX on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
