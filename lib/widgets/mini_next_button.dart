import 'package:flutter/material.dart';

class MiniNextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MiniNextButton({
    super.key,
    required this.onPressed,  
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Image.asset(
            'assets/icons/arrow_right_in_circle_512.png',
            fit: BoxFit.cover
            ),
        )
      ),
    );
  }
}