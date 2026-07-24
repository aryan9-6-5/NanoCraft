import 'package:hive/hive.dart';

class DraftService {
  static const String boxName = 'drafts_box';
  static const String latestDraftKey = 'latest_draft';

  /// Persists draft configuration to the Hive drafts box.
  Future<void> saveDraft(Map<String, dynamic> draftMap) async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    await box.put(latestDraftKey, draftMap);
  }

  /// Retrieves the latest saved draft from the Hive drafts box, if it exists.
  Future<Map<String, dynamic>?> loadLatestDraft() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    final raw = box.get(latestDraftKey);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  /// Clears out the current draft.
  Future<void> clearDraft() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    await box.delete(latestDraftKey);
  }

  /// Checks if any draft exists in the local Hive storage.
  Future<bool> hasDraft() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    return box.containsKey(latestDraftKey);
  }
}
