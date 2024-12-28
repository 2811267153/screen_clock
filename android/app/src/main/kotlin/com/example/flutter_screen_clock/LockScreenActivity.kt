package com.example.flutter_screen_clock

import android.app.KeyguardManager
import android.content.Context
import android.os.Bundle
import android.view.KeyEvent
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity

class LockScreenActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        println("LockScreenActivity onCreate")

        // 设置窗口为透明背景
        window.setBackgroundDrawableResource(android.R.color.transparent)
        
        // 设置锁屏相关标志
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
        )

        setContentView(R.layout.activity_lock_screen)

        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        keyguardManager.requestDismissKeyguard(this, null)
    }

    // 处理返回键和菜单键
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        return when (event?.keyCode) {
            KeyEvent.KEYCODE_BACK -> true  // 禁用返回键
            KeyEvent.KEYCODE_MENU -> true  // 禁用菜单键
            else -> super.onKeyDown(keyCode, event)
        }
    }

    // 当活动不可见时（比如用户解锁屏幕）
    override fun onStop() {
        super.onStop()
        if (!isFinishing) {
            finish()
        }
    }
} 