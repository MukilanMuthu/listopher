/// wrap [job] so two runs never overlap.
/// called while running: mark "again" and hand back the running future;
/// the job runs once more right after it finishes. many calls mid-run = one rerun.
/// a failed run throws to its callers; the last run's result is the result.
/// ponytail: a caller that joins a running job gets that future, which ends with the rerun.
Future<void> Function() oneAtATime(Future<void> Function() job) {
  Future<void>? running; // null = idle
  var again = false; // asked while busy

  // run, then rerun while asked
  Future<void> loop() async {
    try {
      Object? error;
      StackTrace? trace;
      do {
        again = false;
        error = null;
        try {
          await job();
        } catch (e, s) {
          error = e;
          trace = s;
        }
      } while (again);
      if (error != null) Error.throwWithStackTrace(error, trace!);
    } finally {
      running = null; // idle again, even on error
    }
  }

  return () {
    if (running != null) {
      again = true;
      return running!;
    }
    return running = loop();
  };
}
