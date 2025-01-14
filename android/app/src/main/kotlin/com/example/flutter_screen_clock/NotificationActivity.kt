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
import com.example.flutter_screen_clock.animation.NotificationAnimator
import android.graphics.Bitmap
import android.graphics.Canvas
import android.widget.FrameLayout

class NotificationActivity : Fragment() {
    private lateinit var verticalAppIconView: ImageView
    private lateinit var verticalAppName: TextView
    private lateinit var verticalTitle: TextView
    private lateinit var verticalText: TextView
    private lateinit var notificationContainer: LinearLayout
    private lateinit var notificationTextContainer: LinearLayout
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001
    private val layoutSwitchLock = Object()   // 添加锁对象
    private val notificationStack = mutableListOf<StatusBarNotification>()  // 将队列改为栈结构，使用 ArrayList 实现
    private var isProcessingNotifications = false  // 添加处理状态标记
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var notificationAnimator: NotificationAnimator
    private var currentNotificationTitle: String = ""
    private var currentNotificationText: String = ""
    private var currentAppName: String = ""

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

        // 初始化动画器
        notificationAnimator = NotificationAnimator(requireContext(), notificationContainer)
    }

    private fun switchToHorizontalLayout() {
        activity?.runOnUiThread {
            try {
                val fadeOut = AlphaAnimation(1f, 0f)
                fadeOut.duration = 300
                fadeOut.interpolator = AccelerateInterpolator()

                val fadeIn = AlphaAnimation(0f, 1f)
                fadeIn.duration = 300
                fadeIn.interpolator = DecelerateInterpolator()
                fadeIn.startOffset = 300

                fadeOut.setAnimationListener(object : Animation.AnimationListener {
                    override fun onAnimationStart(animation: Animation?) {}
                    override fun onAnimationRepeat(animation: Animation?) {}
                    override fun onAnimationEnd(animation: Animation?) {
                        // 切换到水平布局
                        notificationContainer.orientation = LinearLayout.HORIZONTAL
                        
                        // 调整容器在父布局中的位置
                        val containerParams = notificationContainer.layoutParams as FrameLayout.LayoutParams
                        containerParams.apply {
                            gravity = android.view.Gravity.START or android.view.Gravity.BOTTOM  // 设置为左下
                            setMargins(
                                resources.getDimensionPixelSize(R.dimen.notification_margin_start),  // 左边距
                                0,  // 上边距
                                0,  // 右边距
                                resources.getDimensionPixelSize(R.dimen.notification_margin_bottom)   // 下边距
                            )
                        }
                        notificationContainer.layoutParams = containerParams
                        
                        // 调整图标布局参数
                        val iconParams = verticalAppIconView.layoutParams as LinearLayout.LayoutParams
                        iconParams.width = resources.getDimensionPixelSize(R.dimen.icon_size_horizontal)
                        iconParams.height = resources.getDimensionPixelSize(R.dimen.icon_size_horizontal)
                        iconParams.setMargins(0, 0, resources.getDimensionPixelSize(R.dimen.icon_margin_end), 0)
                        verticalAppIconView.layoutParams = iconParams

                        // 调整文本容器
                        notificationTextContainer.gravity = android.view.Gravity.START
                        val textContainerParams = notificationTextContainer.layoutParams as LinearLayout.LayoutParams
                        textContainerParams.setMargins(0, 0, 0, 0)
                        textContainerParams.width = LinearLayout.LayoutParams.MATCH_PARENT  // 确保宽度为 match_parent
                        notificationTextContainer.layoutParams = textContainerParams

                        // 调整文本对齐方式
                        verticalAppName.gravity = android.view.Gravity.START
                        verticalTitle.gravity = android.view.Gravity.START
                        verticalText.gravity = android.view.Gravity.START

                        // 显示所有组件并设置实际内容
                        verticalTitle.visibility = View.VISIBLE
                        
                        Log.d("NotificationDebug", "Setting horizontal layout content - Title: $currentNotificationTitle, Text: $currentNotificationText")
                        
                        // 使用保存的通知内容
                        verticalAppName.text = currentAppName
                        verticalTitle.text = currentNotificationTitle
                        verticalText.text = currentNotificationText

                        // 调整文本大小和间距
                        verticalAppName.apply {
                            textSize = resources.getDimension(R.dimen.text_size_h_app_name)
                            setPadding(0, 0, 0, resources.getDimensionPixelSize(R.dimen.text_margin_h_bottom))
                        }

                        verticalTitle.apply {
                            textSize = resources.getDimension(R.dimen.text_size_h_title)
                            setPadding(0, 0, 0, resources.getDimensionPixelSize(R.dimen.text_margin_h_bottom))
                        }

                        verticalText.apply {
                            textSize = resources.getDimension(R.dimen.text_size_h_text)
                        }

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


    fun updateNotification(sbn: StatusBarNotification) {
        synchronized(layoutSwitchLock) {
            notificationStack.clear() // 清空队列，确保只有最新通知
            notificationStack.add(sbn)
            Log.d("NotificationDebug", "Cleared stack and added new notification: ${sbn.packageName}")

            handler.removeCallbacksAndMessages(null) // 移除所有延迟任务
            processNextNotification() // 立即处理
        }
    }

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
                        
                        // 更新UI内容
                        updateNotificationContent(sbn, extras)

                        // 重置并开始动画
                        notificationAnimator.resetNotificationView()
                        notificationAnimator.startNotificationAnimation()

                        // 延迟切换或处理下一条
                        handler.postDelayed({
                            synchronized(layoutSwitchLock) {
                                if (notificationStack.isEmpty()) {
                                    switchToHorizontalLayout()
                                    isProcessingNotifications = false
                                } else {
                                    processNextNotification()
                                }
                            }
                        }, 3000)
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
        notificationAnimator.cancelAnimation()
        NotificationListenerService.setNotificationActivity(null)
    }

    override fun onResume() {
        super.onResume()
        checkAndUpdatePermissionStatus()
    }

    private fun updateNotificationContent(sbn: StatusBarNotification, extras: Bundle) {
        try {
            // 重置容器位置为居中
            val containerParams = notificationContainer.layoutParams as FrameLayout.LayoutParams
            containerParams.apply {
                gravity = android.view.Gravity.CENTER  // 重置为居中
                setMargins(0, 0, 0, 0)  // 清除所有边距
            }
            notificationContainer.layoutParams = containerParams

            // 首先重置布局参数为垂直布局的尺寸
            val iconParams = verticalAppIconView.layoutParams as LinearLayout.LayoutParams
            iconParams.width = resources.getDimensionPixelSize(R.dimen.icon_size_vertical)
            iconParams.height = resources.getDimensionPixelSize(R.dimen.icon_size_vertical)
            iconParams.setMargins(0, 0, 0, 0)  // 清除水平布局时设置的margin
            verticalAppIconView.layoutParams = iconParams

            // 重置文本容器的布局参数
            notificationTextContainer.gravity = android.view.Gravity.CENTER  // 重置为居中对齐
            val textContainerParams = notificationTextContainer.layoutParams as LinearLayout.LayoutParams
            textContainerParams.setMargins(0, resources.getDimensionPixelSize(R.dimen.text_container_margin_top), 0, 0)
            notificationTextContainer.layoutParams = textContainerParams

            // 重置文本组件的对齐方式和大小
            verticalAppName.apply {
                gravity = android.view.Gravity.CENTER
                textSize = resources.getDimension(R.dimen.text_size_v_app_name)
                setPadding(0, 0, 0, 0)
            }
            
            verticalTitle.apply {
                gravity = android.view.Gravity.CENTER
                textSize = resources.getDimension(R.dimen.text_size_v_title)
                setPadding(0, resources.getDimensionPixelSize(R.dimen.text_margin_v_top), 0, 0)
            }
            
            verticalText.apply {
                gravity = android.view.Gravity.CENTER
                textSize = resources.getDimension(R.dimen.text_size_v_text)
                setPadding(0, resources.getDimensionPixelSize(R.dimen.text_margin_v_top), 0, 0)
            }

            // 保存通知内容供水平布局使用
            currentNotificationTitle = extras.getString(Notification.EXTRA_TITLE, "")
            currentNotificationText = extras.getString(Notification.EXTRA_TEXT, "")
            currentAppName = context?.packageManager?.getApplicationLabel(
                context?.packageManager?.getApplicationInfo(sbn.packageName, 0)!!
            )?.toString() ?: ""
            
            Log.d("NotificationDebug", "Saved notification content - Title: $currentNotificationTitle, Text: $currentNotificationText")
            
            // 在垂直布局时隐藏标题，并显示固定文本
            verticalTitle.visibility = View.GONE
            verticalAppName.text = currentAppName
            verticalText.text = "1个通知内容"

            // 设置图标
            context?.packageManager?.getApplicationIcon(sbn.packageName)?.let { drawable ->
                // 创建一个固定大小的 Bitmap，使用垂直布局的尺寸
                val size = resources.getDimensionPixelSize(R.dimen.icon_size_vertical)
                val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bitmap)
                
                drawable.setBounds(0, 0, size, size)
                drawable.draw(canvas)
                
                verticalAppIconView.apply {
                    setImageBitmap(bitmap)
                    scaleType = ImageView.ScaleType.FIT_CENTER
                }
            }
        } catch (e: Exception) {
            Log.e("NotificationDebug", "Error updating notification content", e)
            throw e
        }
    }
}
