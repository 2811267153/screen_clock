package com.example.flutter_screen_clock.notification

import NotificationActivity
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
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
        Log.d("NotificationDebug", "onNotificationPosted called")
        notificationActivity?.let {
            Log.d("NotificationDebug", "Updating notification activity")
            it.updateNotification(sbn)
            // 通知 ContainerActivity 显示通知
            (it.activity as? ContainerActivity)?.handleNotification(true)
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