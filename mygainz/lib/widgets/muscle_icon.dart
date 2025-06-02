import 'package:flutter/material.dart';

class MuscleIcon extends StatelessWidget {
  final String muscle;

  const MuscleIcon({
    super.key,
    required this.muscle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(_getAssetPath(), fit: BoxFit.contain),
          ),
          const SizedBox(height: 4),
          Text(
            muscle.length > 5 ? '${muscle.substring(0, 5)}...' : muscle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _getAssetPath() {
    // Map muscle name to corresponding asset path
    String assetPath = 'assets/icons/muscles/';

    // Normalize the muscle name for comparison
    String normalizedMuscle = muscle.toLowerCase();

    if (normalizedMuscle.contains('chest')) {
      assetPath += 'Chest.png';
    } else if (normalizedMuscle.contains('tricep')) {
      assetPath += 'Triceps.png';
    } else if (normalizedMuscle.contains('bicep')) {
      assetPath += 'Biceps.png';
    } else if (normalizedMuscle.contains('quad')) {
      assetPath += 'Thigh.png';
    } else if (normalizedMuscle.contains('hamstring')) {
      assetPath += 'Hamstrings.png';
    } else if (normalizedMuscle.contains('glute')) {
      assetPath += 'butt.png';
    } else if (normalizedMuscle.contains('shoulder') ||
        normalizedMuscle.contains('delt')) {
      assetPath += 'Shoulder.png';
    } else if (normalizedMuscle.contains('back')) {
      assetPath += 'Back.png';
    } else if (normalizedMuscle.contains('ab') ||
        normalizedMuscle.contains('core')) {
      assetPath += 'Abs.png';
    } else if (normalizedMuscle.contains('forearm')) {
      assetPath += 'Forearm.png';
    } else if (normalizedMuscle.contains('calf') ||
        normalizedMuscle.contains('calves')) {
      assetPath += 'Calves.png';
    } else {
      // Default to showing a generic icon if no match
      assetPath += 'Chest.png';
    }

    return assetPath;
  }
}
