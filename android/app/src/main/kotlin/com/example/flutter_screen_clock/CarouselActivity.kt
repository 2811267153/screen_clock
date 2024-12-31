package com.example.flutter_screen_clock

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import com.example.flutter_screen_clock.calendar.CalendarPageManager
import com.example.flutter_screen_clock.calendar.WeekComponent

class CarouselActivity : Fragment() {
    // ViewPager2 用于实现轮播效果
    private lateinit var viewPager: ViewPager2
    // 存放指示器小圆点的容器
    private lateinit var indicatorContainer: LinearLayout
    // 轮播页面总数
    private val pageCount = 4
    
    // 存储指示器小圆点的集合

    private val indicators = mutableListOf<ImageView>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // 记录日志，用于调试 Fragment 生命周期
        Log.d("CarouselDebug", "onCreateView called")
        // 加载轮播图的布局文件
        return inflater.inflate(R.layout.activity_fullscreen_carousel, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        Log.d("CarouselDebug", "onViewCreated called")

        try {
            // 初始化 ViewPager2 和指示器容器
            viewPager = view.findViewById(R.id.viewPager)
            indicatorContainer = view.findViewById(R.id.indicatorContainer)

            // 设置 ViewPager2 的适配器
            viewPager.adapter = CarouselAdapter()

            // 创建底部的指示器小圆点
//            createIndicators() //默认不显示

            // 监听页面切换事件，更新指示器状态
            viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
                override fun onPageSelected(position: Int) {
                    updateIndicators(position)
                }
            })

            Log.d("CarouselDebug", "ViewPager setup complete")
        } catch (e: Exception) {
            // 捕获并记录初始化过程中的任何错误
            Log.e("CarouselDebug", "Error setting up carousel: ${e.message}")
            e.printStackTrace()
        }
    }

    // 创建底部指示器小圆点
    private fun createIndicators() {
        for (i in 0 until pageCount) {
            val indicator = ImageView(requireContext()).apply {
                // 设置指示器图片，第一个为选中状态
                setImageResource(if (i == 0) R.drawable.indicator_selected else R.drawable.indicator_unselected)
                // 设置指示器的布局参数
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    // 设置指示器之间的间距
                    setMargins(8, 0, 8, 0)
                }
                layoutParams = params
            }
            // 将指示器添加到集合和视图中
            indicators.add(indicator)
            indicatorContainer.addView(indicator)
        }
    }

    // 更新指示器状态
    private fun updateIndicators(position: Int) {
        for (i in indicators.indices) {
            // 更新指示器图片，当前页对应的指示器显示选中状态
            indicators[i].setImageResource(
                if (i == position) R.drawable.indicator_selected 
                else R.drawable.indicator_unselected
            )
        }
    }

    // ViewPager2 的适配器
    inner class CarouselAdapter : RecyclerView.Adapter<CarouselAdapter.ViewHolder>() {
        // ViewHolder 类定义
        inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            // 右侧文本视图
            val rightText: TextView = view.findViewById(R.id.rightText)
            // 左侧竖向轮播
            val verticalViewPager: ViewPager2 = view.findViewById(R.id.verticalViewPager)
            val verticalIndicatorContainer: LinearLayout = view.findViewById(R.id.verticalIndicatorContainer)
            // 存储垂直指示器
            val verticalIndicators = mutableListOf<ImageView>()
        }

        // 创建 ViewHolder
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_carousel, parent, false)
            return ViewHolder(view)
        }

        // 绑定数据到 ViewHolder
        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            when (position) {
                0 -> {
                    // 设置右侧内容
                    holder.rightText.text = "右侧区域"
                    
                    // 设置左侧竖向轮播
                    setupVerticalCarousel(holder)
                }
                else -> {
                    // 其他页面的内容
                    holder.rightText.text = "Page ${position + 1}"
                }
            }
            Log.d("CarouselDebug", "Binding view for position: $position")
        }

        // 设置竖向轮播
        private fun setupVerticalCarousel(holder: ViewHolder) {
            // 创建垂直轮播适配器
            val verticalAdapter = VerticalCarouselAdapter()
            holder.verticalViewPager.adapter = verticalAdapter

            // 默认不显示指示器
            holder.verticalIndicatorContainer.visibility = View.GONE

            // 可选：创建指示器（默认不调用）
            // createVerticalIndicators(holder)

            // 监听垂直页面切换
            holder.verticalViewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
                override fun onPageSelected(position: Int) {
                    // 如果需要显示指示器，可以取消下面的注释
                    // updateVerticalIndicators(holder, position)
                }
            })
        }

        // 分离出来的创建垂直指示器方法
        private fun createVerticalIndicators(holder: ViewHolder) {
            // 清除旧的指示器
            holder.verticalIndicatorContainer.removeAllViews()
            holder.verticalIndicators.clear()

            // 创建垂直指示器
            for (i in 0 until 3) {
                val indicator = ImageView(holder.itemView.context).apply {
                    setImageResource(if (i == 0) R.drawable.indicator_selected else R.drawable.indicator_unselected)
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    ).apply {
                        setMargins(0, 0, 0, 8) // 垂直间距
                    }
                    layoutParams = params
                }
                holder.verticalIndicators.add(indicator)
                holder.verticalIndicatorContainer.addView(indicator)
            }
        }

        // 分离出来的更新垂直指示器方法
        private fun updateVerticalIndicators(holder: ViewHolder, position: Int) {
            for (i in holder.verticalIndicators.indices) {
                holder.verticalIndicators[i].setImageResource(
                    if (i == position) R.drawable.indicator_selected 
                    else R.drawable.indicator_unselected
                )
            }
        }

        // 垂直轮播适配器
        inner class VerticalCarouselAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            // 为普通页面创建新的 ViewHolder
            inner class NormalViewHolder(view: View) : RecyclerView.ViewHolder(view) {
                val text: TextView = view.findViewById(R.id.verticalItemText)
            }

            // 为日历页面创建新的 ViewHolder
            inner class CalendarPageHolder(view: View) : RecyclerView.ViewHolder(view) {
                val monthContainer: FrameLayout = view.findViewById(R.id.monthContainer)
                val weekContainer: LinearLayout = view.findViewById(R.id.weekContainer)
            }

            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
                return when (viewType) {
                    0 -> {
                        val view = LayoutInflater.from(parent.context)
                            .inflate(R.layout.calendar_page, parent, false)
                        CalendarPageHolder(view)
                    }
                    else -> {
                        val view = LayoutInflater.from(parent.context)
                            .inflate(R.layout.vertical_carousel_item, parent, false)
                        NormalViewHolder(view)
                    }
                }
            }

            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
                when (position) {
                    0 -> {
                        if (holder is CalendarPageHolder) {
                            // 添加年月显示
                            holder.monthContainer.removeAllViews()
                            holder.monthContainer.addView(
                                CalendarPageManager().createYearMonthView(holder.itemView.context)
                            )

                            // 添加 WeekComponent
                            holder.weekContainer.removeAllViews()
                            holder.weekContainer.addView(WeekComponent(holder.itemView.context))
                        }
                    }
                    else -> {
                        if (holder is NormalViewHolder) {
                            holder.text.text = "${position + 1}"
                        }
                    }
                }
            }

            override fun getItemViewType(position: Int): Int = position

            override fun getItemCount() = 3 // 垂直轮播3页
        }

        override fun getItemCount() = pageCount
    }
} 