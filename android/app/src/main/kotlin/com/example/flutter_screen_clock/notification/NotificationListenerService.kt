package com.example.flutter_screen_clock.notification

import NotificationActivity
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log


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
        Log.d(TAG, "Notification Posted: ${sbn.packageName}")
        
        try {
            // 过滤掉系统通知
            if (sbn.packageName.startsWith("android") || 
                sbn.packageName.startsWith("com.android")) {
                return
            }

            // 过滤掉通知优先级较低的通知
            if (sbn.notification.priority < android.app.Notification.PRIORITY_DEFAULT) {
                return
            }

            // 更新通知界面
            notificationActivity?.updateNotification(sbn)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error processing notification", e)
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        Log.d(TAG, "Notification Removed: ${sbn.packageName}")
        notificationActivity?.onNotificationRemoved(sbn)
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "Notification Listener Connected")
        
        // 获取当前通知
        try {
            val notifications = activeNotifications
            if (notifications.isNotEmpty()) {
                // 显示最新的通知
                notificationActivity?.updateNotification(notifications.last())
                Log.d(TAG, "Found ${notifications.size} active notifications")
            } else {
                Log.d(TAG, "No active notifications")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting active notifications", e)
        }
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d(TAG, "Notification Listener Disconnected")
    }
} 