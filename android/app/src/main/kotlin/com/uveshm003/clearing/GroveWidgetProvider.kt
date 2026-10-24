package com.uveshm003.clearing

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/**
 * The Grove widget (§6.3): the user's clearing as a picture on the home
 * screen. The app paints it whenever the Grove changes
 * (`lib/presentation/grove/grove_widget_sync.dart`); this only shows it.
 */
class GroveWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val path = widgetData.getString(KEY, null)
        val bitmap = path?.let { File(it) }?.takeIf { it.exists() }?.let {
            BitmapFactory.decodeFile(it.absolutePath)
        }
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_grove)
            if (bitmap != null) {
                views.setImageViewBitmap(R.id.grove_image, bitmap)
            } else {
                views.setImageViewResource(R.id.grove_image, R.drawable.ic_launcher_foreground)
            }
            views.setOnClickPendingIntent(
                R.id.grove_image,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("clearing://grove"),
                ),
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private companion object {
        const val KEY = "grove"
    }
}
