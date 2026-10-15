import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../design_system.dart';
import 'state.dart';

const warm = Color(0xFFF8F2E9);
const ink = Color(0xFF002A3B);

class FigmaAsset extends StatelessWidget {
  const FigmaAsset(this.file, {this.width, this.height, super.key});
  final String file;
  final double? width, height;
  @override
  Widget build(BuildContext context) => file.endsWith('.svg')
      ? SvgPicture.asset('assets/figma/$file', excludeFromSemantics: true)
      : Image.asset(
          'assets/figma/$file',
          width: width,
          height: height,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        );
}

class WellnessScaffold extends StatelessWidget {
  const WellnessScaffold({
    required this.state,
    required this.title,
    required this.body,
    required this.onBack,
    required this.onProfile,
    this.footer,
    this.navigation,
    this.brand = false,
    super.key,
  });
  final WellnessState state;
  final String title;
  final Widget body;
  final Widget? footer, navigation;
  final VoidCallback onBack, onProfile;
  final bool brand;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFEDEAE4),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Scaffold(
          backgroundColor: CareColors.canvas,
          body: Stack(
            children: [
              Positioned(
                left: -112.42,
                top: -354.63,
                width: 605.806,
                height: 458.779,
                child: Center(
                  child: Transform.rotate(
                    angle: -10.12 * math.pi / 180,
                    child: const FigmaAsset('29ea8.svg'),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: MediaQuery.paddingOf(context).top),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: brand ? 8 : 17,
                    ),
                    child: SizedBox(
                      height: 34,
                      child: Row(
                        children: [
                          if (brand)
                            const Row(
                              children: [
                                FigmaAsset('16e0e.svg'),
                                SizedBox(width: 8),
                                FigmaAsset('a4176.svg'),
                              ],
                            )
                          else ...[
                            Semantics(
                              button: true,
                              label: 'Back',
                              child: InkWell(
                                onTap: onBack,
                                child: const SizedBox(
                                  width: 30,
                                  height: 34,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FigmaAsset('8c03e.svg'),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Family',
                                  fontSize: 28,
                                  height: 1.2,
                                  color: ink,
                                ),
                              ),
                            ),
                          ],
                          if (brand) const Spacer(),
                          Semantics(
                            button: true,
                            label: 'Edit profile',
                            child: InkWell(
                              onTap: onProfile,
                              borderRadius: BorderRadius.circular(20),
                              child: MemberAvatar(state: state),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
            ],
          ),
          bottomNavigationBar:
              navigation ??
              (footer == null
                  ? null
                  : SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: footer,
                      ),
                    )),
        ),
      ),
    ),
  );
}

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({required this.state, this.size = 30, super.key});
  final WellnessState state;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: CareColors.navy,
      shape: BoxShape.circle,
    ),
    clipBehavior: Clip.antiAlias,
    alignment: Alignment.center,
    child: state.profilePhoto != null
        ? Image.memory(
            state.profilePhoto!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              Text(
                state.initials,
                style: label(size > 40 ? 22 : 11, color: Colors.white),
              ),
              if (size == 30) const FigmaAsset('38b9c.svg'),
            ],
          ),
  );
}

class Panel extends StatelessWidget {
  const Panel({
    required this.child,
    this.color = Colors.white,
    this.padding = 16,
    this.onTap,
    this.radius = 14,
    this.borderColor = CareColors.border,
    super.key,
  });
  final Widget child;
  final Color color, borderColor;
  final double padding, radius;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    ),
  );
}

class ActionButton extends StatelessWidget {
  const ActionButton(
    this.text,
    this.onPressed, {
    this.secondary = false,
    super.key,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool secondary;
  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 46)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textStyle: WidgetStatePropertyAll(label(16)),
    );
    return secondary
        ? OutlinedButton(
            style: style.copyWith(
              side: const WidgetStatePropertyAll(
                BorderSide(color: CareColors.border),
              ),
              foregroundColor: const WidgetStatePropertyAll(ink),
            ),
            onPressed: onPressed,
            child: Text(text, textAlign: TextAlign.center),
          )
        : FilledButton(
            style: style,
            onPressed: onPressed,
            child: Text(text, textAlign: TextAlign.center),
          );
  }
}

Widget vertical(
  List<Widget> children, {
  double gap = 16,
  CrossAxisAlignment alignment = CrossAxisAlignment.stretch,
}) => Column(
  crossAxisAlignment: alignment,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (var i = 0; i < children.length; i++) ...[
      if (i > 0) SizedBox(height: gap),
      children[i],
    ],
  ],
);
Widget scrollBody(List<Widget> children, {double top = 0, double gap = 16}) =>
    ListView(
      padding: EdgeInsets.fromLTRB(20, top, 20, 24),
      children: [vertical(children, gap: gap)],
    );
