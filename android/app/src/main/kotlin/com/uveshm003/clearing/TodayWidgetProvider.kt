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
 * The Today widget (FR-14): today's must-dos with a tap-to-complete check
 * mark. Dart writes the rows (`lib/data/home_widgets.dart`); the check mark
 * completes in the background through `onWidgetAction` in
 * `lib/background.dart`, without opening the app.
 */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val (rows, more) = parse(widgetData.getString(KEY, null))
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_today)
            views.setOnClickPendingIntent(R.id.header, launch(context, "clearing://today"))
            views.setOnClickPendingIntent(R.id.empty, launch(context, "clearing://today"))
            views.setViewVisibility(R.id.empty, if (rows.isEmpty()) View.VISIBLE else View.GONE)

            for (i in ROW_IDS.indices) {
                val row = rows.getOrNull(i)
                views.setViewVisibility(ROW_IDS[i], if (row == null) View.GONE else View.VISIBLE)
                if (row == null) continue
                val (id, title) = row
                views.setTextViewText(TITLE_IDS[i], title)
                views.setContentDescription(
                    CHECK_IDS[i],
                    context.getString(R.string.widget_mark_done, title),
                )
                views.setOnClickPendingIntent(
                    CHECK_IDS[i],
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("clearing://complete?id=${Uri.encode(id)}"),
                    ),
                )
                views.setOnClickPendingIntent(
                    TITLE_IDS[i],
                    launch(context, "clearing://item/${Uri.encode(id)}"),
                )
            }

            views.setViewVisibility(R.id.more, if (more > 0) View.VISIBLE else View.GONE)
            if (more > 0) {
                views.setTextViewText(
                    R.id.more,
                    context.resources.getQuantityString(R.plurals.widget_today_more, more, more),
                )
                views.setOnClickPendingIntent(R.id.more, launch(context, "clearing://today"))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun launch(context: Context, uri: String) =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(uri))

    /** Rows of (id, title) and the count of items not shown. */
    private fun parse(json: String?): Pair<List<Pair<String, String>>, Int> {
        if (json == null) return emptyList<Pair<String, String>>() to 0
        return try {
            val data = JSONObject(json)
            val rows = data.getJSONArray("rows")
            val parsed = (0 until rows.length()).map {
                val row = rows.getJSONObject(it)
                row.getString("id") to row.getString("title")
            }
            parsed to data.optInt("more", 0)
        } catch (e: JSONException) {
            emptyList<Pair<String, String>>() to 0
        }
    }

    private companion object {
        const val KEY = "today"
        val ROW_IDS = intArrayOf(R.id.row0, R.id.row1, R.id.row2, R.id.row3, R.id.row4)
        val CHECK_IDS = intArrayOf(R.id.check0, R.id.check1, R.id.check2, R.id.check3, R.id.check4)
        val TITLE_IDS = intArrayOf(R.id.title0, R.id.title1, R.id.title2, R.id.title3, R.id.title4)
    }
}
