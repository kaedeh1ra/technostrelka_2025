import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const NextButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: _buildBtnContent()
      );
  }

  Widget _buildBtnContent() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(55))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(text, style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w500)),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 32),
            )
          ],
        ),
      ),
    );
  }
}