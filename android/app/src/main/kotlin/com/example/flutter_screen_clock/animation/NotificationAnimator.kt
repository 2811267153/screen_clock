package com.example.flutter_screen_clock.animation

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewTreeObserver
import android.view.animation.PathInterpolator
import android.widget.LinearLayout
import android.widget.ImageView
import android.widget.TextView
import com.example.flutter_screen_clock.R

class NotificationAnimator(
    private val context: Context,
    private val notificationLayout: LinearLayout
) {
    private var currentAnimatorSet: AnimatorSet? = null
    private var isAnimating = false
    private var animationCallback: AnimationCallback? = null
    private val screenMetrics = context.resources.displayMetrics

    private lateinit var appIconView: ImageView
    private lateinit var appNameView: TextView
    private lateinit var titleView: TextView
    private lateinit var textView: TextView
    private lateinit var textContainer: LinearLayout

    init {
        try {
            // 初始化视图引用
            appIconView = notificationLayout.findViewById<ImageView>(R.id.verticalAppIconView).also {
                Log.d("AnimatorDebug", "appIconView initialized: ${it != null}")
            }
            textContainer = notificationLayout.findViewById<LinearLayout>(R.id.notificationTextContainer).also {
                Log.d("AnimatorDebug", "textContainer initialized: ${it != null}")
            }
            appNameView = notificationLayout.findViewById<TextView>(R.id.verticalAppName).also {
                Log.d("AnimatorDebug", "appNameView initialized: ${it != null}")
            }
            titleView = notificationLayout.findViewById<TextView>(R.id.verticalTitle).also {
                Log.d("AnimatorDebug", "titleView initialized: ${it != null}")
            }
            textView = notificationLayout.findViewById<TextView>(R.id.verticalText).also {
                Log.d("AnimatorDebug", "textView initialized: ${it != null}")
            }
        } catch (e: Exception) {
            Log.e("AnimatorDebug", "Error initializing views", e)
        }
    }

    interface AnimationCallback {
        fun onAnimationStart()
        fun onAnimationEnd()
    }

    fun setAnimationCallback(callback: AnimationCallback) {
        animationCallback = callback
    }

    fun resetNotificationView() {
        Log.d("AnimatorDebug", "resetNotificationView called")
        
        // 立即取消当前动画
        cancelAnimation()
        
        // 使用同步锁确保动画状态的一致性
        synchronized(this) {
            isAnimating = false
            currentAnimatorSet = null
        }
        
        notificationLayout.viewTreeObserver.addOnPreDrawListener(object : ViewTreeObserver.OnPreDrawListener {
            override fun onPreDraw(): Boolean {
                if (notificationLayout.height == 0) {
                    return true
                }
                
                notificationLayout.viewTreeObserver.removeOnPreDrawListener(this)
                
                val screenHeight = screenMetrics.heightPixels
                Log.d("AnimatorDebug", "Screen height: $screenHeight")
                
                try {
                    // 设置容器位置
                    val centerY = (screenHeight - notificationLayout.height) / 2f
                    notificationLayout.y = centerY
                    notificationLayout.visibility = View.VISIBLE
                    notificationLayout.alpha = 1f
                    Log.d("AnimatorDebug", "Container set to centerY: $centerY")
                    
                    // 重置所有子视图位置
                    val startY = screenHeight.toFloat()
                    Log.d("AnimatorDebug", "Setting start position for views: $startY")
                    
                    // 强制重置所有视图的位置
                    arrayOf(appIconView, textContainer, appNameView, titleView, textView).forEachIndexed { index, view ->
                        view.apply {
                            translationY = startY
                            alpha = 1f
                            Log.d("AnimatorDebug", "View $index reset - translationY: $translationY")
                        }
                    }
                    
                    // 确保视图位置已经更新后再开始动画
                    notificationLayout.post {
                        // 再次检查位置是否正确设置
                        arrayOf(appIconView, textContainer, appNameView, titleView, textView).forEachIndexed { index, view ->
                            Log.d("AnimatorDebug", "Before animation - View $index position: ${view.translationY}")
                            // 确保位置正确
                            if (view.translationY != startY) {
                                view.translationY = startY
                            }
                        }
                        
                        // 等待下一帧再开始动画
                        notificationLayout.postOnAnimation {
                            synchronized(this@NotificationAnimator) {
                                if (!isAnimating) {
                                    startNotificationAnimation()
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.e("AnimatorDebug", "Error in resetNotificationView", e)
                }
                
                return true
            }
        })
    }

    fun startNotificationAnimation() {
        synchronized(this) {
            if (isAnimating || notificationLayout.height == 0) {
                Log.d("AnimatorDebug", "Animation skipped - isAnimating: $isAnimating, height: ${notificationLayout.height}")
                return
            }
            isAnimating = true
        }

        try {
            Log.d("AnimatorDebug", "Starting animation sequence")
            
            // 检查所有视图的起始位置
            arrayOf(appIconView, textContainer, appNameView, titleView, textView).forEachIndexed { index, view ->
                val position = view.translationY
                Log.d("AnimatorDebug", "Animation start - View $index position: $position")
                if (position == 0f) {
                    // 如果位置不正确，跳过动画
                    synchronized(this) {
                        isAnimating = false
                        currentAnimatorSet = null
                    }
                    return
                }
            }
            
            currentAnimatorSet = AnimatorSet().apply {
                val totalDuration = 800L
                val singleDuration = 400f
                
                // 创建所有动画
                val animations = listOf(
                    appIconView to 0f,
                    textContainer to 100f,
                    appNameView to 200f,
                    titleView to 300f,
                    textView to 400f
                ).map { (view, delay) ->
                    createElementAnimation(view, delay, singleDuration).also {
                        Log.d("AnimatorDebug", "Created animation - from: ${view.translationY}, delay: $delay")
                    }
                }

                playTogether(*animations.toTypedArray())
                duration = totalDuration

                addListener(object : AnimatorListenerAdapter() {
                    override fun onAnimationStart(animation: Animator) {
                        Log.d("AnimatorDebug", "Animation sequence started")
                    }
                    
                    override fun onAnimationEnd(animation: Animator) {
                        Log.d("AnimatorDebug", "Animation sequence completed")
                        synchronized(this@NotificationAnimator) {
                            isAnimating = false
                            currentAnimatorSet = null
                        }
                    }
                })
                start()
            }
        } catch (e: Exception) {
            Log.e("AnimatorDebug", "Error during animation", e)
            synchronized(this) {
                isAnimating = false
                currentAnimatorSet = null
            }
        }
    }

    private fun createElementAnimation(view: View, startDelay: Float, duration: Float): Animator {
        return ObjectAnimator.ofFloat(view, "translationY", view.translationY, 0f).apply {
            interpolator = PathInterpolator(0.2f, 1f, 0.33f, 1f)
            this.startDelay = startDelay.toLong()
            this.duration = duration.toLong()
        }
    }

    fun startFadeOutAnimation(onComplete: () -> Unit) {
        AnimatorSet().apply {
            playTogether(
                ObjectAnimator.ofFloat(notificationLayout, "alpha", notificationLayout.alpha, 0f)
            )
            duration = 150
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    onComplete()
                }
            })
            start()
        }
    }

    fun cancelAnimation() {
        currentAnimatorSet?.cancel()
        currentAnimatorSet = null
    }

    fun isAnimating() = isAnimating
}