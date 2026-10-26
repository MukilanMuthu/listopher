package com.gnomebyte.listopher.widget

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.os.Bundle
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

class WidgetConfigurationActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val widgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        val isNewWidget = intent.action == AppWidgetManager.ACTION_APPWIDGET_CONFIGURE
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val prefs = HomeWidgetPlugin.getData(this)
        val currentMode = prefs.getString("filter_mode_$widgetId", "all") ?: "all"
        val currentIds = ids(prefs.getString("filter_spaces_$widgetId", "[]"))
        val spaces = spaces(prefs.getString("listopher_snapshot", "{}") ?: "{}")
        val labels = listOf("All lists") + spaces.map { it.second }
        val checked = booleanArrayOf(currentMode == "all", *spaces.map { currentMode == "selected" && it.first in currentIds }.toBooleanArray())

        AlertDialog.Builder(this)
            .setTitle("Show lists")
            .setMultiChoiceItems(labels.toTypedArray(), checked) { dialog, index, selected ->
                if (index == 0 && selected) {
                    checked.indices.forEach { checked[it] = it == 0 }
                    (dialog as AlertDialog).listView?.let { view ->
                        for (row in 0 until view.count) view.setItemChecked(row, row == 0)
                    }
                } else if (index > 0 && selected) {
                    checked[0] = false
                    (dialog as AlertDialog).listView?.setItemChecked(0, false)
                }
            }
            .setNegativeButton("Cancel") { _, _ ->
                if (isNewWidget) setResult(RESULT_CANCELED)
                finish()
            }
            .setPositiveButton("Apply") { _, _ ->
                val ids = spaces.filterIndexed { index, _ -> checked[index + 1] }.map { it.first }
                val all = checked[0] || ids.isEmpty()
                prefs.edit()
                    .putString("filter_mode_$widgetId", if (all) "all" else "selected")
                    .putString("filter_spaces_$widgetId", JSONArray(ids).toString())
                    .apply()
                if (isNewWidget) {
                    setResult(RESULT_OK, intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId))
                }
                CoroutineScope(Dispatchers.Main).launch {
                    runCatching {
                        val glanceId = androidx.glance.appwidget.GlanceAppWidgetManager(this@WidgetConfigurationActivity)
                            .getGlanceIdBy(widgetId)
                        ListopherWidget().update(this@WidgetConfigurationActivity, glanceId)
                    }
                    finish()
                }
            }
            .setOnCancelListener {
                if (isNewWidget) setResult(RESULT_CANCELED)
                finish()
            }
            .show()
    }
}

private fun spaces(json: String): List<Pair<String, String>> = runCatching {
    val array = JSONObject(json).optJSONArray("spaces") ?: JSONArray()
    (0 until array.length()).mapNotNull { index ->
        val item = array.optJSONObject(index) ?: return@mapNotNull null
        val id = item.optString("id")
        if (id.isBlank()) null else id to if (item.optBoolean("private")) "Private" else item.optString("name", "List")
    }
}.getOrDefault(emptyList())

private fun ids(json: String?): Set<String> = runCatching {
    val array = JSONArray(json ?: "[]")
    (0 until array.length()).mapNotNull { array.optString(it).takeIf(String::isNotBlank) }.toSet()
}.getOrDefault(emptySet())
