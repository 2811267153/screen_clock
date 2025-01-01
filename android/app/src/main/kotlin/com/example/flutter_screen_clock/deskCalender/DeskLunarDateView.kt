package com.example.flutter_screen_clock.deskCalender

import android.content.Context
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.Shader
import android.graphics.Typeface
import android.util.AttributeSet
import android.util.TypedValue
import android.util.Log
import android.view.View
import android.animation.ValueAnimator
import android.view.animation.LinearInterpolator
import com.example.flutter_screen_clock.network.Repository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Calendar
import android.widget.FrameLayout
import android.widget.TextView
import com.example.flutter_screen_clock.widget.ShimmerView

class DeskLunarDateView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {

    private var lunarText = "农历二〇二四年腊月初一日（阴历）"
    private val scope = CoroutineScope(Dispatchers.Main)
    private val shimmerView: ShimmerView
    private val textView: TextView

    init {
        // 初始化骨架屏
        shimmerView = ShimmerView(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT
            )
            shimmerHeight = 20f
            shimmerColor = 0x79797979
            cornerRadius = 5f
        }
        addView(shimmerView)

        // 初始化文本视图
        textView = TextView(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT
            ).apply {
                // 移除 margin
                setMargins(0, 0, 0, 0)
            }
            setTextColor(0xFFFFFFFF.toInt())
            textSize = 30f
            typeface = Typeface.DEFAULT_BOLD
            visibility = View.GONE
            includeFontPadding = false  // 移除字体内边距
            
            // 移除所有内边距
            setPadding(0, 0, 0, 0)
        }
        addView(textView)

        updateLunarDate()
        startDateUpdate()
    }

    private fun updateLunarDate() {
        val calendar = Calendar.getInstance()
        val year = calendar.get(Calendar.YEAR)
        val month = calendar.get(Calendar.MONTH) + 1
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        
        Log.d("DeskLunarDateView", "开始获取农历数据: $year-$month-$day")
        
        showLoading()
        
        scope.launch {
            Repository.getLunarCalendar(year, month, day)
                .onSuccess { response ->
                    Log.d("DeskLunarDateView", "获取成功: ${response.nongli}")
                    hideLoading()
                    lunarText = response.nongli ?: "暂无数据"
                    textView.text = lunarText
                }.onFailure { error ->
                    Log.e("DeskLunarDateView", "获取失败", error)
                    hideLoading()
                    lunarText = "暂无数据"
                    textView.text = lunarText
                }
        }
    }

    private fun showLoading() {
        shimmerView.visibility = View.VISIBLE
        shimmerView.startShimmer()
        textView.visibility = View.GONE
    }

    private fun hideLoading() {
        shimmerView.stopShimmer()
        shimmerView.visibility = View.GONE
        textView.visibility = View.VISIBLE
        textView.text = lunarText
        
        if (lunarText == "获取农历失败") {
            // 错误状态：居中对齐
            textView.gravity = android.view.Gravity.CENTER
            textView.letterSpacing = 0f
        } else {
            // 正常状态：两端对齐
            textView.gravity = android.view.Gravity.FILL_HORIZONTAL
            textView.post {
                val availableWidth = textView.width
                val textWidth = textView.paint.measureText(lunarText)
                val spacing = (availableWidth - textWidth) / (lunarText.length - 1)
                textView.letterSpacing = spacing / textView.paint.textSize
            }
        }
    }

    private fun startDateUpdate() {
        post(object : Runnable {
            override fun run() {
                showLoading()
                
                updateLunarDate()
                
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
