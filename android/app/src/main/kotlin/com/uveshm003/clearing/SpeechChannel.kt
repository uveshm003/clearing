package com.uveshm003.clearing

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Voice capture (FR-01b) with Android's on-device recogniser only. Audio
 * never leaves the phone: where no on-device recogniser exists, capture
 * offers no microphone at all rather than fall back to the cloud.
 *
 * Each pause ends a phrase, sent as a final result; listening carries on
 * for the next one until the user stops or stays quiet.
 */
class SpeechChannel(
    private val context: Context,
    private val activity: () -> Activity?,
) : EventChannel.StreamHandler {
    private var recognizer: SpeechRecognizer? = null
    private var sink: EventChannel.EventSink? = null
    private var language = "en-IN"
    private var waitingForPermission = false

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "clearing/speech").setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(isAvailable())
                "stop" -> {
                    finish()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        EventChannel(messenger, "clearing/speech/events").setStreamHandler(this)
    }

    private fun isAvailable(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            SpeechRecognizer.isOnDeviceRecognitionAvailable(context)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        language = arguments as? String ?: language
        if (!isAvailable()) return fail("unavailable")
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            val activity = activity() ?: return fail("permission")
            waitingForPermission = true
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                REQUEST_AUDIO,
            )
            return
        }
        start()
    }

    /** Called by [MainActivity.onRequestPermissionsResult]. */
    fun onPermissionResult(requestCode: Int, granted: Boolean): Boolean {
        if (requestCode != REQUEST_AUDIO) return false
        if (!waitingForPermission) return true
        waitingForPermission = false
        if (granted) start() else fail("permission")
        return true
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        finish()
    }

    private fun start() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return fail("unavailable")
        val recognizer = recognizer ?: SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
            .also { it.setRecognitionListener(listener) }
        this.recognizer = recognizer
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
            .putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            .putExtra(RecognizerIntent.EXTRA_LANGUAGE, language)
            .putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            .putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
        recognizer.startListening(intent)
    }

    private fun finish() {
        recognizer?.destroy()
        recognizer = null
        sink?.success(mapOf("type" to "done"))
    }

    private fun fail(reason: String) {
        sink?.success(mapOf("type" to "error", "reason" to reason))
        recognizer?.destroy()
        recognizer = null
    }

    private val listener = object : RecognitionListener {
        override fun onReadyForSpeech(params: Bundle?) {}
        override fun onBeginningOfSpeech() {}
        override fun onRmsChanged(rmsdB: Float) {}
        override fun onBufferReceived(buffer: ByteArray?) {}
        override fun onEndOfSpeech() {}
        override fun onEvent(eventType: Int, params: Bundle?) {}

        override fun onPartialResults(partialResults: Bundle?) {
            val words = partialResults
                ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                ?.firstOrNull() ?: return
            sink?.success(mapOf("type" to "words", "text" to words, "final" to false))
        }

        override fun onResults(results: Bundle?) {
            val words = results
                ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                ?.firstOrNull()
            if (!words.isNullOrBlank()) {
                sink?.success(mapOf("type" to "words", "text" to words, "final" to true))
            }
            // Keep listening for the next phrase.
            if (sink != null) start()
        }

        override fun onError(error: Int) {
            when (error) {
                // Silence: the user has finished.
                SpeechRecognizer.ERROR_NO_MATCH,
                SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> finish()
                SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> fail("permission")
                else -> fail("error")
            }
        }
    }

    companion object {
        private const val REQUEST_AUDIO = 4418
    }
}