Widget bodyText(
  String text, {
  double size = 14,
  bool center = false,
  Color color = CareColors.muted,
}) => Text(
  text,
  textAlign: center ? TextAlign.center : TextAlign.start,
  style: TextStyle(fontSize: size, height: 1.45, color: color),
);
Widget serif(String text, {double size = 24, bool center = false}) => Text(
  text,
  textAlign: center ? TextAlign.center : TextAlign.start,
  style: TextStyle(
    fontFamily: 'Family',
    fontSize: size,
    height: 1.15,
    color: ink,
  ),
);
Widget heading(String text, {double size = 16}) =>
    Text(text, style: label(size, color: ink));
Widget rule() =>
    const Divider(color: CareColors.border, height: 1, thickness: 1);
Widget split(Widget left, Widget right) => Row(
  children: [
    Expanded(child: left),
    const SizedBox(width: 8),
    right,
  ],
);
Widget pill(String text, {Color color = CareColors.navy}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(100),
  ),
  child: Text(
    text,
    style: label(11, color: color, weight: FontWeight.w400),
  ),
);
Widget progress(
  double value, {
  Color color = CareColors.navy,
  double height = 8,
}) => ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: LinearProgressIndicator(
    value: value.clamp(0, 1),
    minHeight: height,
    color: color,
    backgroundColor: const Color(0xFFEDF8FC),
  ),
);

class LinkRow extends StatelessWidget {
  const LinkRow(
    this.title,
    this.subtitle,
    this.onTap, {
    this.icon = '32f6c.svg',
    super.key,
  });
  final String title, subtitle, icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Panel(
    color: warm,
    padding: 14,
    onTap: onTap,
    child: Row(
      children: [
        FigmaAsset(icon),
        const SizedBox(width: 12),
        Expanded(
          child: vertical([
            heading(title, size: 14),
            bodyText(subtitle, size: 12),
          ], gap: 2),
        ),
        const FigmaAsset('13891.svg'),
      ],
    ),
  );
}

class Illustration extends StatelessWidget {
  const Illustration(this.kind, {super.key});
  final String kind;
  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 195,
      height: 180,
      child: Stack(
        children: [
          FigmaAsset(kind == 'submitted' ? '90539.svg' : 'ec9c4.svg'),
          if (kind == 'joined')
            const Positioned(
              left: 35,
              top: 27.25,
              child: FigmaAsset('bfa9d.svg'),
            ),
          if (kind == 'sharing')
            const Positioned(
              left: 39.6,
              top: 32.6,
              child: FigmaAsset('52ebd.svg'),
            ),
          if (kind == 'complete') ...[
            const Positioned(
              left: 33,
              top: 31.25,
              child: FigmaAsset('5082f.svg'),
            ),
            const Positioned(
              left: 139,
              top: 21,
              child: FigmaAsset('f52ac.svg'),
            ),
          ],
          if (kind == 'submitted') ...[
            const Positioned(
              left: 79.01,
              top: 26.53,
              child: FigmaAsset('b01f6.svg'),
            ),
            const Positioned(
              left: 12.81,
              top: 56.48,
              child: FigmaAsset('233ad.svg'),
            ),
          ],
        ],
      ),
    ),
  );
}

class WellnessNav extends StatelessWidget {
  const WellnessNav({
    required this.onHome,
    required this.onTeam,
    required this.onHealth,
    required this.onRecords,
    required this.onSettings,
    super.key,
  });
  final VoidCallback onHome, onTeam, onHealth, onRecords, onSettings;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x1A000000),
          offset: Offset(0, -4),
          blurRadius: 20,
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 76,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 23.5, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 5; i++)
                Semantics(
                  button: true,
                  label: [
                    'Home',
                    'Care team',
                    'Health data',
                    'Records',
                    'Settings',
                  ][i],
                  child: InkWell(
                    onTap: [onHome, onTeam, onHealth, onRecords, onSettings][i],
                    child: SizedBox(
                      width: [60.0, 38.0, 52.5, 60.0, 60.0][i],
                      height: 60,
                      child: Center(
                        child: FigmaAsset(
                          [
                            '47c32.svg',
                            '9089e.svg',
                            'd6021.svg',
                            'a59b3.svg',
                            'c4d31.svg',
                          ][i],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
