package com.example.flutter_screen_clock.widget

import android.content.Context
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.util.AttributeSet
import android.util.TypedValue
import android.view.View
import android.animation.ValueAnimator
import android.view.animation.LinearInterpolator

class ShimmerView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : View(context, attrs) {

    private var isLoading = true
    private val shimmerPaint = Paint().apply {
        isAntiAlias = true
        color = 0x797979FF.toInt()
    }
    
    var shimmerHeight: Float = 20f  // 默认高度 20dp
        set(value) {
            field = value
            invalidate()
        }
    
    var shimmerColor: Int = 0x797979FF.toInt()  // 默认颜色
        set(value) {
            field = value
            shimmerPaint.color = value
            invalidate()
        }
    
    var cornerRadius: Float = 5f  // 默认圆角 5dp
        set(value) {
            field = value
            invalidate()
        }
    
    private var shimmerTranslation = 0f
    private val shimmerAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
        duration = 1000
        repeatCount = ValueAnimator.INFINITE
        repeatMode = ValueAnimator.RESTART
        interpolator = LinearInterpolator()
        addUpdateListener { animator ->
            shimmerTranslation = animator.animatedValue as Float
            invalidate()
        }
    }

    init {
        startShimmer()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        if (isLoading) {
            drawShimmer(canvas)
        }
    }

    private fun drawShimmer(canvas: Canvas) {
        val shimmerWidth = width.toFloat()
        val actualHeight = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            shimmerHeight,
            context.resources.displayMetrics
        )
        val left = 0f
        val top = 0f
        
        val gradient = LinearGradient(
            left - shimmerWidth + (shimmerWidth * 2 * shimmerTranslation),
            0f,
            left + shimmerWidth * shimmerTranslation,
            0f,
            intArrayOf(shimmerColor, shimmerColor, shimmerColor),
            floatArrayOf(0f, 0.5f, 1f),
            Shader.TileMode.CLAMP
        )
        shimmerPaint.shader = gradient
        
        val actualCornerRadius = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            cornerRadius,
            context.resources.displayMetrics
        )
        
        canvas.drawRoundRect(
            left, top, 
            left + shimmerWidth, top + actualHeight,
            actualCornerRadius,
            actualCornerRadius,
            shimmerPaint
        )
    }

    fun startShimmer() {
        isLoading = true
        shimmerAnimator.start()
        invalidate()
    }

    fun stopShimmer() {
        isLoading = false
        shimmerAnimator.cancel()
        invalidate()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        shimmerAnimator.cancel()
    }
} 