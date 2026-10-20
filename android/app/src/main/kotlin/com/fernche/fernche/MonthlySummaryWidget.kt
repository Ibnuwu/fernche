package com.fernche.fernche

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class MonthlySummaryWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_monthly_summary).apply {
                val income = widgetData.getString("monthly_income", "Rp 0")
                val expense = widgetData.getString("monthly_expense", "Rp 0")
                val balance = widgetData.getString("monthly_balance", "Rp 0")
                val sign = widgetData.getString("balance_sign", "+")

                setTextViewText(R.id.widget_income, income)
                setTextViewText(R.id.widget_expense, expense)
                setTextViewText(R.id.widget_balance, "${if (sign == "-") "- " else ""}Rp ${balance?.replace("Rp ", "") ?: "0"}")

                if (sign == "-") {
                    setTextColor(R.id.widget_balance, Color.parseColor("#EF5350"))
                } else {
                    setTextColor(R.id.widget_balance, Color.parseColor("#00C853"))
                }
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
