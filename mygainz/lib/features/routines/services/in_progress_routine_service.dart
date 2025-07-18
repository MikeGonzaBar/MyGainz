import 'package:hive/hive.dart';
import 'package:mygainz/features/routines/models/in_progress_routine.dart';

class InProgressRoutineService {
  static const String _boxName = 'in_progress_routine_box';
  static const String _draftKey = 'draft_routine';

  // Open the Hive box (should be awaited before use)
  static Future<Box<InProgressRoutine>> openBox() async {
    return await Hive.openBox<InProgressRoutine>(_boxName);
  }

  // Save or update the in-progress routine
  static Future<void> saveDraft(InProgressRoutine routine) async {
    final box = await openBox();
    await box.put(_draftKey, routine);
  }

  // Load the in-progress routine, or null if none exists
  static Future<InProgressRoutine?> loadDraft() async {
    final box = await openBox();
    return box.get(_draftKey);
  }

  // Delete the in-progress routine draft
  static Future<void> deleteDraft() async {
    final box = await openBox();
    await box.delete(_draftKey);
  }

  // Check if a draft exists
  static Future<bool> hasDraft() async {
    final box = await openBox();
    return box.containsKey(_draftKey);
  }
}
