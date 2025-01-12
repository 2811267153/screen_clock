import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
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
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.DisplayMetrics
import android.util.Log
import android.widget.LinearLayout
import com.example.flutter_screen_clock.R
import androidx.dynamicanimation.animation.SpringAnimation
import androidx.dynamicanimation.animation.SpringForce
import android.view.animation.AlphaAnimation
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.Animation
import io.flutter.plugins.sharedpreferences.TAG

class NotificationActivity : Fragment() {
    private lateinit var verticalAppIconView: ImageView
    private lateinit var verticalAppName: TextView
    private lateinit var verticalTitle: TextView
    private lateinit var verticalText: TextView
    private lateinit var notificationContainer: LinearLayout
    private lateinit var notificationTextContainer: LinearLayout
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001
//    private val handler = Handler(Looper.getMainLooper())
    private var pendingNotificationCount = 0  // 添加计数器
    private val layoutSwitchLock = Object()   // 添加锁对象
    private val notificationStack = mutableListOf<StatusBarNotification>()  // 将队列改为栈结构，使用 ArrayList 实现
    private var isProcessingNotifications = false  // 添加处理状态标记
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.activity_notification, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // 初始化视图
        notificationContainer = view.findViewById(R.id.notificationContainer)
        notificationTextContainer = view.findViewById(R.id.notificationTextContainer)
        verticalAppIconView = view.findViewById(R.id.verticalAppIconView)
        verticalAppName = view.findViewById(R.id.verticalAppName)
        verticalTitle = view.findViewById(R.id.verticalTitle)
        verticalText = view.findViewById(R.id.verticalText)

        // 检查通知访问权限
        if (!isNotificationServiceEnabled()) {
            verticalAppName.text = "通知监听"
            verticalTitle.text = "请授予通知访问权限"
            requestNotificationPermission()
        } else {
            NotificationListenerService.setNotificationActivity(this)
        }
    }

    private fun switchToHorizontalLayout() {
        activity?.runOnUiThread {
            try {
                // 创建动画
                val fadeOut = AlphaAnimation(1f, 0f)
                fadeOut.duration = 300
                fadeOut.interpolator = AccelerateInterpolator()

                val fadeIn = AlphaAnimation(0f, 1f)
                fadeIn.duration = 300
                fadeIn.interpolator = DecelerateInterpolator()
                fadeIn.startOffset = 300 // 等待淡出动画完成

                // 设置淡出动画结束后的操作
                fadeOut.setAnimationListener(object : Animation.AnimationListener {
                    override fun onAnimationStart(animation: Animation?) {}
                    override fun onAnimationRepeat(animation: Animation?) {}
                    override fun onAnimationEnd(animation: Animation?) {
                        // 切换到水平布局
                        notificationContainer.orientation = LinearLayout.HORIZONTAL

                        // 调整图标大小和边距
                        val iconParams = verticalAppIconView.layoutParams as LinearLayout.LayoutParams
                        iconParams.width = resources.getDimensionPixelSize(R.dimen.icon_size_horizontal)
                        iconParams.height = resources.getDimensionPixelSize(R.dimen.icon_size_horizontal)
                        iconParams.setMargins(0, 0, resources.getDimensionPixelSize(R.dimen.icon_margin_end), 0)
                        verticalAppIconView.layoutParams = iconParams

                        // 调整文本容器
                        val textContainerParams = notificationTextContainer.layoutParams as LinearLayout.LayoutParams
                        textContainerParams.setMargins(0, 0, 0, 0)  // 水平布局时清除所有边距
                        notificationTextContainer.layoutParams = textContainerParams

                        // 开始淡入动画
                        notificationContainer.startAnimation(fadeIn)
                    }
                })

                // 开始淡出动画
                notificationContainer.startAnimation(fadeOut)

            } catch (e: Exception) {
                Log.e("NotificationDebug", "Error switching to horizontal layout", e)
                e.printStackTrace()
            }
        }
    }

    // 更新通知的方法
