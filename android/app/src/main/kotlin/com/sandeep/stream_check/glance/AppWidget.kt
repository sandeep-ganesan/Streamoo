package com.sandeep.stream_check.glance

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Column
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import androidx.glance.layout.Alignment
import androidx.glance.layout.size
import androidx.glance.layout.Column

class AppWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = HomeWidgetPlugin.getData(context)
        val hasLive = prefs.getBoolean("hasLive", false)

        val label = if (hasLive) "Live" else "Offline"
        
        // FIX: ColorProvider needs a single color or (day, night)
        // We use the single color constructor here
        val textColor = if (hasLive)
            ColorProvider(Color.Red)
        else
            ColorProvider(Color.Black)

        val bg = ColorProvider(Color.White)

        provideContent {
            Content(label, textColor, bg)
        }
    }

    @Composable
private fun Content(label: String, textColor: ColorProvider, bg: ColorProvider) {
    // Define a square size, e.g., 100.dp x 100.dp
    val squareSize = 60.dp 

    Column(
        modifier = GlanceModifier
            .size(squareSize) // Sets both width and height to the same value
            .background(bg)
            .padding(8.dp),
        verticalAlignment = Alignment.CenterVertically, // Centers the text vertically
        horizontalAlignment = Alignment.CenterHorizontally // Centers the text horizontally
    ) {
        Text(
            text = label,
            style = TextStyle(
                color = textColor,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
        )
    }
}
    }