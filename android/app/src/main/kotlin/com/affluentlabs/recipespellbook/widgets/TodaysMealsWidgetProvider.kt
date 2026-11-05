package com.affluentlabs.recipespellbook.widgets

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import com.affluentlabs.recipespellbook.R
import java.util.Calendar

/**
 * "Today's meals" home screen widget: the meals planned for today in the
 * order of the day. A meal opens its recipe, anything else opens the planner.
 *
 * The app redraws it whenever meals change (HomeWidgetService). The snapshot
 * also holds the coming days, so at midnight an alarm (inexact, it waits for
 * the phone to wake) turns the page without the app.
 */
class TodaysMealsWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val meals = WidgetSnapshot.meals(context)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, views(context, appWidgetManager, id, meals))
        }
        scheduleMidnightRefresh(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        appWidgetManager.updateAppWidget(
            appWidgetId,
            views(context, appWidgetManager, appWidgetId, WidgetSnapshot.meals(context)),
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_MIDNIGHT_REFRESH,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_LOCALE_CHANGED,
            -> refreshAll(context)
        }
    }

    override fun onDisabled(context: Context) {
        context.getSystemService(AlarmManager::class.java)?.cancel(midnightIntent(context))
    }

    private fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, TodaysMealsWidgetProvider::class.java))
        if (ids.isNotEmpty()) onUpdate(context, manager, ids)
    }

    private fun views(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        meals: WidgetSnapshot.Meals,
    ): RemoteViews = WidgetUi.sized(context, manager, widgetId) { width, height ->
        render(context, meals, width, height)
    }

    private fun render(context: Context, meals: WidgetSnapshot.Meals, widthDp: Float, heightDp: Float): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_todays_meals)
        views.setTextViewText(R.id.widget_title, meals.title ?: context.getString(R.string.widget_meals_title))
        WidgetUi.fitHeader(views, R.id.widget_icon, R.id.widget_title, widthDp)
        // The heading and any empty space open the planner.
        views.setOnClickPendingIntent(android.R.id.background, WidgetUi.open(context, meals.link))

        if (meals.total > 0) {
            views.setViewVisibility(R.id.widget_count, View.VISIBLE)
            views.setTextViewText(R.id.widget_count, meals.total.toString())
        } else {
            views.setViewVisibility(R.id.widget_count, View.GONE)
        }

        views.removeAllViews(R.id.widget_rows)
        if (meals.items.isEmpty()) {
            views.setViewVisibility(R.id.widget_rows, View.GONE)
            views.setViewVisibility(R.id.widget_more, View.GONE)
            views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
            views.setTextViewText(R.id.widget_empty, meals.emptyText ?: context.getString(R.string.widget_meals_empty))
            return views
        }

        val shown = WidgetUi.rowsThatFit(
            context,
            heightDp,
            rowDp = ROW_DP,
            listed = meals.items.size,
            total = meals.total,
        )
        // The meal type pill only where the title still has room next to it.
        val showType = widthDp >= TYPE_MIN_WIDTH_DP
        for (meal in meals.items.take(shown)) {
            val row = RemoteViews(context.packageName, R.layout.widget_meal_row)
            row.setTextViewText(R.id.meal_title, meal.title)
            if (meal.typeLabel != null && showType) {
                row.setTextViewText(R.id.meal_type, meal.typeLabel)
                row.setViewVisibility(R.id.meal_type, View.VISIBLE)
            } else {
                row.setViewVisibility(R.id.meal_type, View.GONE)
            }
            val time = WidgetUi.formatTime(context, meal.time)
            if (time != null) {
                row.setTextViewText(R.id.meal_time, time)
                row.setViewVisibility(R.id.meal_time, View.VISIBLE)
            } else {
                row.setViewVisibility(R.id.meal_time, View.GONE)
            }
            row.setOnClickPendingIntent(R.id.meal_row, WidgetUi.open(context, meal.link))
            views.addView(R.id.widget_rows, row)
        }

        views.setViewVisibility(R.id.widget_empty, View.GONE)
        views.setViewVisibility(R.id.widget_rows, if (shown > 0) View.VISIBLE else View.GONE)
        val hidden = meals.total - shown
        if (shown > 0 && hidden > 0) {
            views.setTextViewText(R.id.widget_more, "+$hidden")
            views.setViewVisibility(R.id.widget_more, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.widget_more, View.GONE)
        }
        return views
    }

    private fun scheduleMidnightRefresh(context: Context) {
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        val nextDay = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 5)
            set(Calendar.MILLISECOND, 0)
        }
        // Inexact and not waking the phone: the new day shows the next time
        // the phone is in use, which is when the widget can be seen anyway.
        alarms.set(AlarmManager.RTC, nextDay.timeInMillis, midnightIntent(context))
    }

    private fun midnightIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
        context,
        0,
        Intent(context, TodaysMealsWidgetProvider::class.java).setAction(ACTION_MIDNIGHT_REFRESH),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private companion object {
        const val ACTION_MIDNIGHT_REFRESH = "com.affluentlabs.recipespellbook.widgets.MIDNIGHT_REFRESH"

        // widget_meal_row.xml: 30dp tall with 3dp above it.
        const val ROW_DP = 33f

        const val TYPE_MIN_WIDTH_DP = 260f
    }
}