//    fun updateNotification(sbn: StatusBarNotification) {
//        synchronized(layoutSwitchLock) {
//            // 将新通知添加到栈顶（列表开头）
//            notificationStack.add(0, sbn)
//
//            // 如果正在处理通知，中断当前处理
//            if (isProcessingNotifications) {
//                handler.removeCallbacksAndMessages(null)  // 移除所有待处理的回调
//                isProcessingNotifications = false
//            }
//
//            // 开始处理新的通知序列
//            processNextNotification()
//        }
//    }
    private val notificationQueue: Queue<StatusBarNotification> = LinkedList()
    fun updateNotification(sbn: StatusBarNotification) {
        synchronized(layoutSwitchLock) {
            notificationStack.clear() // 清空队列，确保只有最新通知
            notificationStack.add(sbn)
            Log.d("NotificationDebug", "Cleared stack and added new notification: ${sbn.packageName}")

            handler.removeCallbacksAndMessages(null) // 移除所有延迟任务
            processNextNotification() // 立即处理
        }
    }




//    private fun processNextNotification() {
//        synchronized(layoutSwitchLock) {
//            if (notificationStack.isEmpty()) {
//                isProcessingNotifications = false
//                return
//            }
//
//            isProcessingNotifications = true
//            // 获取栈顶（最新）的通知
//            val sbn = notificationStack[0]
//
//            try {
//                val notification = sbn.notification
//                val extras = notification.extras
//
//                activity?.runOnUiThread {
//                    try {
//                        // 重置为垂直布局
//                        notificationContainer.orientation = LinearLayout.VERTICAL
//
//                        // 重置图标大小和边距
//                        val iconParams = verticalAppIconView.layoutParams as LinearLayout.LayoutParams
//                        iconParams.width = resources.getDimensionPixelSize(R.dimen.icon_size_vertical)
//                        iconParams.height = resources.getDimensionPixelSize(R.dimen.icon_size_vertical)
//                        iconParams.setMargins(0, 0, 0, 0)
//                        verticalAppIconView.layoutParams = iconParams
//
//                        // 重置文本容器的边距
//                        val textContainerParams = notificationTextContainer.layoutParams as LinearLayout.LayoutParams
//                        textContainerParams.setMargins(0, resources.getDimensionPixelSize(R.dimen.text_container_margin_top), 0, 0)
//                        notificationTextContainer.layoutParams = textContainerParams
//
//                        // 更新UI内容
//                        val appName = context?.packageManager?.getApplicationLabel(
//                            context?.packageManager?.getApplicationInfo(sbn.packageName, 0)!!
//                        ) ?: ""
//
//                        val title = extras.getString(Notification.EXTRA_TITLE, "")
//                        val text = extras.getString(Notification.EXTRA_TEXT, "")
//                        val icon = context?.packageManager?.getApplicationIcon(sbn.packageName)
//
//                        notificationContainer.visibility = View.VISIBLE
//                        verticalAppName.text = appName.toString()
//                        verticalTitle.text = title
//                        verticalText.text = text
//                        verticalAppIconView.setImageDrawable(icon)
//
//                        // 检查是否还有更多通知
//                        if (notificationStack.size == 1) {
//                            // 是最后一条，延迟切换到水平布局
//                            handler.postDelayed({
//                                synchronized(layoutSwitchLock) {
//                                    if (notificationStack.size == 1) {
//                                        switchToHorizontalLayout()
//                                        notificationStack.removeAt(0)
//                                        isProcessingNotifications = false
//                                    }
//                                }
//                            }, 3000)
//                        } else {
//                            // 还有更多通知，延迟显示下一条
//                            handler.postDelayed({
//                                synchronized(layoutSwitchLock) {
//                                    if (!notificationStack.isEmpty()) {
//                                        notificationStack.removeAt(0)  // 移除当前显示的通知
//                                        processNextNotification()  // 处理下一条
//                                    }
//                                }
//                            }, 3000)
//                        }
//
//                    } catch (e: Exception) {
//                        Log.e("NotificationDebug", "Error updating UI", e)
//                        e.printStackTrace()
//                        synchronized(layoutSwitchLock) {
//                            if (!notificationStack.isEmpty()) {
//                                notificationStack.removeAt(0)
//                                processNextNotification()
//                            }
//                        }
//                    }
//                }
//            } catch (e: Exception) {
//                Log.e("NotificationDebug", "Error processing notification", e)
//                e.printStackTrace()
//                synchronized(layoutSwitchLock) {
//                    if (!notificationStack.isEmpty()) {
//                        notificationStack.removeAt(0)
//                        processNextNotification()
//                    }
//                }
//            }
//        }
//    }



    private fun processNextNotification() {
        synchronized(layoutSwitchLock) {
            if (notificationStack.isEmpty()) {
                isProcessingNotifications = false
                Log.d("NotificationDebug", "Notification stack empty, stopping processing.")
                return
            }

            isProcessingNotifications = true
            val sbn = notificationStack.removeAt(0) // 取出队列的第一条通知
            Log.d("NotificationDebug", "Processing notification: ${sbn.packageName}")

            try {
                val notification = sbn.notification
                val extras = notification.extras

                activity?.runOnUiThread {
                    try {
                        // 设置为垂直布局
                        notificationContainer.orientation = LinearLayout.VERTICAL

                        // 更新图标和文本
                        val appName = context?.packageManager?.getApplicationLabel(
                            context?.packageManager?.getApplicationInfo(sbn.packageName, 0)!!
                        ) ?: ""
                        val title = extras.getString(Notification.EXTRA_TITLE, "")
                        val text = extras.getString(Notification.EXTRA_TEXT, "")
                        val icon = context?.packageManager?.getApplicationIcon(sbn.packageName)

                        verticalAppName.text = appName.toString()
                        verticalTitle.text = title
                        verticalText.text = text
                        verticalAppIconView.setImageDrawable(icon)
                        notificationContainer.visibility = View.VISIBLE

                        // 延迟切换或处理下一条
                        handler.postDelayed({
                            synchronized(layoutSwitchLock) {
                                if (notificationStack.isEmpty()) {
                                    Log.d("NotificationDebug", "Switching to horizontal layout.")
                                    switchToHorizontalLayout()
                                    isProcessingNotifications = false
                                } else {
                                    processNextNotification()
                                }
                            }
                        }, 3000) // 3 秒延迟
                    } catch (e: Exception) {
                        Log.e("NotificationDebug", "Error updating UI", e)
                        handleError()
                    }
                }
            } catch (e: Exception) {
                Log.e("NotificationDebug", "Error processing notification", e)
                handleError()
            }
        }
    }
    private fun handleError() {
        synchronized(layoutSwitchLock) {
            if (notificationStack.isNotEmpty()) {
                notificationStack.removeAt(0)
                processNextNotification()
            } else {
                isProcessingNotifications = false
            }
        }
    }


    // 错误处理的辅助方法
    private fun handleUIError() {
        synchronized(layoutSwitchLock) {
            if (notificationStack.isNotEmpty()) {
                notificationStack.removeAt(0) // 移除当前通知
                processNextNotification() // 继续处理下一条
            } else {
                isProcessingNotifications = false
            }
        }
    }


