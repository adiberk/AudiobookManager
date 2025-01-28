import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {
  final VoidCallback onTap;

  const DragHandle({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              12, // Add safe area padding plus original padding
          bottom: 0,
        ),
        width: double.infinity,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
