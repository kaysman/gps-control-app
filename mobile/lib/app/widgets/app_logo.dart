import 'package:flutter/material.dart';

/// The app mark: the same arrow that ships as the launcher icon and the launch
/// screen, so the header, the home screen and the splash all agree.
///
/// The artwork at `assets/images/logo.png` (with 2x/3x variants) is the
/// transparent cut of the icon — no plate, no ground — so it sits on whatever
/// surface the header already has, ink or mist.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 26, super.key});

  /// Edge of the square the arrow is drawn in.
  final double size;

  @override
  Widget build(BuildContext context) {
    // Decorative: every place this appears, the title beside it already names
    // the app to a screen reader.
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
