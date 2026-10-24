package com.uveshm003.clearing

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Receives text shared from other apps (FR-01) and hands it to Flutter, which
 * opens quick capture pre-filled with it. Also hosts the folder picker,
 * on-device speech and the small device channels.
 *
 * A fragment activity, as the app lock's biometric prompt needs one.
 */
class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null
    private var pendingText: String? = null
    private var folders: FolderChannel? = null
    private var speech: SpeechChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Arms the nightly series advance on first launch, before any reboot.
        SchedulerReceiver.scheduleMidnight(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        folders = FolderChannel(applicationContext) { this }.also { it.register(messenger) }
        speech = SpeechChannel(applicationContext) { this }.also { it.register(messenger) }
        DeviceChannel(applicationContext) { this }.register(messenger)
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

    @Deprecated("Needed for the folder picker's result")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (folders?.onActivityResult(requestCode, resultCode, data) == true) return
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        if (speech?.onPermissionResult(requestCode, granted) == true) return
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
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
