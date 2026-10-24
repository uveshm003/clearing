package com.uveshm003.clearing

import android.app.Activity
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.SoundPool
import android.view.WindowManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Small things only the phone can do: a short chime on "all clear" and a
 * finished review (off unless asked for, and silent when the phone is), and
 * keeping the screen on in Focus.
 */
class DeviceChannel(
    private val context: Context,
    private val activity: () -> Activity?,
) {
    private val sounds = SoundPool.Builder()
        .setMaxStreams(1)
        .setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build(),
        )
        .build()
    private val clear = sounds.load(context, R.raw.chime_clear, 1)
    private val review = sounds.load(context, R.raw.chime_review, 1)

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "clearing/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "chime" -> {
                    val audio = context.getSystemService(AudioManager::class.java)
                    if (audio?.ringerMode == AudioManager.RINGER_MODE_NORMAL) {
                        val id = if (call.arguments == "review") review else clear
                        sounds.play(id, 0.6f, 0.6f, 1, 0, 1f)
                    }
                    result.success(null)
                }
                "keepScreenOn" -> {
                    val window = activity()?.window
                    if (call.arguments == true) {
                        window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window?.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
