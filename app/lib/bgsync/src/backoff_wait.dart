/// how long to wait after [failures] background fails in a row.
Duration backoffWait(int failures) {
  if (failures <= 0) return Duration.zero;
  if (failures == 1) return const Duration(minutes: 15);
  if (failures == 2) return const Duration(minutes: 30);
  return const Duration(hours: 1); // 3rd and later: 1 h forever
}
