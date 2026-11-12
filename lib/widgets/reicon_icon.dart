import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/reicon_paths.dart';

/// Renders Reicon (https://reicon.dev) SVG path data at [size], tinted with
/// [color]. Mirrors the Icon widget's role in the bottom navigation bar.
class ReiconIcon extends StatelessWidget {
  final String pathData;
  final double size;
  final Color? color;

  const ReiconIcon(this.pathData, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" width="24" '
        'height="24" viewBox="0 0 24 24" fill="none">$pathData</svg>';
    return SvgPicture.string(svg,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn));
  }
}
