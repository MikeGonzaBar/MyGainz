class Routine {
  final String id; // Document ID
  final String userId;
  final String name;
  final bool orderIsRequired;
  final List<String> exerciseIds; // References to exercise document IDs

  Routine({
    required this.id,
    required this.userId,
    required this.name,
    required this.orderIsRequired,
    required this.exerciseIds,
  });
}
