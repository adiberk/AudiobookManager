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
          top: MediaQuery.of(context).padding.top,
          bottom: 20,
        ),
        width: double.infinity,
        color: Colors.transparent, // Make the whole area tappable
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
