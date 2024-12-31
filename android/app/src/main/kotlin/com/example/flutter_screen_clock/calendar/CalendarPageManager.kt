package com.example.flutter_screen_clock.calendar

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.util.TypedValue
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Calendar

class CalendarPageManager {
    fun createYearMonthView(context: Context): LinearLayout {
        val calendar = Calendar.getInstance()
        val currentYear = calendar.get(Calendar.YEAR)
        val currentMonth = calendar.get(Calendar.MONTH) + 1

        // 创建水平布局容器
        return LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.END or Gravity.CENTER_VERTICAL

            // 设置上下外边距
            val topMargin = (context.resources.displayMetrics.density * 30).toInt()
            val bottomMargin = (context.resources.displayMetrics.density * 20).toInt()
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, topMargin, 0, bottomMargin)
            }

            // 添加月份文本
            addView(TextView(context).apply {
                text = "${currentMonth}月"
                setTextSize(TypedValue.COMPLEX_UNIT_DIP, 30f)
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(0xFFFF4650.toInt())  // 修改为不透明的红色

                // 添加右边距
                val rightPadding = (context.resources.displayMetrics.density * 20).toInt()
                setPadding(0, 0, rightPadding, 0)
            })

            // 添加年份文本
            addView(TextView(context).apply {
                text = "${currentYear}年"
                setTextSize(TypedValue.COMPLEX_UNIT_DIP, 30f)
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(Color.argb(102, 255, 255, 255))  // 保持年份的半透明效果

                // 添加右边距
                val rightPadding = (context.resources.displayMetrics.density * 20).toInt()
                setPadding(0, 0, rightPadding, 0)
            })
        }
    }
} 