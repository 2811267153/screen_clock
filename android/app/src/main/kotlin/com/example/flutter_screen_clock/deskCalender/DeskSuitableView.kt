package com.example.flutter_screen_clock.deskCalender

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.Typeface
import android.util.AttributeSet
import android.util.Log
import android.view.View
import com.example.flutter_screen_clock.network.Repository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Calendar
import android.util.TypedValue

class DeskSuitableView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : View(context, attrs) {

    private val textPaint = Paint().apply {
        isAntiAlias = true
        color = 0xFFFFFFFF.toInt()
        textAlign = Paint.Align.LEFT
        typeface = Typeface.DEFAULT_BOLD
    }

    private var yiText = ""
    private var jiText = ""
    private val scope = CoroutineScope(Dispatchers.Main)

    init {
        updateSuitableInfo()
        startDayUpdate()
    }

    private fun updateSuitableInfo() {
        val calendar = Calendar.getInstance()
        val year = calendar.get(Calendar.YEAR)
        val month = calendar.get(Calendar.MONTH) + 1
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        
        Log.d("DeskSuitableView", "开始获取数据: $year-$month-$day")
        
        scope.launch {
            Repository.getLunarCalendar(year, month, day)
                .onSuccess { response ->
                    Log.d("DeskSuitableView", "获取成功: ${response.yi}")
                    yiText = "宜：${response.yi?.joinToString(" ") ?: "暂无数据"}"
                    jiText = "忌：${response.yi?.joinToString(" ") ?: "暂无数据"}"
                    invalidate()
                }.onFailure { error ->
                    Log.e("DeskSuitableView", "获取失败", error)
                    yiText = "暂无数据"
                    jiText = "暂无数据"
                    invalidate()
                }
        }
    }

    private fun startDayUpdate() {
        post(object : Runnable {
            override fun run() {
                updateSuitableInfo()
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

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        Log.d("DeskSuitableView", "onAttachedToWindow")
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        Log.d("DeskSuitableView", "onLayout - changed: $changed, bounds: [$left, $top, $right, $bottom]")
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        val availableWidth = width
        val lineHeight = dpToPx(40f)

        // 绘制 "宜" 部分
        val yiText = yiText.substringAfter("宜：")
        drawAlignedText(canvas, "宜：", yiText, 0f, lineHeight, availableWidth)

        // 绘制 "忌" 部分
        val jiText =jiText .substringAfter("忌：")
        drawAlignedText(canvas, "忌：", jiText, lineHeight, 2 * lineHeight, availableWidth)

    }

    private fun drawAlignedText(
        canvas: Canvas,
        prefix: String,
        content: String,
        top: Float,
        bottom: Float,
        availableWidth: Int
    ) {
        val textSize: Float
        val spacing: Float
        val baseline = top + (bottom - top) / 2 + dpToPx(10f) // 居中绘制

        when {
            content.length < 5 -> {
                // 小于 5 个字符，按 5 个字符宽度计算，左对齐
                textSize = dpToPx(20f)
                spacing = 0f
            }
            content.length == 5 -> {
                // 等于 5 个字符，两端对齐
                textSize = dpToPx(20f)
                spacing = (availableWidth - textPaint.measureText(prefix) -
                        textPaint.measureText(content)) / (content.length - 1)
            }
            content.length < 10 -> {
                // 大于 5 小于 10 个字符，按 10 个字符宽度计算，左对齐
                textSize = dpToPx(12f)
                spacing = 0f
            }
            content.length == 10 -> {
                // 等于 10 个字符，两端对齐
                textSize = dpToPx(12f)
                spacing = (availableWidth - textPaint.measureText(prefix) -
                        textPaint.measureText(content)) / (content.length - 1)
            }
            else -> {
                // 超过 10 个字符，截断显示，按 10 个字符宽度计算
                textSize = dpToPx(12f)
                spacing = 0f
            }
        }

        textPaint.textSize = textSize
        val startX = dpToPx(10f)
        canvas.drawText(prefix, startX, baseline, textPaint)

        // 绘制内容
        var currentX = startX + textPaint.measureText(prefix)
        content.forEachIndexed { index, char ->
            canvas.drawText(char.toString(), currentX, baseline, textPaint)
            currentX += textPaint.measureText(char.toString()) + spacing
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val heightMode = MeasureSpec.getMode(heightMeasureSpec)
        val heightSize = MeasureSpec.getSize(heightMeasureSpec)

        val height = when (heightMode) {
            MeasureSpec.EXACTLY -> heightSize
            else -> dpToPx(80f).toInt()
        }
        
        Log.d("DeskSuitableView", "onMeasure - width: $width, height: $height, heightMode: $heightMode")
        setMeasuredDimension(width, height)
    }

    private fun dpToPx(dp: Float): Float {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            context.resources.displayMetrics
        )
    }
} 