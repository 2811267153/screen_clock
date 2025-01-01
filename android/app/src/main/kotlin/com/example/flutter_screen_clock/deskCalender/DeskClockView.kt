package com.example.flutter_screen_clock.deskCalender

import android.content.Context
import android.util.AttributeSet
import android.widget.FrameLayout

class DeskClockView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {

    init {
        // 设置白色背景
        setBackgroundColor(0xFFFFFFFF.toInt())
    }
} 