package com.sandeep.stream_check.glance

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class HomeWidgetReceiver : HomeWidgetGlanceWidgetReceiver<AppWidget>() {
    override val glanceAppWidget = AppWidget()
}
