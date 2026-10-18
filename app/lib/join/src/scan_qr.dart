import 'package:flutter/services.dart';

import 'scanner_unavailable.dart';

/// open the Android code scanner (Kotlin side, no camera permission).
/// returns the raw QR text, or null if the user cancelled.
/// throws ScannerUnavailable if the scanner itself failed.
Future<String?> scanQr() async {
  try {
    return await const MethodChannel('listopher/scan').invokeMethod<String>('scan');
  } on PlatformException {
    throw const ScannerUnavailable(); // Kotlin side reported an error
  }
}
