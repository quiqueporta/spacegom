import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const DateField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'D/M/A',
        suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF8B949E)),
      ),
    );
  }
}
