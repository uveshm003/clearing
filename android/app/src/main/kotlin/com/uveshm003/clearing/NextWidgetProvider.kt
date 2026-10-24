package com.uveshm003.clearing

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONException
import org.json.JSONObject

/**
 * The small "next thing" widget (2×1): the first of today's must-dos, or of
 * Today, with a check mark that completes it in the background. Reads the
 * same data as [TodayWidgetProvider].
 */
class NextWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val next = first(widgetData.getString(KEY, null))
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_next)
            if (next == null) {
                views.setViewVisibility(R.id.next_check, View.GONE)
                views.setTextViewText(R.id.next_title, context.getString(R.string.widget_today_empty))
                views.setOnClickPendingIntent(R.id.next_title, launch(context, "clearing://today"))
            } else {
                val (id, title) = next
                views.setViewVisibility(R.id.next_check, View.VISIBLE)
                views.setTextViewText(R.id.next_title, title)
                views.setContentDescription(
                    R.id.next_check,
                    context.getString(R.string.widget_mark_done, title),
                )
                views.setOnClickPendingIntent(
                    R.id.next_check,
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("clearing://complete?id=${Uri.encode(id)}"),
                    ),
                )
                views.setOnClickPendingIntent(
                    R.id.next_title,
                    launch(context, "clearing://item/${Uri.encode(id)}"),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun launch(context: Context, uri: String) =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(uri))

    private fun first(json: String?): Pair<String, String>? {
        if (json == null) return null
        return try {
            val rows = JSONObject(json).getJSONArray("rows")
            if (rows.length() == 0) return null
            val row = rows.getJSONObject(0)
            row.getString("id") to row.getString("title")
        } catch (e: JSONException) {
            null
        }
    }

    private companion object {
        const val KEY = "today"
    }
}
