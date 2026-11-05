package com.affluentlabs.recipespellbook.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.text.format.DateFormat
import android.util.SizeF
import android.util.TypedValue
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import com.affluentlabs.recipespellbook.MainActivity
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import java.util.Calendar
import kotlin.math.floor

/** What both widgets share: tap intents, sizing and time formatting. */
internal object WidgetUi {

    /**
     * Opens the app on [link]. The link reaches Flutter through app_links like
     * any recipespellbook:// link, and lib/utils/widget_links.dart routes it.
     */
    fun open(context: Context, link: String): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(link))

    /**
     * The widget's views for every size the launcher may show it at (Android
     * 12 and newer pick the right one themselves, e.g. on rotation), or for
     * the current size on older versions. [build] gets the size in dp.
     */
    fun sized(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        build: (widthDp: Float, heightDp: Float) -> RemoteViews,
    ): RemoteViews {
        val options = manager.getAppWidgetOptions(widgetId)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val sizes = sizesOf(options).distinct()
            if (sizes.isNotEmpty()) {
                return RemoteViews(sizes.associateWith { build(it.width, it.height) })
            }
        }
        val portrait = context.resources.configuration.orientation != Configuration.ORIENTATION_LANDSCAPE
        val width = options.getInt(
            if (portrait) AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH else AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH,
        )
        val height = options.getInt(
            if (portrait) AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT else AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT,
        )
        return build(
            if (width > 0) width.toFloat() else DEFAULT_WIDTH_DP,
            if (height > 0) height.toFloat() else DEFAULT_HEIGHT_DP,
        )
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun sizesOf(options: Bundle): List<SizeF> =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            options.getParcelableArrayList(AppWidgetManager.OPTION_APPWIDGET_SIZES, SizeF::class.java)
        } else {
            @Suppress("DEPRECATION")
            options.getParcelableArrayList(AppWidgetManager.OPTION_APPWIDGET_SIZES)
        } ?: emptyList()

    /**
     * How many of [listed] rows (each [rowDp] tall, its margin included) fit
     * in a widget [heightDp] tall. When some rows stay hidden ([total] counts
     * every row, also those that were not listed) room is kept for the "+N"
     * line under them. Heights are in dp at the default font size and grow
     * with the user's font scale.
     */
    fun rowsThatFit(
        context: Context,
        heightDp: Float,
        rowDp: Float,
        listed: Int,
        total: Int,
    ): Int {
        if (listed <= 0) return 0
        val scale = maxOf(1f, context.resources.configuration.fontScale)
        val row = rowDp * scale
        val space = heightDp - PADDING_DP - HEADER_DP * scale - ROWS_TOP_DP
        fun count(available: Float): Int = if (available < row) 0 else floor(available / row).toInt()

        if (total <= listed && count(space) >= listed) return listed
        return minOf(listed, count(space - MORE_DP * scale))
    }

    /** "HH:mm" in the phone's own time format (12 or 24 hours), or null. */
    fun formatTime(context: Context, hhmm: String?): String? {
        val parts = hhmm?.split(":") ?: return null
        val hour = parts.getOrNull(0)?.toIntOrNull() ?: return null
        val minute = parts.getOrNull(1)?.toIntOrNull() ?: return null
        if (hour !in 0..23 || minute !in 0..59) return null
        val time = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
        }
        return DateFormat.getTimeFormat(context).format(time.time)
    }

    // Sizes in dp, matching the layouts (widget_todays_meals.xml and friends).
    private const val PADDING_DP = 24f // 12dp top + 12dp bottom
    private const val HEADER_DP = 24f
    private const val ROWS_TOP_DP = 4f // widget_rows' top margin
    private const val MORE_DP = 18f
    private const val DEFAULT_WIDTH_DP = 180f
    private const val DEFAULT_HEIGHT_DP = 110f

    /** Narrower than this (2 cells on small phones), the heading is compacted. */
    private const val COMPACT_HEADER_DP = 160f

    /**
     * On a narrow widget the heading drops its icon and uses a smaller title,
     * so a name like "Shopping list" still fits next to the count.
     */
    fun fitHeader(views: RemoteViews, iconId: Int, titleId: Int, widthDp: Float) {
        val compact = widthDp < COMPACT_HEADER_DP
        views.setViewVisibility(iconId, if (compact) android.view.View.GONE else android.view.View.VISIBLE)
        views.setTextViewTextSize(titleId, TypedValue.COMPLEX_UNIT_SP, if (compact) 13f else 15f)
    }
}
