import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class CareColors {
  static const canvas = Color(0xFFFAF7F2);
  static const navy = Color(0xFF004966);
  static const header = Color(0xFF053549);
  static const muted = Color(0xFF5B6D75);
  static const green = Color(0xFF438808);
  static const lime = Color(0xFFA4DA75);
  static const border = Color(0xFFE2D9CA);
}

class DesignAsset extends StatelessWidget {
  const DesignAsset(this.name, {super.key});
  final String name;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/$name.svg', excludeFromSemantics: true);
}

TextStyle label(double size, {Color? color, FontWeight? weight}) => TextStyle(
  fontSize: size,
  height: 1.2,
  letterSpacing: 0,
  color: color ?? CareColors.navy,
  fontWeight: weight ?? FontWeight.w500,
);
