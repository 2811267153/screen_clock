package com.example.flutter_screen_clock

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper
import android.content.Intent
import android.app.Activity
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.view.WindowManager.LayoutParams
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat

/**
 * 主活动类，处理锁屏和 Flutter 通信
 */
class MainActivity: FlutterActivity() {
    // Flutter 通信通道常量
    private val CHANNEL = "com.example.flutter_screen_clock/toast"  // Toast 消息通道
    private val MASTER_SWITCH_CHANNEL = "com.example.flutter_screen_clock/master_switch"  // 主开关通道

    // 状态变量
    private var isMasterSwitchOn = false  // 主开关状态
    private val handler = Handler(Looper.getMainLooper())  // UI 线程处理器
    private var isHandlingToast = false  // Toast 显示状态标志
    private var pendingResult: MethodChannel.Result? = null  // 异步操作结果
    private var isLockScreenActive = false  // 锁屏状态标志

    /**
     * 锁屏广播接收器
     * 监听屏幕关闭和用户解锁事件
     */
    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_OFF -> {  // 屏幕关闭时
                    if (isMasterSwitchOn && !isLockScreenActive) {
                        enableLockScreen()  // 启用锁屏
                    }
                }
                Intent.ACTION_USER_PRESENT -> {  // 用户解锁时
                    disableLockScreen()  // 禁用锁屏
                }
            }
        }
    }

    /**
     * 活动创建时的初始化
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 注册锁屏广播接收器
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        registerReceiver(screenReceiver, filter)
    }

    /**
     * 活动销毁时的清理
     */
    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(screenReceiver)  // 注销广播接收器
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * 配置 Flutter 引擎和通信通道
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 配置 Toast 通信通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showToast" -> {
                    if (isHandlingToast) {  // 防止重复显示
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    
                    isHandlingToast = true
                    try {
                        val message = call.argument<String>("message")
                        showToast(message)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("TOAST_ERROR", e.message, null)
                    } finally {
                        handler.postDelayed({
                            isHandlingToast = false
                        }, 1000)  // 1秒后重置状态
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 配置主开关通信通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MASTER_SWITCH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateMasterSwitch" -> {
                    try {
                        isMasterSwitchOn = call.argument<Boolean>("isOn") ?: false
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("SWITCH_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * 处理活动结果
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == 1199) {
            pendingResult?.success(resultCode == Activity.RESULT_OK)
            pendingResult = null
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    /**
     * 显示 Toast 消息
     */
    private fun showToast(message: String?) {
        handler.post {
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
        }
    }

    /**
     * 启用锁屏功能
     * 设置窗口属性和系统UI显示
     */
    private fun enableLockScreen() {
        isLockScreenActive = true
        
        runOnUiThread {
            // 适配 Android 8.1 及以上版本
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)  // 在锁屏界面上显示
                setTurnScreenOn(true)    // 打开屏幕
                
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                keyguardManager.requestDismissKeyguard(this, null)  // 请求解除系统锁屏
            }

            // 设置窗口属性
            window.apply {
                addFlags(
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or      // 保持屏幕常亮
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or    // 解除系统锁屏
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or   // 在锁屏界面上显示
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON        // 打开屏幕
                )

                // 适配刘海屏
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    attributes.layoutInDisplayCutoutMode = 
                        WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
                }
            }

            // 处理系统UI（状态栏和导航栏）
            WindowCompat.setDecorFitsSystemWindows(window, false)
            WindowInsetsControllerCompat(window, window.decorView).apply {
                hide(WindowInsetsCompat.Type.systemBars())  // 隐藏系统栏
                systemBarsBehavior = 
                    WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE  // 设置滑动显示
            }
        }

        println("Lock screen enabled")
    }

    /**
     * 禁用锁屏功能
     * 恢复窗口属性和系统UI显示
     */
    private fun disableLockScreen() {
        isLockScreenActive = false
        
        runOnUiThread {
            // 恢复 Android 8.1 及以上版本的设置
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(false)
                setTurnScreenOn(false)
            }

            // 清除窗口标志
            window.clearFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )

            // 恢复系统UI显示
            WindowCompat.setDecorFitsSystemWindows(window, true)
            WindowInsetsControllerCompat(window, window.decorView).apply {
                show(WindowInsetsCompat.Type.systemBars())
            }
        }

        println("Lock screen disabled")
    }

    /**
     * 更新主开关状态
     * 当关闭主开关时，同时禁用锁屏
     */
    private fun updateMasterSwitch(isOn: Boolean) {
        isMasterSwitchOn = isOn
        if (!isOn && isLockScreenActive) {
            disableLockScreen()
        }
    }
}