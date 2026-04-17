package com.fitsmart.fitsmart_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class FitSmartWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.fitsmart_widget_small)
            val widgetData = HomeWidgetPlugin.getData(context)

            val remaining = widgetData.getInt("calories_remaining", 0)
            val pct = widgetData.getInt("calories_pct", 0)
            val streak = widgetData.getInt("streak_days", 0)
            val updatedAt = widgetData.getString("updated_at", "") ?: ""

            views.setProgressBar(R.id.widget_cal_ring, 100, pct, false)
            views.setTextViewText(R.id.widget_cal_remaining, "$remaining")
            views.setTextViewText(R.id.widget_streak,
                if (streak > 0) "$streak day streak 🔥" else "Start your streak!")
            views.setTextViewText(R.id.widget_updated_at, updatedAt)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
