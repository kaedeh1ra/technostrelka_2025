import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final String placeholder;
  final double borderRadius;
  final TextEditingController? controller;

  const TextInput({
    super.key,
    required this.placeholder,
    required this.borderRadius,
    this.controller,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorHeight: 12,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