//    fun onNotificationRemoved(sbn: StatusBarNotification) {
//        Log.d(TAG, "Notification Removed: ${sbn.packageName}")
//        notificationActivity?.onNotificationRemoved(sbn)
//    }

    
    private fun isNotificationServiceEnabled(): Boolean {
        try {
            // 检查基本的通知监听权限
            val pkgName = requireContext().packageName
            val flat = Settings.Secure.getString(requireContext().contentResolver,
                "enabled_notification_listeners")
            val hasPermission = flat != null && flat.contains(pkgName)
            
            Log.d("NotificationDebug", "Notification permission status: $hasPermission")
            return hasPermission
        } catch (e: Exception) {
            Log.e("NotificationDebug", "Error checking notification permission", e)
            return false
        }
    }

    private fun requestNotificationPermission() {
        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
        startActivityForResult(intent, NOTIFICATION_PERMISSION_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
            view?.postDelayed({
                checkAndUpdatePermissionStatus()
            }, 500)
        }
    }

    private fun checkAndUpdatePermissionStatus() {
        if (isNotificationServiceEnabled()) {
            NotificationListenerService.setNotificationActivity(this)
            verticalAppName.text = "等待通知..."
            verticalTitle.text = ""
            verticalText.text = ""
        } else {
            verticalAppName.text = "通知监听"
            verticalTitle.text = "请授予通知访问权限"
            verticalText.text = ""
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        NotificationListenerService.setNotificationActivity(null)
    }

    override fun onResume() {
        super.onResume()
        checkAndUpdatePermissionStatus()
    }
}
