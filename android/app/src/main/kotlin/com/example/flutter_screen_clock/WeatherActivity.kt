package com.example.flutter_screen_clock

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import java.text.SimpleDateFormat
import java.util.*

class WeatherActivity : Fragment() {
    private lateinit var temperatureView: TextView
    private lateinit var weatherConditionView: TextView
    private lateinit var humidityView: TextView
    private lateinit var dateView: TextView
    private lateinit var lunarDateView: TextView

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        Log.d("WeatherDebug", "onCreateView called")
        val view = inflater.inflate(R.layout.activity_weather, container, false)
        Log.d("WeatherDebug", "View inflated: $view")
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Log.d("WeatherDebug", "onViewCreated called")
        
        try {
            // 初始化视图
            temperatureView = view.findViewById<TextView>(R.id.temperature).also {
                Log.d("WeatherDebug", "Temperature view found: $it")
            }
            weatherConditionView = view.findViewById<TextView>(R.id.weather_condition).also {
                Log.d("WeatherDebug", "Weather condition view found: $it")
            }
            humidityView = view.findViewById<TextView>(R.id.humidity).also {
                Log.d("WeatherDebug", "Humidity view found: $it")
            }
            dateView = view.findViewById<TextView>(R.id.date).also {
                Log.d("WeatherDebug", "Date view found: $it")
            }
            lunarDateView = view.findViewById<TextView>(R.id.lunar_date).also {
                Log.d("WeatherDebug", "Lunar date view found: $it")
            }

            // 更新日期显示
            updateDate()
            // 更新天气数据
            updateWeatherData()
            
        } catch (e: Exception) {
            Log.e("WeatherDebug", "Error initializing views", e)
        }
    }

    private fun updateDate() {
        try {
            val sdf = SimpleDateFormat("yyyy年MM月dd日", Locale.CHINESE)
            dateView.text = sdf.format(Date()).also {
                Log.d("WeatherDebug", "Setting date: $it")
            }
            
            lunarDateView.text = "农历十一月十七".also {
                Log.d("WeatherDebug", "Setting lunar date: $it")
            }
        } catch (e: Exception) {
            Log.e("WeatherDebug", "Error updating date", e)
        }
    }

    private fun updateWeatherData() {
        try {
            temperatureView.text = "25°C".also {
                Log.d("WeatherDebug", "Setting temperature: $it")
            }
            weatherConditionView.text = "晴".also {
                Log.d("WeatherDebug", "Setting weather condition: $it")
            }
            humidityView.text = "湿度: 65%".also {
                Log.d("WeatherDebug", "Setting humidity: $it")
            }
        } catch (e: Exception) {
            Log.e("WeatherDebug", "Error updating weather data", e)
        }
    }
} 