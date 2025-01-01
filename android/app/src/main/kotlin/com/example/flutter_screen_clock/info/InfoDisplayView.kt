package com.example.flutter_screen_clock.info

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import com.example.flutter_screen_clock.R

class InfoDisplayView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    init {
        // 加载布局
        inflate(context, R.layout.info_display_layout, this)
    }
} 