package com.example.flutter_screen_clock.deskCalender

import android.content.Context
import android.graphics.Typeface
import android.os.Build
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.TextView
import androidx.annotation.RequiresApi
import com.example.flutter_screen_clock.R
import java.util.Calendar

@RequiresApi(Build.VERSION_CODES.M)
class DeskYearMonthView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {

    init {
        // 设置布局参数
        layoutParams = LayoutParams(
            LayoutParams.MATCH_PARENT,
            LayoutParams.WRAP_CONTENT
        )

        val calendar = Calendar.getInstance()
        val currentYear = calendar.get(Calendar.YEAR)
        val currentMonth = calendar.get(Calendar.MONTH) + 1

        // 创建并添加年月显示的 TextView
        addView(TextView(context).apply {
            text = "${currentYear}年${currentMonth}月"
            setTextSize(TypedValue.COMPLEX_UNIT_DIP, 30f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setTextColor(context.getColor(R.color.calendar_weekday_text))  // 使用纯白色

            // 设置布局参数
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
                
                // 添加上下边距
                val verticalMargin = (context.resources.displayMetrics.density * 20).toInt()
                setMargins(0, verticalMargin, 0, verticalMargin)
            }
        })
    }
} 