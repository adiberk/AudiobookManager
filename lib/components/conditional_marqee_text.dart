import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class ConditionalMarquee extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double maxWidth;
  final double blankSpace;
  final double velocity;
  final Duration pauseAfterRound;
  final double startPadding;

  const ConditionalMarquee({
    Key? key,
    required this.text,
    required this.style,
    this.maxWidth = double.infinity,
    this.blankSpace = 50.0,
    this.velocity = 30.0,
    this.pauseAfterRound = const Duration(seconds: 1),
    this.startPadding = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the provided maxWidth if it's not infinity, otherwise use constraints.maxWidth
        final effectiveMaxWidth =
            maxWidth != double.infinity ? maxWidth : constraints.maxWidth;

        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.infinity);

        bool isOverflowing = textPainter.width > effectiveMaxWidth;

        return SizedBox(
          height: style.fontSize! + 6, // Ensure text fits
          width: effectiveMaxWidth,
          child: isOverflowing
              ? Marquee(
                  text: text,
                  style: style,
                  scrollAxis: Axis.horizontal,
                  blankSpace: blankSpace,
                  velocity: velocity,
                  pauseAfterRound: pauseAfterRound,
                  startPadding: startPadding,
                )
              : Text(text,
                  style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}
