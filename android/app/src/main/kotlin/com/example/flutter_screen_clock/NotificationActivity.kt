import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.Fragment
import java.text.SimpleDateFormat
import java.util.*
import android.service.notification.StatusBarNotification
import android.app.Notification
import com.example.flutter_screen_clock.notification.NotificationListenerService
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.util.DisplayMetrics
import android.util.Log
import androidx.constraintlayout.widget.ConstraintLayout
import com.example.flutter_screen_clock.R

class NotificationActivity : Fragment() {
    private lateinit var appNameText: TextView
    private lateinit var contentText: TextView
    private lateinit var timeText: TextView
    private lateinit var appIconView: ImageView
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001
    private var notificationCount = 0
    private lateinit var notificationLayout: ConstraintLayout


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        Log.d("NotificationDebug", "onCreateView called")
        val view = inflater.inflate(R.layout.activity_notification, container, false)
        Log.d("NotificationDebug", "View inflated: $view")
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Log.d("NotificationDebug", "onViewCreated called")
        val displayMetrics = DisplayMetrics()
        notificationLayout = view.findViewById<ConstraintLayout>(R.id.notificationLayout)
        requireActivity().windowManager.defaultDisplay.getMetrics(displayMetrics)
        val screenHeight = displayMetrics.heightPixels
        notificationLayout.translationY = screenHeight.toFloat()
//        notificationCountText = view.findViewById(R.id.notificationCountText)

        try {
            // 初始化视图
            appNameText = view.findViewById(R.id.appNameText)
            contentText = view.findViewById(R.id.contentText)
            timeText = view.findViewById(R.id.timeText)
            appIconView = view.findViewById(R.id.appIconView)
            notificationLayout = view.findViewById<ConstraintLayout>(R.id.notificationLayout)

            // 获取屏幕高度
            val displayMetrics = DisplayMetrics()
            requireActivity().windowManager.defaultDisplay.getMetrics(displayMetrics)
            val screenHeight = displayMetrics.heightPixels

            // 设置初始位置在屏幕外
            notificationLayout.translationY = screenHeight.toFloat()


            // 检查通知访问权限
            if (!isNotificationServiceEnabled()) {
                // 显示一些默认内容
                appNameText.text = "通知监听"
                contentText.text = "请授予通知访问权限"
                timeText.text = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())

                // 引导用户开启权限
                requestNotificationPermission()
            } else {
                // 注册到通知监听服务
                NotificationListenerService.setNotificationActivity(this)
            }

        } catch (e: Exception) {
            Log.e("NotificationDebug", "Error initializing views", e)
        }
    }

    private fun animateNotificationIn() {
        Log.d("NotificationDebug", "animateNotificationIn called")
        val views = listOf(appIconView, appNameText, contentText, timeText)
        
        views.forEachIndexed { index, view ->
            Log.d("NotificationDebug", "Animating view $index: ${view.id}")
            view.alpha = 0f
            view.translationY = 100f
            
            view.animate()
                .alpha(1f)
                .translationY(0f)
                .setDuration(500)
                .setStartDelay(index * 100L)
                .setInterpolator(android.view.animation.DecelerateInterpolator())
                .withStartAction {
                    Log.d("NotificationDebug", "Animation started for view $index")
                }
                .withEndAction {
                    Log.d("NotificationDebug", "Animation ended for view $index")
                }
                .start()
        }
    }

    private fun animateNotificationOut() {
        val views = listOf(timeText, contentText, appNameText, appIconView)
        
        views.forEachIndexed { index, view ->
            view.animate()
                .alpha(0f)
                .translationY(100f)
                .setDuration(500)
                .setStartDelay(index * 50L)  // 错开动画开始时间
                .setInterpolator(android.view.animation.AccelerateInterpolator())
                .start()
        }
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val pkgName = requireContext().packageName
        val flat = Settings.Secure.getString(requireContext().contentResolver,
            "enabled_notification_listeners")
        return flat != null && flat.contains(pkgName)
    }

    private fun requestNotificationPermission() {
        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
        startActivityForResult(intent, NOTIFICATION_PERMISSION_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
            // 用户从设置页面返回，延迟检查权限状态
            view?.postDelayed({
                checkAndUpdatePermissionStatus()
            }, 500) // 延迟500ms，确保系统设置已经保存
        }
    }

    private fun checkAndUpdatePermissionStatus() {
        if (isNotificationServiceEnabled()) {
            // 有权限，注册到服务
            NotificationListenerService.setNotificationActivity(this)
            // 更新UI显示等待通知状态
            appNameText.text = "等待通知..."
            contentText.text = ""
            timeText.text = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
        } else {
            // 没有权限，显示提示
            appNameText.text = "通知监听"
            contentText.text = "请授予通知访问权限"
            timeText.text = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
        }
    }

    // 更新通知的方法
    fun updateNotification(sbn: StatusBarNotification) {
        try {
            Log.d("NotificationDebug", "updateNotification called")
            activity?.runOnUiThread {
                try {
                    // 获取应用名称
                    val appName = context?.packageManager?.getApplicationLabel(
                        context?.packageManager?.getApplicationInfo(sbn.packageName, 0)!!
                    ) ?: ""

                    // 获取通知内容
                    val title = sbn.notification.extras.getString(Notification.EXTRA_TITLE, "")
                    val text = sbn.notification.extras.getString(Notification.EXTRA_TEXT, "")

                    // 获取应用图标
                    val icon = context?.packageManager?.getApplicationIcon(sbn.packageName)

                    // 更新UI
                    appNameText.text = appName.toString()
                    contentText.text = if (title.isNullOrEmpty()) text else "$title: $text"
                    timeText.text = SimpleDateFormat("HH:mm", Locale.getDefault())
                        .format(Date(sbn.postTime))
                    appIconView.setImageDrawable(icon)

                    Log.d("NotificationDebug", "Updated notification: $appName - $title: $text")

                    // 检查视图的可见性状态
                    Log.d("NotificationDebug", "View visibility states:")
                    Log.d("NotificationDebug", "notificationLayout visibility: ${notificationLayout.visibility}")
                    Log.d("NotificationDebug", "appIconView visibility: ${appIconView.visibility}")
                    Log.d("NotificationDebug", "appNameText visibility: ${appNameText.visibility}")
                    
                    // 确保父布局可见
                    notificationLayout.visibility = View.VISIBLE
                    
                    // 触发进入动画
                    animateNotificationIn()
                } catch (e: Exception) {
                    Log.e("NotificationDebug", "Error in updateNotification", e)
                }
            }

            // 更新通知计数
            notificationCount++

        } catch (e: Exception) {
            Log.e("NotificationDebug", "Error processing notification", e)
        }
    }

    fun onNotificationRemoved(sbn: StatusBarNotification) {
        notificationCount--
        if (notificationCount < 0) {
            notificationCount = 0
        }

        // 如果没有通知了，触发退出动画
        if (notificationCount == 0) {
            animateNotificationOut()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        // 取消注册
        NotificationListenerService.setNotificationActivity(null)
    }

    override fun onResume() {
        super.onResume()
        // 在恢复时检查权限，但不自动弹出设置页面
        checkAndUpdatePermissionStatus()
    }
}
