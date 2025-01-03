package com.example.flutter_screen_clock

import NotificationActivity
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import android.view.WindowManager
import android.content.Context
import android.content.BroadcastReceiver
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.fragment.app.Fragment
import android.widget.TextView


class ContainerActivity : AppCompatActivity() {
    private lateinit var carouselFragment: Fragment
    private lateinit var weatherFragment: Fragment
    private lateinit var notificationFragment:  Fragment

    // 状态变量
    private var isMasterSwitchOn = false  // 主开关状态
    private val handler = Handler(Looper.getMainLooper())  // UI 线程处理器
    private var isLockScreenActive = false  // 锁屏状态标志

    /**
     * 锁屏广播接收器
     * 监听屏幕关闭和用户解锁事件
     */
    private val screenReceiver = object : BroadcastReceiver() {
        @RequiresApi(Build.VERSION_CODES.M)
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_OFF -> {
                    if (isMasterSwitchOn) {
                        handler.postDelayed({
                            showCarousel()
                        }, 100)
                    }
                }
            }
        }
    }



    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 强制显示 Fragment
        val fragment = supportFragmentManager.findFragmentById(R.id.fragment_container)
        Log.d("FragmentDebug", "CarouselFragment found: $fragment")

        // 设置窗口标志，允许在锁屏界面上显示
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        // 启用全屏模式，包含状态栏和导航栏
        window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                )
        window.statusBarColor = android.graphics.Color.TRANSPARENT
        window.navigationBarColor = android.graphics.Color.TRANSPARENT

        setContentView(R.layout.activity_container)

        // 初始化 Fragment
        if (savedInstanceState == null) {  // 只在首次创建时添加 Fragment
            carouselFragment = CarouselActivity()
            notificationFragment = NotificationActivity()

            supportFragmentManager.beginTransaction()
                .add(R.id.fragment_container, carouselFragment)
                .add(R.id.fragment_container, notificationFragment)  // 使用同一个容器
                .hide(carouselFragment)  // 默认隐藏轮播
                .show(notificationFragment)   // 显示天气
                .commitNow()
        } else {
            // 从已保存状态恢复 Fragment
            carouselFragment = supportFragmentManager.findFragmentById(R.id.fragment_container)
                ?: CarouselActivity()
            notificationFragment = supportFragmentManager.findFragmentById(R.id.fragment_container)
                ?: WeatherActivity()
        }

        // 添加日志
        Log.d("FragmentDebug", "CarouselFragment: $carouselFragment")
        Log.d("FragmentDebug", "notificationFragment: $notificationFragment")

        // 默认显示轮播图
//        showCarousel()
//        showWeather()
        showNotificationActivity()
        // 注册屏幕状态广播接收器
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        registerReceiver(screenReceiver, filter)

        // 从 Intent 中获取主开关状态
        isMasterSwitchOn = intent.getBooleanExtra("master_switch_state", false)
        
        // 如果主开关开启，显示轮播图
        if (isMasterSwitchOn) {
            showCarousel()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(screenReceiver)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * 启用锁屏功能
     */
    private fun enableLockScreen() {
        isLockScreenActive = true
        
        // 创建意图过滤器
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        
        // 尝试取消旧的注册
        try {
            unregisterReceiver(screenReceiver)
        } catch (e: Exception) {
            // 忽略未注册的异常
        }
        
        // 注册新的广播接收器
        registerReceiver(screenReceiver, filter)
        println("Lock screen enabled")
    }

    /**
     * 禁用锁屏功能
     */
    private fun disableLockScreen() {
        isLockScreenActive = false
        finish()  // 关闭当前活动
    }

    /**
     * 显示轮播图页面
     */
    fun showCarousel() {
        Log.d("FragmentDebug", "Showing carousel fragment")
        supportFragmentManager.beginTransaction()
            .setCustomAnimations(
                android.R.anim.fade_in,
                android.R.anim.fade_out
            )
            .show(carouselFragment)
            .hide(weatherFragment)
            .commitNow()
    }
    private fun showNotificationActivity() {
        Log.d("FragmentDebug", "Showing notificationFragment fragment")
        supportFragmentManager.beginTransaction()
            .setCustomAnimations(
                android.R.anim.fade_in,
                android.R.anim.fade_out
            )
            .show(notificationFragment)
            .hide(carouselFragment)
            .commitNow()
    }

    /**
     * 显示天气页面
     */
    private fun showWeather() {
        Log.d("FragmentDebug", "Showing weather fragment")
        supportFragmentManager.beginTransaction()
            .setCustomAnimations(
                android.R.anim.fade_in,
                android.R.anim.fade_out
            )
            .hide(carouselFragment)
            .show(weatherFragment)
            .commitNow()
        
        // 强制更新天气数据
//        (weatherFragment as? WeatherActivity)?.updateWeatherData()
    }

    fun updateWeatherData(temperature: String, condition: String, humidity: String) {
        (weatherFragment as? WeatherActivity)?.let { fragment ->
            fragment.view?.let { view ->
                view.findViewById<TextView>(R.id.temperature)?.text = temperature
                view.findViewById<TextView>(R.id.weather_condition)?.text = condition
                view.findViewById<TextView>(R.id.humidity)?.text = "湿度: $humidity"
            }
        }
    }
} 