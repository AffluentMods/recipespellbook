package com.affluentlabs.recipespellbook.widgets

import android.content.Context
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar
import java.util.Locale

/**
 * Reads the snapshot the app writes for the home screen widgets
 * (lib/services/home_widget_snapshot.dart, saved through home_widget into its
 * "HomeWidgetPreferences" SharedPreferences). The widgets only read it; the
 * app is the only writer.
 *
 * Words the app wrote (titles, empty states, meal types) are in the app's
 * language. Until the app has written a snapshot the widgets fall back to
 * their own string resources.
 */
internal object WidgetSnapshot {
    /** Must match homeWidgetSnapshotKey in home_widget_snapshot.dart. */
    private const val KEY = "rsb_widget_snapshot"

    const val SHOPPING_LINK = "recipespellbook://shopping"
    const val PLANNER_LINK = "recipespellbook://planner"

    data class Meal(
        val title: String,
        val typeLabel: String?,
        /** "HH:mm", or null when the meal has no clock time. */
        val time: String?,
        val link: String,
    )

    data class Meals(
        val title: String?,
        val emptyText: String?,
        /** Today's meals in the order of the day (at most 8). */
        val items: List<Meal>,
        /** All of today's meals, including those not in [items]. */
        val total: Int,
        val link: String,
    )

    data class Item(val name: String, val detail: String?)

    data class Shopping(
        /** Fallback heading when the list has no name. */
        val title: String?,
        val emptyText: String?,
        val listName: String?,
        val unchecked: Int,
        /** The first unchecked items (at most 8). */
        val items: List<Item>,
        val link: String,
    )

    fun meals(context: Context, today: Calendar = Calendar.getInstance()): Meals {
        val root = read(context)
        val labels = root?.optJSONObject("labels")
        val meals = root?.optJSONObject("meals")
        val day = meals?.optJSONObject("days")?.optJSONObject(dayKey(today))
        val items = day?.optJSONArray("items").objects().mapNotNull { m ->
            val title = m.text("title") ?: return@mapNotNull null
            Meal(
                title = title,
                typeLabel = m.text("typeLabel") ?: m.text("type"),
                time = m.text("time"),
                link = m.text("link") ?: PLANNER_LINK,
            )
        }
        return Meals(
            title = labels?.text("mealsTitle"),
            emptyText = labels?.text("mealsEmpty"),
            items = items,
            total = maxOf(day?.optInt("total", items.size) ?: 0, items.size),
            link = meals?.text("link") ?: PLANNER_LINK,
        )
    }

    fun shopping(context: Context): Shopping {
        val root = read(context)
        val labels = root?.optJSONObject("labels")
        val shopping = root?.optJSONObject("shopping")
        val items = shopping?.optJSONArray("items").objects().mapNotNull { i ->
            val name = i.text("name") ?: return@mapNotNull null
            Item(name, i.text("detail"))
        }
        return Shopping(
            title = labels?.text("shoppingTitle"),
            emptyText = labels?.text("shoppingEmpty"),
            listName = shopping?.text("name"),
            unchecked = maxOf(shopping?.optInt("unchecked", items.size) ?: 0, items.size),
            items = items,
            link = shopping?.text("link") ?: SHOPPING_LINK,
        )
    }

    /** "yyyy-MM-dd" of [day], the key of the snapshot's meals by day. */
    fun dayKey(day: Calendar): String = String.format(
        Locale.US,
        "%04d-%02d-%02d",
        day.get(Calendar.YEAR),
        day.get(Calendar.MONTH) + 1,
        day.get(Calendar.DAY_OF_MONTH),
    )

    private fun read(context: Context): JSONObject? {
        val raw = HomeWidgetPlugin.getData(context).getString(KEY, null) ?: return null
        return try {
            JSONObject(raw)
        } catch (e: Exception) {
            null
        }
    }

    private fun JSONArray?.objects(): List<JSONObject> =
        if (this == null) emptyList() else (0 until length()).mapNotNull { optJSONObject(it) }

    /** Trimmed, non-empty string at [key], or null (also for JSON null). */
    private fun JSONObject.text(key: String): String? =
        if (isNull(key)) null else optString(key).trim().takeIf { it.isNotEmpty() }
}
