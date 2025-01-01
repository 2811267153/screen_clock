package com.example.flutter_screen_clock.deskCalender

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import android.widget.TextView
import com.example.flutter_screen_clock.R
import java.util.Calendar

class DeskInfoView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val weekDays = arrayOf("星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六")
    private lateinit var weekDayText: TextView

    init {
        try {
            // 加载布局
            inflate(context, R.layout.desk_info_layout, this)
            
            // 初始化视图
            weekDayText = findViewById(R.id.weekDayText)
            
            // 设置当前星期
            updateWeekDay()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun updateWeekDay() {
        val calendar = Calendar.getInstance()
        val dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK) - 1
        weekDayText.text = weekDays[dayOfWeek]
    }
} 