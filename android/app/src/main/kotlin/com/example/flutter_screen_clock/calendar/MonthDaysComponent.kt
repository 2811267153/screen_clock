package com.example.flutter_screen_clock.calendar

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.GridLayout
import android.widget.TextView
import java.util.Calendar

class MonthDaysComponent @JvmOverloads constructor(
    context: Context, 
    attrs: AttributeSet? = null
) : GridLayout(context, attrs) {

    init {
        Log.d("MonthDaysComponent", "Initializing")
        rowCount = 6
        columnCount = 7
        useDefaultMargins = false
        alignmentMode = ALIGN_BOUNDS

        // 移除调试用的背景色
        // setBackgroundColor(Color.parseColor("#80000000"))

        post { setupCalendar() }
    }

    private fun setupCalendar() {
        removeAllViews()
        
        val calendar = Calendar.getInstance()
        val currentDay = calendar.get(Calendar.DAY_OF_MONTH)

        calendar.set(Calendar.DAY_OF_MONTH, 1)
        val firstDayOfWeek = calendar.get(Calendar.DAY_OF_WEEK) - 1
        val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)

        // 填充空白天数
        for (i in 0 until firstDayOfWeek) {
            addDayView("")
        }

        // 填充日期
        for (day in 1..daysInMonth) {
            calendar.set(Calendar.DAY_OF_MONTH, day)
            val dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)
            addDayView(day.toString(), day == currentDay, dayOfWeek)
        }
    }

    private fun addDayView(text: String, isToday: Boolean = false, dayOfWeek: Int = -1) {
        val container = FrameLayout(context).apply {
            layoutParams = LayoutParams().apply {
                width = 0
                height = 0
                setMargins(4, 4, 4, 4)
                columnSpec = spec(GridLayout.UNDEFINED, 1f)
                rowSpec = spec(GridLayout.UNDEFINED, 1f)
            }
            
            // 添加 10dp 的内部边距
            val padding = (context.resources.displayMetrics.density * 13).toInt()
            setPadding(padding, padding, padding, padding)
        }

        if (text.isNotEmpty()) {
            val dayView = TextView(context).apply {
                this.text = text
                textSize = 24f
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER

                // 设置文本颜色
                val isWeekend = dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY
                setTextColor(if (isWeekend) Color.argb(102, 255, 255, 255) else Color.WHITE)

                // 只为今天设置背景
                if (isToday) {
                    background = GradientDrawable().apply {
                        shape = GradientDrawable.RECTANGLE
                        cornerRadius = context.resources.displayMetrics.density * 20 // 20dp
                        setColor(0xFFFF4650.toInt())
                    }
                }

                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            }
            container.addView(dayView)
        }

        addView(container)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = MeasureSpec.getSize(heightMeasureSpec)
        
        // 使用可用空间中的较小值作为基准
        val size = minOf(width, height)
        
        super.onMeasure(
            MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(size, MeasureSpec.EXACTLY)
        )
    }
}