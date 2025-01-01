package com.example.flutter_screen_clock.deskCalender

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.util.AttributeSet
import android.view.View
import java.util.Calendar

class DeskDayView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : View(context, attrs) {

    private val textPaint = Paint().apply {
        isAntiAlias = true
        color = 0xFFFFFFFF.toInt()
        textAlign = Paint.Align.CENTER
        typeface = Typeface.DEFAULT_BOLD
    }
    
    private var firstDigit = "0"
    private var secondDigit = "0"
    
    init {
        // 设置当前日期
        updateDay()
        // 启动定时更新
        startDayUpdate()
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        if (changed) {
            // 根据父元素宽高设置字体大小
            val availableWidth = width / 2f
            val availableHeight = height.toFloat()
             val targetSize = minOf(availableWidth, availableHeight) * 1f // 留一些边距
            textPaint.textSize = targetSize * 1.4f  // 将字号放大1.2倍
            invalidate()
        }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        // 计算字体的绘制基线
        val fontMetrics = textPaint.fontMetrics
        val baseline = height / 2f - (fontMetrics.top + fontMetrics.bottom) / 2f

        // 绘制两个数字，水平居中
        val centerX1 = width / 4f
        val centerX2 = width * 3 / 4f
        canvas.drawText(firstDigit, centerX1, baseline, textPaint)
        canvas.drawText(secondDigit, centerX2, baseline, textPaint)
    }


    // 确保视图是正方形
    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val heightMode = MeasureSpec.getMode(heightMeasureSpec)
        val heightSize = MeasureSpec.getSize(heightMeasureSpec)

        // 使用布局提供的高度，而不是强制设为正方形
        val height = when (heightMode) {
            MeasureSpec.EXACTLY -> heightSize  // 使用布局指定的精确值
            else -> width  // 如果没有指定，才使用宽度值
        }

        setMeasuredDimension(width, height)
    }

    private fun updateDay() {
        val calendar = Calendar.getInstance()
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        // 格式化为两位数
        val dayStr = String.format("%02d", day)
        firstDigit = dayStr[0].toString()
        secondDigit = dayStr[1].toString()
        invalidate()
    }

    private fun startDayUpdate() {
        post(object : Runnable {
            override fun run() {
                updateDay()
                // 计算到下一天凌晨的延迟时间
                val calendar = Calendar.getInstance()
                calendar.add(Calendar.DAY_OF_MONTH, 1)
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                calendar.set(Calendar.MILLISECOND, 0)
                val delay = calendar.timeInMillis - System.currentTimeMillis()
                postDelayed(this, delay)
            }
        })
    }
} 