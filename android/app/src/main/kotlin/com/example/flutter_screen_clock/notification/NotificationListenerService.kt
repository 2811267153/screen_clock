package com.example.flutter_screen_clock.notification

import NotificationActivity
import android.content.ComponentName
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import androidx.annotation.RequiresApi
import com.example.flutter_screen_clock.ContainerActivity


class NotificationListenerService : NotificationListenerService() {

    companion object {
        private const val TAG = "NotificationListener"
        private var instance: NotificationListenerService? = null
        private var notificationActivity: NotificationActivity? = null

        fun setNotificationActivity(activity: NotificationActivity?) {
            notificationActivity = activity
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "NotificationListenerService created")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d(TAG, "NotificationListenerService destroyed")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        Log.d("NotificationDebug", "onNotificationPosted called for package: ${sbn.packageName}")
        
        // 过滤系统通知和低优先级通知
        if (sbn.packageName.startsWith("android") || 
            sbn.packageName.startsWith("com.android") ||
            sbn.notification.priority < android.app.Notification.PRIORITY_DEFAULT) {
            Log.d("NotificationDebug", "Filtered out system or low priority notification")
            return
        }
        
        // 检查通知内容
        val notification = sbn.notification
        val extras = notification.extras
        val title = extras.getString(android.app.Notification.EXTRA_TITLE)
        val text = extras.getString(android.app.Notification.EXTRA_TEXT)
        Log.d("NotificationDebug", "Notification content - Title: $title, Text: $text")

        notificationActivity?.let {
            Log.d("NotificationDebug", "NotificationActivity is available")
            it.updateNotification(sbn)
            // 通知 ContainerActivity 显示通知
            (it.activity as? ContainerActivity)?.also { container ->
                Log.d("NotificationDebug", "ContainerActivity is available")
                container.handleNotification(true)
            } ?: Log.e("NotificationDebug", "ContainerActivity is null")
        } ?: Log.e("NotificationDebug", "NotificationActivity is null")
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("NotificationDebug", "NotificationListenerService connected")
    }

    @RequiresApi(Build.VERSION_CODES.N)
    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d("NotificationDebug", "NotificationListenerService disconnected")
        // 尝试重新连接服务
        requestRebind(ComponentName(this, NotificationListenerService::class.java))
    }
} 