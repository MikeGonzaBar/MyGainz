import 'package:flutter/material.dart';
import '../../features/exercises/utils/equipment_options.dart';

/// Reusable equipment dropdown widget
/// Reduces code duplication across forms that need equipment selection
class EquipmentDropdown extends StatelessWidget {
  final String selectedEquipment;
  final ValueChanged<String> onChanged;
  final String? label;
  final bool enabled;
  final List<String>? customOptions;

  const EquipmentDropdown({
    super.key,
    required this.selectedEquipment,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.customOptions,
  });

  @override
  Widget build(BuildContext context) {
    final options = customOptions ?? EquipmentOptions.basic;

    // Ensure selected equipment is in options, or use first option
    final validSelectedEquipment = options.contains(selectedEquipment)
        ? selectedEquipment
        : options.isNotEmpty
            ? options.first
            : 'Barbell';

    return DropdownButtonFormField<String>(
      value: validSelectedEquipment,
      decoration: InputDecoration(
        labelText: label ?? 'Equipment',
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      items: options.map((equipment) {
        return DropdownMenuItem(
          value: equipment,
          child: Text(equipment),
        );
      }).toList(),
      onChanged: enabled
          ? (String? value) {
              if (value != null) onChanged(value);
            }
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select equipment';
        }
        return null;
      },
    );
  }
}

/// Compact version of equipment dropdown for use in dialogs or tight spaces
class CompactEquipmentDropdown extends StatelessWidget {
  final String selectedEquipment;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final List<String>? customOptions;

  const CompactEquipmentDropdown({
    super.key,
    required this.selectedEquipment,
    required this.onChanged,
    this.enabled = true,
    this.customOptions,
  });

  @override
  Widget build(BuildContext context) {
    final options = customOptions ?? EquipmentOptions.basic;

    // Ensure selected equipment is in options, or use first option
    final validSelectedEquipment = options.contains(selectedEquipment)
        ? selectedEquipment
        : options.isNotEmpty
            ? options.first
            : 'Barbell';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validSelectedEquipment,
          isExpanded: true,
          items: options.map((equipment) {
            return DropdownMenuItem(
              value: equipment,
              child: Text(
                equipment,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: enabled
              ? (String? value) {
                  if (value != null) onChanged(value);
                }
              : null,
          hint: const Text('Select Equipment'),
        ),
      ),
    );
  }
}

/// Equipment selection with chips for multiple selection
class MultiSelectEquipmentWidget extends StatelessWidget {
  final List<String> selectedEquipment;
  final ValueChanged<List<String>> onSelectionChanged;
  final String? label;
  final List<String>? customOptions;

  const MultiSelectEquipmentWidget({
    super.key,
    required this.selectedEquipment,
    required this.onSelectionChanged,
    this.label,
    this.customOptions,
  });

  @override
  Widget build(BuildContext context) {
    final options = customOptions ?? EquipmentOptions.basic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((equipment) {
            final isSelected = selectedEquipment.contains(equipment);
            return FilterChip(
              label: Text(equipment),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = List<String>.from(selectedEquipment);
                if (selected) {
                  newSelection.add(equipment);
                } else {
                  newSelection.remove(equipment);
                }
                onSelectionChanged(newSelection);
              },
              selectedColor: const Color(0xFF1B2027).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF1B2027),
            );
          }).toList(),
        ),
      ],
    );
  }
}
