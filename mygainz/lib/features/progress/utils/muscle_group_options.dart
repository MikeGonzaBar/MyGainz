// Consistent muscle group options used throughout the app
class MuscleGroupOptions {
  static const List<String> all = [
    'Chest',
    'Back',
    'Biceps',
    'Triceps',
    'Shoulders',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Abs',
    'Lower Back',
    'Obliques',
  ];

  // Core muscle groups (most commonly targeted)
  static const List<String> core = [
    'Chest',
    'Back',
    'Biceps',
    'Triceps',
    'Shoulders',
    'Quads',
  ];

  // Support for both individual and combined views
  static const List<String> withAll = [
    'All',
    ...all,
  ];
}
