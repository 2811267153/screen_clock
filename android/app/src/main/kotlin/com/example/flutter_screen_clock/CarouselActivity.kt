package com.example.flutter_screen_clock

import android.app.KeyguardManager
import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import android.os.Build
import androidx.annotation.RequiresApi

class CarouselActivity : AppCompatActivity() {
    private lateinit var viewPager: ViewPager2
    private lateinit var indicatorContainer: LinearLayout
    private val pageCount = 4
    private val indicators = mutableListOf<ImageView>()

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 设置窗口标志，允许在锁屏界面上显示
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        // 请求解除系统锁屏
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        keyguardManager.requestDismissKeyguard(this, null)

        setContentView(R.layout.activity_fullscreen_carousel)

        // 设置横屏全屏
        window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY)

        viewPager = findViewById(R.id.viewPager)
        indicatorContainer = findViewById(R.id.indicatorContainer)

        // 设置适配器
        viewPager.adapter = CarouselAdapter()

        // 设置页面切换监听
        viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                updateIndicators(position)
            }
        })
    }

    private fun updateIndicators(position: Int) {
        for (i in indicators.indices) {
            indicators[i].setBackgroundResource(
                if (i == position) R.drawable.indicator_selected 
                else R.drawable.indicator_unselected
            )
        }
    }

    inner class CarouselAdapter : RecyclerView.Adapter<CarouselAdapter.ViewHolder>() {
        inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val pageText: TextView = view.findViewById(R.id.pageText)
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = layoutInflater.inflate(R.layout.item_carousel, parent, false)
            return ViewHolder(view)
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            holder.pageText.text = (position + 1).toString()
        }

        override fun getItemCount() = pageCount
    }
} 