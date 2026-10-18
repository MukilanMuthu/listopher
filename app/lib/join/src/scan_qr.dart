import 'package:flutter/services.dart';

/// open the Android code scanner (Kotlin side, no camera permission).
/// returns the raw QR text, or null if the user cancelled.
Future<String?> scanQr() =>
    const MethodChannel('listopher/scan').invokeMethod<String>('scan');
