package com.gnomebyte.listopher

import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.codescanner.GmsBarcodeScannerOptions
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // channel "listopher/scan": method "scan" -> raw QR string, or null on cancel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "listopher/scan")
            .setMethodCallHandler { _, result ->
                // QR only
                val options = GmsBarcodeScannerOptions.Builder()
                    .setBarcodeFormats(Barcode.FORMAT_QR_CODE)
                    .build()
                GmsBarcodeScanning.getClient(this, options).startScan()
                    .addOnSuccessListener { result.success(it.rawValue) }
                    // cancel and scanner errors both mean "no link"
                    .addOnCanceledListener { result.success(null) }
                    .addOnFailureListener { result.success(null) }
            }
    }
}
