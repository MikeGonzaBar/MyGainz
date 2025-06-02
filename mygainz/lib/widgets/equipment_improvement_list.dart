import 'package:flutter/material.dart';

class EquipmentImprovementList extends StatelessWidget {
  final Map<String, double> equipmentImprovement;
  final String selectedMuscleGroup;

  const EquipmentImprovementList({
    super.key,
    required this.equipmentImprovement,
    required this.selectedMuscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    if (equipmentImprovement.isEmpty) {
      return const Text(
        'No equipment data available for the selected filters.',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedMuscleGroup != 'All Muscles') ...[
          Text(
            'Performance for $selectedMuscleGroup',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
        ],
        ...equipmentImprovement.entries.map(
          (entry) => EquipmentImprovementItem(
            equipment: entry.key,
            improvement: entry.value,
          ),
        ),
      ],
    );
  }
}

class EquipmentImprovementItem extends StatelessWidget {
  final String equipment;
  final double improvement;

  const EquipmentImprovementItem({
    super.key,
    required this.equipment,
    required this.improvement,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    switch (equipment) {
      case 'Dumbbell':
        dotColor = Colors.blue;
        break;
      case 'Barbell':
        dotColor = Colors.green;
        break;
      case 'Machine':
        dotColor = Colors.purple;
        break;
      case 'Kettlebell':
        dotColor = Colors.orange;
        break;
      default:
        dotColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              equipment,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)}%',
            style: TextStyle(
              color: improvement >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
