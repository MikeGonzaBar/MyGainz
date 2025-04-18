import 'package:flutter/material.dart';

class MeasurementInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onUnitChanged;
  final String selectedUnit;
  final String measurementType; // "height" or "weight"

  const MeasurementInputField({
    super.key,
    required this.controller,
    required this.onUnitChanged,
    required this.selectedUnit,
    required this.measurementType,
  });

  List<String> get unitOptions {
    if (measurementType.toLowerCase() == 'weight') {
      return ['kg', 'lbs'];
    } else {
      return ['cm', 'm', 'ft', 'in'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeight = measurementType.toLowerCase() == 'weight';
    final label = isWeight ? 'Weight' : 'Height';
    final hint = isWeight ? 'Enter your weight' : 'Enter your height';
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,

        hintText: hint,
        suffixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedUnit,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onUnitChanged(newValue);
                }
              },
              items:
                  unitOptions.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
