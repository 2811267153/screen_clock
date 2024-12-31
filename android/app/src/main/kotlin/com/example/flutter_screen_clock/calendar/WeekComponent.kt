package com.example.flutter_screen_clock.calendar

import android.content.Context
import android.graphics.Typeface
import android.os.Build
import android.util.AttributeSet
import android.widget.LinearLayout
import android.widget.TextView
import android.view.Gravity
import androidx.annotation.RequiresApi

import com.example.flutter_screen_clock.R

@RequiresApi(Build.VERSION_CODES.M)
class WeekComponent @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val weekDays = arrayOf("日", "一", "二", "三", "四", "五", "六")

    init {
        layoutParams = LayoutParams(
            LayoutParams.MATCH_PARENT,
            LayoutParams.WRAP_CONTENT
        )
        
        orientation = HORIZONTAL
        weightSum = 7f

        weekDays.forEachIndexed { index, day ->
            addView(TextView(context).apply {
                text = day
                textSize = 24f
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                
                val isWeekend = index == 0 || index == 6
                setTextColor(context.getColor(
                    if (isWeekend) R.color.calendar_weekend_text 
                    else R.color.calendar_weekday_text
                ))

                layoutParams = LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f)
            })
        }
    }
} 