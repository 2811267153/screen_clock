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
import android.os.PowerManager
import android.app.ActivityOptions
import androidx.annotation.RequiresApi

/**
 * 主活动类，处理锁屏和 Flutter 通信
 */
class MainActivity: FlutterActivity() {
    // Flutter 通信通道常量
    private val CHANNEL = "com.example.flutter_screen_clock/toast"  // Toast 消息通道
    private val MASTER_SWITCH_CHANNEL = "com.example.flutter_screen_clock/master_switch"  // 主开关通道
    private val LUNAR_CALENDAR_CHANNEL = "lunar_calendar_channel"

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
        @RequiresApi(Build.VERSION_CODES.M)
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_OFF -> {
                    if (isMasterSwitchOn) {
                        handler.postDelayed({
                            showCarouselOnLockScreen()
                        }, 100)
                    }
                }
            }
        }
    }

    /**
     * 活动创建时的初始化
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 注册屏幕状态广播接收器
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        registerReceiver(screenReceiver, filter)

        // 如果主开关已经开启，确保锁屏监听正常工作
        if (isMasterSwitchOn) {
            enableLockScreen()
        }
    }

    /**
     * 活动销毁时的清理
     */
    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(screenReceiver)
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
//                "openCarouselActivity" -> {
//                    val intent = Intent(this, CarouselContainerActivity::class.java)
//                    startActivity(intent)
//                    result.success(null)
//                }
                "openContainer" -> {
                    val intent = Intent(this, ContainerActivity::class.java)
                    startActivity(intent)
                    result.success(null)
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
//                "openContainer" -> {
//                    try {
//                        val intent = Intent(this, CarouselContainerActivity::class.java)
//                        startActivity(intent)
//                        result.success(null)
//                    } catch (e: Exception) {
//                        result.error("NAVIGATION_ERROR", e.message, null)
//                    }
//                }
                "openContainer" -> {
                    val intent = Intent(this, ContainerActivity::class.java)
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LUNAR_CALENDAR_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getLunarDate") {
                result.success(null)  // Flutter 端会处理日期计算
            } else {
                result.notImplemented()
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

    private fun openCarousel() {
        val intent = Intent(this, CarouselContainerActivity::class.java)
        startActivity(intent)
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun showCarouselOnLockScreen() {
        val intent = Intent(this, CarouselContainerActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK
                or Intent.FLAG_ACTIVITY_CLEAR_TOP
                or Intent.FLAG_ACTIVITY_NO_ANIMATION
                or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                or Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
            putExtra("from_lock_screen", true)
        }
        
        try {
            // 使用 startActivity 的重载方法，添加选项
            startActivity(intent, ActivityOptions.makeBasic().toBundle())
        } catch (e: Exception) {
            e.printStackTrace()
            // 尝试使用替代方法
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            val wakeLock = powerManager.newWakeLock(
                PowerManager.FULL_WAKE_LOCK
                or PowerManager.ACQUIRE_CAUSES_WAKEUP
                or PowerManager.ON_AFTER_RELEASE, "flutter_screen_clock:WakeLock"
            )
            wakeLock.acquire(10*1000L) // 10秒后自动释放
            
            startActivity(intent)
            wakeLock.release()
        }
    }
}