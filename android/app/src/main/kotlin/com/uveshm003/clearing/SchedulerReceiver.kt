package com.uveshm003.clearing

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

/**
 * Runs `backgroundSync()` from `lib/background.dart` in a headless Flutter
 * engine: series advance and reminders are reconciled even when the app
 * isn't open (PRD §8.3, §8.4).
 *
 * Triggered on boot, after an app update, on a time or time-zone change, and
 * by an alarm just after each local midnight, which it re-arms every run.
 */
class SchedulerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appContext = context.applicationContext
        scheduleMidnight(appContext)
        val pending = goAsync()
        val handler = Handler(Looper.getMainLooper())
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(appContext)
        loader.ensureInitializationCompleteAsync(appContext, null, handler) {
            val engine = FlutterEngine(appContext)
            var finished = false
            val finish = Runnable {
                if (finished) return@Runnable
                finished = true
                engine.destroy()
                pending.finish()
            }
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "done") {
                        result.success(null)
                        handler.post(finish)
                    } else {
                        result.notImplemented()
                    }
                }
            // Background broadcasts may run for up to a minute; stop well
            // before that even if Dart never reports back.
            handler.postDelayed(finish, TIMEOUT_MS)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    loader.findAppBundlePath(),
                    "package:clearing/background.dart",
                    "backgroundSync",
                ),
            )
        }
    }

    companion object {
        private const val CHANNEL = "clearing/background"
        private const val ACTION_MIDNIGHT = "com.uveshm003.clearing.MIDNIGHT"
        private const val TIMEOUT_MS = 30_000L

        /**
         * Arms an inexact alarm for one minute past the next local midnight.
         * Inexact is enough: nothing user-visible depends on the exact
         * minute, and it needs no special permission.
         */
        fun scheduleMidnight(context: Context) {
            val next = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 1)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val intent = Intent(context, SchedulerReceiver::class.java)
                .setAction(ACTION_MIDNIGHT)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            val alarms = context.getSystemService(AlarmManager::class.java)
            alarms.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                next.timeInMillis,
                pendingIntent,
            )
        }
    }
}
