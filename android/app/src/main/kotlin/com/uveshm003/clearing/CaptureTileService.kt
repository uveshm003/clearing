package com.uveshm003.clearing

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.service.quicksettings.TileService

/**
 * The "Capture" Quick Settings tile: one swipe down and a tap opens quick
 * capture, once the phone is unlocked.
 */
class CaptureTileService : TileService() {
    @SuppressLint("StartActivityAndCollapseDeprecated")
    override fun onClick() {
        super.onClick()
        val intent = Intent(this, MainActivity::class.java)
            .setAction(LAUNCH)
            .setData(Uri.parse("clearing://capture?from=tile"))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val open = Runnable {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startActivityAndCollapse(
                    PendingIntent.getActivity(
                        this,
                        0,
                        intent,
                        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                    ),
                )
            } else {
                @Suppress("DEPRECATION")
                startActivityAndCollapse(intent)
            }
        }
        if (isLocked) unlockAndRun(open) else open.run()
    }

    private companion object {
        const val LAUNCH = "es.antonborri.home_widget.action.LAUNCH"
    }
}
