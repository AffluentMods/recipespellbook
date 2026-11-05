package com.affluentlabs.recipespellbook.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import com.affluentlabs.recipespellbook.R

/**
 * "Shopping list" home screen widget: the list the Shopping screen last
 * showed, how many items are left and the first of them. A tap anywhere
 * opens Shopping. The app redraws it whenever the list changes
 * (HomeWidgetService).
 */
class ShoppingListWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val shopping = WidgetSnapshot.shopping(context)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, views(context, appWidgetManager, id, shopping))
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        appWidgetManager.updateAppWidget(
            appWidgetId,
            views(context, appWidgetManager, appWidgetId, WidgetSnapshot.shopping(context)),
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // The fallback words come from string resources.
        if (intent.action == Intent.ACTION_LOCALE_CHANGED) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, ShoppingListWidgetProvider::class.java))
            if (ids.isNotEmpty()) onUpdate(context, manager, ids)
        }
    }

    private fun views(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        shopping: WidgetSnapshot.Shopping,
    ): RemoteViews = WidgetUi.sized(context, manager, widgetId) { width, height ->
        render(context, shopping, width, height)
    }

    private fun render(
        context: Context,
        shopping: WidgetSnapshot.Shopping,
        widthDp: Float,
        heightDp: Float,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_shopping_list)
        views.setTextViewText(
            R.id.widget_title,
            shopping.listName ?: shopping.title ?: context.getString(R.string.widget_shopping_title),
        )
        WidgetUi.fitHeader(views, R.id.widget_icon, R.id.widget_title, widthDp)
        views.setOnClickPendingIntent(android.R.id.background, WidgetUi.open(context, shopping.link))

        if (shopping.unchecked > 0) {
            views.setViewVisibility(R.id.widget_count, View.VISIBLE)
            views.setTextViewText(R.id.widget_count, shopping.unchecked.toString())
        } else {
            views.setViewVisibility(R.id.widget_count, View.GONE)
        }

        views.removeAllViews(R.id.widget_rows)
        if (shopping.items.isEmpty()) {
            views.setViewVisibility(R.id.widget_rows, View.GONE)
            views.setViewVisibility(R.id.widget_more, View.GONE)
            views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
            views.setTextViewText(
                R.id.widget_empty,
                shopping.emptyText ?: context.getString(R.string.widget_shopping_empty),
            )
            return views
        }

        val shown = WidgetUi.rowsThatFit(
            context,
            heightDp,
            rowDp = ROW_DP,
            listed = shopping.items.size,
            total = shopping.unchecked,
        )
        // Amounts only where the name still has room next to them.
        val showDetail = widthDp >= DETAIL_MIN_WIDTH_DP
        for (item in shopping.items.take(shown)) {
            val row = RemoteViews(context.packageName, R.layout.widget_shopping_row)
            row.setTextViewText(R.id.item_name, item.name)
            if (item.detail != null && showDetail) {
                row.setTextViewText(R.id.item_detail, item.detail)
                row.setViewVisibility(R.id.item_detail, View.VISIBLE)
            } else {
                row.setViewVisibility(R.id.item_detail, View.GONE)
            }
            views.addView(R.id.widget_rows, row)
        }

        views.setViewVisibility(R.id.widget_empty, View.GONE)
        views.setViewVisibility(R.id.widget_rows, if (shown > 0) View.VISIBLE else View.GONE)
        val hidden = shopping.unchecked - shown
        if (shown > 0 && hidden > 0) {
            views.setTextViewText(R.id.widget_more, "+$hidden")
            views.setViewVisibility(R.id.widget_more, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.widget_more, View.GONE)
        }
        return views
    }

    private companion object {
        // widget_shopping_row.xml: 24dp tall, no gap.
        const val ROW_DP = 24f

        const val DETAIL_MIN_WIDTH_DP = 180f
    }
}
