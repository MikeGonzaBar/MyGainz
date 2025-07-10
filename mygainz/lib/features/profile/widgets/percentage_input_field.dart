import 'package:flutter/material.dart';

class BodyCompInputField extends StatelessWidget {
  final TextEditingController controller;
  final String measurementType; // "height" or "weight"

  const BodyCompInputField({
    super.key,
    required this.controller,
    required this.measurementType,
  });

  @override
  Widget build(BuildContext context) {
    final isWeight = measurementType.toLowerCase() == 'fat';
    final label = isWeight ? 'Fat' : 'Muscle';
    final hint =
        isWeight ? 'Enter your fat percentage' : 'Enter your muscle percentage';

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffix: Text("%"),
      ),
    );
  }
}
