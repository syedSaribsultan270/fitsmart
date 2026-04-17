import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A drop-in replacement for [Text] that:
///  - Scales font sizes proportionally to screen size via flutter_screenutil.
///  - Defaults to [TextOverflow.ellipsis] and [maxLines: 1] so user-generated
///    content never overflows, without needing to remember per-widget.
///
/// Usage:
///   AppText('Some meal name', style: AppTypography.body)
///   AppText('Multi-line note', style: AppTypography.caption, maxLines: 3)
///   AppText('Heading', style: AppTypography.h2, overflow: TextOverflow.visible)
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  /// Defaults to 1. Pass null for unlimited lines.
  final int? maxLines;

  /// Defaults to [TextOverflow.ellipsis].
  final TextOverflow overflow;

  final TextAlign? textAlign;
  final bool? softWrap;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    // Scale the font size proportionally to the reference design (390px wide).
    final scaledStyle = style?.fontSize != null
        ? style!.copyWith(fontSize: style!.fontSize!.sp)
        : style;

    return Text(
      text,
      style: scaledStyle,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}
