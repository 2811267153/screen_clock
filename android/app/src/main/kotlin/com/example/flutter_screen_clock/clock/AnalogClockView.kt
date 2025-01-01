package com.example.flutter_screen_clock.clock

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.view.View
import android.view.animation.LinearInterpolator
import java.util.*
import kotlin.math.cos
import kotlin.math.sin
import android.animation.ValueAnimator

class AnalogClockView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : View(context, attrs) {

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private var centerX = 0f
    private var centerY = 0f
    private var radius = 0f

    // 时钟刻度的颜色和宽度
    private val markWidth = 10f  // 统一刻度宽度为5dp
    private val hourTextSize = 40f
    private val minuteTextSize = 30f

    // 指针颜色和宽度
    private val hourHandColor = Color.WHITE
    private val minuteHandColor = Color.WHITE
    private val secondHandColor = Color.RED

    private val hourHandWidth = 14f
    private val minuteHandWidth = 14f
    private val secondHandWidth = 8f

    private var currentSecond = 0f
    private var currentMinute = 0f
    private var currentHour = 0f
    private var animator: ValueAnimator? = null
    
    init {
        // 初始化当前时间
        val calendar = Calendar.getInstance()
        currentSecond = calendar.get(Calendar.SECOND).toFloat()
        currentMinute = calendar.get(Calendar.MINUTE).toFloat()
        currentHour = calendar.get(Calendar.HOUR).toFloat()

        // 初始化文字画笔
        textPaint.apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            strokeCap = Paint.Cap.ROUND
        }

        // 启动动画
        startSmoothAnimation()
    }

    private fun startSmoothAnimation() {
        animator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 1000
            interpolator = LinearInterpolator()
            repeatCount = ValueAnimator.INFINITE
            addUpdateListener { animator ->
                val fraction = animator.animatedValue as Float
                
                // 累加时间
                currentSecond += 1f/60f
                if (currentSecond >= 60f) {
                    currentSecond = 0f
                    currentMinute += 1f
                    if (currentMinute >= 60f) {
                        currentMinute = 0f
                        currentHour += 1f
                        if (currentHour >= 12f) {
                            currentHour = 0f
                        }
                    }
                }
                
                invalidate()
            }
            start()
        }
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        centerX = w / 2f
        centerY = h / 2f
        radius = (Math.min(w, h) / 2 * 0.8).toFloat()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        drawClockFace(canvas)

        // 计算角度
        val hourAngle = (currentHour + currentMinute / 60f) * 30f
        val minuteAngle = (currentMinute + currentSecond / 60f) * 6f
        val secondAngle = currentSecond * 6f

        // 绘制指针
        drawHand(canvas, hourAngle, radius * 0.5f, hourHandWidth, hourHandColor)
        drawHand(canvas, minuteAngle, radius * 0.7f, minuteHandWidth, minuteHandColor)
        drawHand(canvas, secondAngle, radius * 0.8f, secondHandWidth, secondHandColor)

        paint.color = Color.WHITE
        canvas.drawCircle(centerX, centerY, 10f, paint)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        animator?.cancel()
    }

    private fun drawClockFace(canvas: Canvas) {
        // 绘制刻度和数字
        for (i in 0..59) {
            val angle = i * 6f
            val isHour = i % 5 == 0
            paint.strokeWidth = markWidth
            paint.strokeCap = Paint.Cap.ROUND
            
            // 刻度线
            val startRadius = radius - 60f
            val endRadius = radius - 20f
            
            val startX = centerX + startRadius * sin(Math.toRadians(angle.toDouble())).toFloat()
            val startY = centerY - startRadius * cos(Math.toRadians(angle.toDouble())).toFloat()
            val endX = centerX + endRadius * sin(Math.toRadians(angle.toDouble())).toFloat()
            val endY = centerY - endRadius * cos(Math.toRadians(angle.toDouble())).toFloat()
            
            // 绘制刻度线
            paint.color = if (isHour) {
                Color.WHITE  // 小时刻度线使用不透明白色
            } else {
                Color.argb(102, 255, 255, 255)  // 非小时刻度线使用60%透明的白色
            }
            canvas.drawLine(startX, startY, endX, endY, paint)

            // 绘制数字
            if (isHour) {
                val number = if (i == 0) "12" else (i / 5).toString()
                val textRadius = radius - 100f  // 将文字位置向内移动，从70f改为100f
                val textX = centerX + textRadius * sin(Math.toRadians(angle.toDouble())).toFloat()
                val textY = centerY - textRadius * cos(Math.toRadians(angle.toDouble())).toFloat()
                
                textPaint.apply {
                    textSize = hourTextSize
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                }
                
                val textBounds = Rect()
                textPaint.getTextBounds(number, 0, number.length, textBounds)
                val textYOffset = (textBounds.bottom - textBounds.top) / 2f
                
                canvas.drawText(number, textX, textY + textYOffset, textPaint)
            }
        }
    }

    private fun drawHand(canvas: Canvas, angle: Float, length: Float, width: Float, color: Int) {
        paint.apply {
            style = Paint.Style.FILL_AND_STROKE
            strokeWidth = width
            this.color = color
            strokeCap = Paint.Cap.ROUND
        }
        
        val radian = Math.toRadians((angle - 90).toDouble())
        val endX = centerX + length * cos(radian).toFloat()
        val endY = centerY + length * sin(radian).toFloat()
        
        canvas.drawLine(centerX, centerY, endX, endY, paint)
    }
} 