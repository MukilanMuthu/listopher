package com.gnomebyte.listopher.widget

import android.content.Context
import android.content.res.Configuration
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ExperimentalGlanceApi
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.CheckBox
import androidx.glance.appwidget.CheckboxDefaults
import androidx.glance.appwidget.action.actionStartActivity as startConfigurationActivity
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.Text
import androidx.glance.text.FontWeight
import androidx.glance.text.TextDecoration
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.semantics.contentDescription
import androidx.glance.semantics.semantics
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import es.antonborri.home_widget.actionStartActivity
import com.gnomebyte.listopher.MainActivity
import org.json.JSONArray
import org.json.JSONObject

private val uriParameter = ActionParameters.Key<String>("widget_uri")

class ListopherWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)
        provideContent { WidgetContent(context, appWidgetId, currentState()) }
    }
}

class ListopherWidgetReceiver : HomeWidgetGlanceWidgetReceiver<ListopherWidget>() {
    override val glanceAppWidget = ListopherWidget()
}

@Composable
@OptIn(ExperimentalGlanceApi::class)
private fun WidgetContent(context: Context, widgetId: Int, state: HomeWidgetGlanceState) {
    val prefs = state.preferences
    val dark = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
    val foreground = if (dark) Color.White else Color(0xFF202124)
    val muted = if (dark) Color(0xFFB8BBC2) else Color(0xFF5F6368)
    val background = if (dark) Color(0xFF202124) else Color(0xFFF8F9FA)
    val error = if (dark) Color(0xFFFFB4AB) else Color(0xFFB3261E)
    val mode = prefs.getString("filter_mode_$widgetId", "all") ?: "all"
    val selected = jsonIds(prefs.getString("filter_spaces_$widgetId", "[]"))
    val lists = jsonLists(prefs.getString("listopher_snapshot", "{}") ?: "{}")
        .filter { mode == "all" || it.id in selected }
    val filterLabel = when {
        mode == "all" -> "All lists ▾"
        lists.size == 1 -> "1 list ▾"
        else -> "${lists.size} lists ▾"
    }
    val configure = Intent(context, WidgetConfigurationActivity::class.java)
        .putExtra(android.appwidget.AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)

    Column(
        modifier = GlanceModifier.fillMaxSize().background(background).padding(12.dp),
    ) {
        Row(
            modifier = GlanceModifier.fillMaxWidth().padding(bottom = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text("Listopher", style = TextStyle(color = ColorProvider(foreground), fontSize = 16.sp, fontWeight = FontWeight.Bold))
            Spacer(GlanceModifier.defaultWeight())
            Text(filterLabel, modifier = GlanceModifier.clickable(startConfigurationActivity(configure)).padding(horizontal = 8.dp, vertical = 8.dp), style = TextStyle(color = ColorProvider(muted), fontSize = 12.sp))
            Text("Sync", modifier = GlanceModifier.clickable(actionRunCallback<WidgetBackgroundAction>(actionParametersOf(uriParameter to "listopher://sync"))).padding(horizontal = 8.dp, vertical = 8.dp), style = TextStyle(color = ColorProvider(foreground), fontSize = 12.sp, fontWeight = FontWeight.Medium))
        }
        if (prefs.getBoolean("listopher_sync_failed", false)) {
            Text("Sync failed · tap to retry", modifier = GlanceModifier.fillMaxWidth().clickable(actionRunCallback<WidgetBackgroundAction>(actionParametersOf(uriParameter to "listopher://sync"))).padding(vertical = 4.dp), style = TextStyle(color = ColorProvider(error), fontSize = 12.sp))
        }
        LazyColumn(modifier = GlanceModifier.defaultWeight()) {
            if (lists.isEmpty()) {
                item(itemId = stableId("empty")) {
                    Text(
                        if (mode == "selected") "No selected lists. Use Lists to choose." else "No lists yet.",
                        modifier = GlanceModifier.padding(top = 12.dp),
                        style = TextStyle(color = ColorProvider(muted), fontSize = 13.sp),
                    )
                }
            }
            lists.forEach { list ->
                item(itemId = stableId("heading:${list.id}")) {
                    Text(if (list.isPrivate) "Private" else list.name, modifier = GlanceModifier.fillMaxWidth().padding(top = 8.dp, bottom = 3.dp), style = TextStyle(color = ColorProvider(foreground), fontSize = 14.sp, fontWeight = FontWeight.Bold))
                }
                items(list.items, itemId = { stableId("${list.id}:${it.id}") }) { item ->
                    val checkUri = "listopher://check?space=${Uri.encode(list.id)}&item=${Uri.encode(item.id)}"
                    val rowUri = "listopher://space?id=${Uri.encode(list.id)}"
                    Row(modifier = GlanceModifier.fillMaxWidth().padding(vertical = 2.dp), verticalAlignment = Alignment.CenterVertically) {
                        CheckBox(
                            checked = item.checked,
                            onCheckedChange = {
                                HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(checkUri)).send()
                            },
                            modifier = GlanceModifier.size(48.dp).semantics { contentDescription = item.name },
                            colors = CheckboxDefaults.colors(
                                checkedColor = if (dark) Color(0xFFB8BBC2) else Color(0xFF202124),
                                uncheckedColor = if (dark) Color.White else Color(0xFF202124),
                            ),
                        )
                        Spacer(GlanceModifier.width(6.dp))
                        Column(modifier = GlanceModifier.defaultWeight().clickable(actionStartActivity<MainActivity>(context, Uri.parse(rowUri))).padding(vertical = 14.dp)) {
                            Text(item.name, style = TextStyle(color = ColorProvider(if (item.checked) muted else foreground), fontSize = 13.sp, textDecoration = if (item.checked) TextDecoration.LineThrough else TextDecoration.None))
                        }
                        if (item.quantity.isNotBlank() || item.unit.isNotBlank()) {
                            Text("${item.quantity}${if (item.unit.isNotBlank()) " ${item.unit}" else ""}", style = TextStyle(color = ColorProvider(muted), fontSize = 12.sp))
                        }
                    }
                }
            }
        }
    }
}

class WidgetBackgroundAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val uri = parameters[uriParameter] ?: return
        HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(uri)).send()
    }
}

private data class WidgetList(val id: String, val name: String, val isPrivate: Boolean, val items: List<WidgetItem>)
private data class WidgetItem(val id: String, val name: String, val quantity: String, val unit: String, val checked: Boolean)

private fun stableId(value: String): Long = value.hashCode().toLong()

private fun jsonLists(json: String): List<WidgetList> = runCatching {
    val spaces = JSONObject(json).optJSONArray("spaces") ?: JSONArray()
    (0 until spaces.length()).mapNotNull { index ->
        val space = spaces.optJSONObject(index) ?: return@mapNotNull null
        val items = space.optJSONArray("items") ?: JSONArray()
        WidgetList(
            space.optString("id"), space.optString("name"), space.optBoolean("private"),
            (0 until items.length()).mapNotNull { itemIndex ->
                val item = items.optJSONObject(itemIndex) ?: return@mapNotNull null
                WidgetItem(item.optString("id"), item.optString("name"), formatQuantity(item.optString("quantity")), item.optString("unit").takeUnless { it == "null" } ?: "", item.optBoolean("checked"))
            },
        )
    }
}.getOrDefault(emptyList())

private fun formatQuantity(value: String): String {
    val number = value.toDoubleOrNull() ?: return value.takeUnless { it == "null" } ?: ""
    return if (number.isFinite() && number % 1.0 == 0.0) number.toLong().toString() else value
}

private fun jsonIds(json: String?): Set<String> = runCatching {
    val ids = JSONArray(json ?: "[]")
    (0 until ids.length()).mapNotNull { ids.optString(it).takeIf(String::isNotBlank) }.toSet()
}.getOrDefault(emptySet())
