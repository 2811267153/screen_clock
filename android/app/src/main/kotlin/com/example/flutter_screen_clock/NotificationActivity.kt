import android.animation.ObjectAnimator
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
import android.widget.LinearLayout
import com.example.flutter_screen_clock.R
import androidx.dynamicanimation.animation.SpringAnimation
import androidx.dynamicanimation.animation.SpringForce

class NotificationActivity : Fragment() {
    private lateinit var appNameText: TextView
    private lateinit var contentText: TextView
    private lateinit var timeText: TextView
    private lateinit var appIconView: ImageView
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001
    private var notificationCount = 0
    private lateinit var notificationCountText: TextView
    private lateinit var notificationLayout: LinearLayout


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
        notificationLayout = view.findViewById<LinearLayout>(R.id.notificationLayout)
        requireActivity().windowManager.defaultDisplay.getMetrics(displayMetrics)
        val screenHeight = displayMetrics.heightPixels
        notificationLayout.translationY = screenHeight.toFloat()
        notificationCountText = view.findViewById(R.id.notificationCountText)

        try {
            // 初始化视图
            appNameText = view.findViewById(R.id.appNameText)
            contentText = view.findViewById(R.id.contentText)
            timeText = view.findViewById(R.id.timeText)
            appIconView = view.findViewById(R.id.appIconView)
            notificationLayout = view.findViewById<LinearLayout>(R.id.notificationLayout)

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
        val displayMetrics = DisplayMetrics()
        requireActivity().windowManager.defaultDisplay.getMetrics(displayMetrics)
        val screenHeight = displayMetrics.heightPixels
        notificationLayout.translationY = screenHeight.toFloat()

        val springAnimation = SpringAnimation(notificationLayout, SpringAnimation.TRANSLATION_Y)
        springAnimation.spring = SpringForce().apply {
            finalPosition = 0f
            stiffness = SpringForce.STIFFNESS_LOW
            dampingRatio = SpringForce.DAMPING_RATIO_LOW_BOUNCY
        }
        springAnimation.start()
        Log.d("NotificationDebug", "Starting animation in")
    }

    private fun animateNotificationOut() {
        val screenHeight = resources.displayMetrics.heightPixels
        val animator = ObjectAnimator.ofFloat(notificationLayout, "translationY", 0f, screenHeight.toFloat())
        animator.duration = 500
        animator.start()
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
            val notification = sbn.notification
            val extras = notification.extras

            activity?.runOnUiThread {
                try {
                    // 获取应用名称
                    val appName = context?.packageManager?.getApplicationLabel(
                        context?.packageManager?.getApplicationInfo(sbn.packageName, 0)!!
                    ) ?: ""

                    // 获取通知内容
                    val title = extras.getString(Notification.EXTRA_TITLE, "")
                    val text = extras.getString(Notification.EXTRA_TEXT, "")

                    // 获取应用图标
                    val icon = context?.packageManager?.getApplicationIcon(sbn.packageName)

                    // 更新UI
                    appNameText.text = appName.toString()
                    contentText.text = if (title.isNullOrEmpty()) text else "$title: $text"
                    timeText.text = SimpleDateFormat("HH:mm", Locale.getDefault())
                        .format(Date(sbn.postTime))
                    appIconView.setImageDrawable(icon)

                    Log.d("NotificationDebug", "Updated notification: $appName - $title: $text")
                } catch (e: Exception) {
                    Log.e("NotificationDebug", "Error updating UI", e)
                }
            }

            // 更新通知计数
            notificationCount++
            notificationCountText.text = "$notificationCount 个通知"

            // 不需要检测是否是第一个通知，只要检测到有新的通知直接触发动画
            animateNotificationIn()
        } catch (e: Exception) {
            Log.e("NotificationDebug", "Error processing notification", e)
        }
    }

    fun onNotificationRemoved(sbn: StatusBarNotification) {
        // 更新通知计数并可能动画移出
        notificationCount--
        if (notificationCount < 0) {
            notificationCount = 0
        }
        notificationCountText.text = "$notificationCount 个通知"

        // 如果没有通知了，动画移出
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
