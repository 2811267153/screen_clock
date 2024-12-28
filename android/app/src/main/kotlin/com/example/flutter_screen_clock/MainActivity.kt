package com.example.flutter_screen_clock

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.flutter_screen_clock/toast"
    private val CHANNELS = "com.example.flutter_screen_clock/lock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showToast") {
                val message = call.argument<String>("message")
                showToast(message)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun showToast(message: String?) {
        runOnUiThread {
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
        }
    }
}