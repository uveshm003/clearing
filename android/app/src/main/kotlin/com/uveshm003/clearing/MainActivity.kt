package com.uveshm003.clearing

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Receives text shared from other apps (FR-01) and hands it to Flutter, which
 * opens quick capture pre-filled with it.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pendingText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingText = sharedText(intent)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "takeSharedText" -> {
                        result.success(pendingText)
                        pendingText = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val text = sharedText(intent) ?: return
        channel?.invokeMethod("sharedText", text)
    }

    private fun sharedText(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") return null
        val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
        val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return subject
        return if (subject.isNullOrBlank() || text.contains(subject)) text else "$subject\n$text"
    }

    private companion object {
        const val CHANNEL = "clearing/share"
    }
}
