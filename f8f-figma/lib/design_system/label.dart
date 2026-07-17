import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';

class AnchorLabel extends StatelessWidget {
  const AnchorLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AnchorColors.slate600,
        letterSpacing: 0.2,
      ),
    );
  }
}
