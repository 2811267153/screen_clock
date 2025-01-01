package com.example.flutter_screen_clock.deskCalender

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.util.AttributeSet
import android.view.View
import com.example.flutter_screen_clock.R
import java.util.Calendar

class DeskWeekDayView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : View(context, attrs) {

    private val weekDays = arrayOf("星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六")
    private var weekDayText = ""
    private val textPaint = Paint().apply {
        isAntiAlias = true
        color = 0xFFFFFFFF.toInt()
        textAlign = Paint.Align.CENTER
    }
    private val textBounds = Rect()

    init {
        updateWeekDay()
    }

    private fun updateWeekDay() {
        val calendar = Calendar.getInstance()
        val dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK) - 1
        weekDayText = weekDays[dayOfWeek]
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        // 获取文字的总高度和单个字符高度
        textPaint.getTextBounds(weekDayText, 0, 1, textBounds)
        val singleCharHeight = textBounds.height()
        
        // 计算字符间距，使文字两端对齐
        val totalTextHeight = singleCharHeight * weekDayText.length
        val spacing = (height - totalTextHeight) / (weekDayText.length - 1)

        // 计算合适的文字大小
        var textSize = width * 1f
        textPaint.textSize = textSize

        // 确保文字宽度不超过视图宽度的80%
        textPaint.getTextBounds("星", 0, 1, textBounds)
        if (textBounds.width() > width * 0.8f) {
            textSize = textSize * (width * 0.8f) / textBounds.width()
            textPaint.textSize = textSize
        }

        // 重新获取调整后的文字边界
        textPaint.getTextBounds(weekDayText, 0, 1, textBounds)
        val adjustedCharHeight = textBounds.height()

        // 绘制文字，从顶部开始
        var y = adjustedCharHeight // 起始位置为第一个字符的高度
        weekDayText.forEach { char ->
            canvas.drawText(char.toString(), width / 2f, y.toFloat(), textPaint)
            y += adjustedCharHeight + spacing.toInt() // 添加间距
        }
    }
} 