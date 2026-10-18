/// one or more spaces failed to sync. the rest did sync; [errors] has one entry per failure.
class SyncFailed implements Exception {
  final List<Object> errors;
  SyncFailed(this.errors);

  @override
  String toString() => 'sync failed for ${errors.length} space(s): $errors';
}
