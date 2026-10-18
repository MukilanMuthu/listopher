/// the QR scanner could not run (not cancelled: it broke). paste the link instead.
class ScannerUnavailable implements Exception {
  const ScannerUnavailable();

  @override
  String toString() => 'scanner unavailable';
}
