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
import android.graphics.Color
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.fragment.app.Fragment
import android.widget.TextView
import android.view.animation.AlphaAnimation
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.Animation
import androidx.core.view.WindowCompat


class ContainerActivity : AppCompatActivity() {
    private lateinit var carouselFragment: Fragment
    private lateinit var containerFragment: Fragment
    private lateinit var notificationFragment:  Fragment

    // 状态变量
    private var isMasterSwitchOn = false  // 主开关状态
    private val handler = Handler(Looper.getMainLooper())  // UI 线程处理器
    private var isLockScreenActive = false  // 锁屏状态标志
    private val hideNotificationRunnable = Runnable {
        handleNotification(false)
    }

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

        // 设置窗口标志，允许在锁屏界面上显示
        // 设置全屏和沉浸式模式
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )

        // 隐藏导航栏和状态栏
        @Suppress("DEPRECATION")
        window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                )

        // 确保导航栏完全透明
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.navigationBarDividerColor = Color.TRANSPARENT
        }
        window.navigationBarColor = Color.TRANSPARENT

        // 设置布局延伸到导航栏下方
        WindowCompat.setDecorFitsSystemWindows(window, false)

        setContentView(R.layout.activity_container)

        // 初始化 Fragment
        if (savedInstanceState == null) {  // 只在首次创建时添加 Fragment
            carouselFragment = CarouselActivity()
            notificationFragment = NotificationActivity()

            supportFragmentManager.beginTransaction()
                .add(R.id.fragment_container, carouselFragment)
                .add(R.id.fragment_container, notificationFragment)
                .hide(notificationFragment)  // 默认隐藏通知
                .show(carouselFragment)     // 默认显示轮播图
                .commitNow()
        } else {
            // 从已保存状态恢复 Fragment
            carouselFragment = supportFragmentManager.findFragmentByTag("carousel")
                ?: CarouselActivity()
            notificationFragment = supportFragmentManager.findFragmentByTag("notification")
                ?: NotificationActivity()
        }

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
        handler.removeCallbacks(hideNotificationRunnable)
        try {
            unregisterReceiver(screenReceiver)
        } catch (e: Exception) {
            e.printStackTrace()
        }
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
            .show(containerFragment)
            .commitNow()
    }

    private fun createFadeInAnimation(): Animation {
        val fadeIn = AlphaAnimation(0f, 1f)
        fadeIn.interpolator = DecelerateInterpolator()
        fadeIn.duration = 800
        return fadeIn
    }

    private fun createFadeOutAnimation(): Animation {
        val fadeOut = AlphaAnimation(1f, 0f)
        fadeOut.interpolator = AccelerateInterpolator()
        fadeOut.duration = 800
        return fadeOut
    }

    fun handleNotification(show: Boolean) {

        runOnUiThread {

            try {
                if (show) {
                    // 显示通知，隐藏轮播图
                    notificationFragment.view?.startAnimation(createFadeInAnimation())
                    carouselFragment.view?.startAnimation(createFadeOutAnimation())
                    
                    supportFragmentManager.beginTransaction()
                        .show(notificationFragment)
                        .hide(carouselFragment)
                        .commitNow()
                } else {
                    // 隐藏通知，显示轮播图
                    carouselFragment.view?.startAnimation(createFadeInAnimation())
                    notificationFragment.view?.startAnimation(createFadeOutAnimation())
                    
                    supportFragmentManager.beginTransaction()
                        .show(carouselFragment)
                        .hide(notificationFragment)
                        .commitNow()
                }
                
                if (show) {
                    // 延长显示时间到 6 秒
                    handler.removeCallbacks(hideNotificationRunnable)
                    handler.postDelayed(hideNotificationRunnable, 6000)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
} 