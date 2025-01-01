package com.example.flutter_screen_clock.network

import android.util.Log
import com.example.flutter_screen_clock.network.HttpClient.createService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import retrofit2.HttpException
import java.io.IOException
import com.google.gson.Gson
import com.google.gson.JsonObject

object Repository {
    private const val TAG = "Repository"
    private val apiService = createService(ApiService::class.java)

    suspend fun getLunarCalendar(year: Int, month: Int, day: Int): Result<LunarCalendarResponse> {
        return withContext(Dispatchers.IO) {
            try {
                val jsonString = apiService.getLunarCalendar(
                    appkey = "2c99829512138cc0",
                    year = year,
                    month = month,
                    day = day
                )
                
                // 打印原始响应以便调试
                Log.d(TAG, "Raw response: $jsonString")
                
                // 手动解析 JSON
                val gson = Gson()
                val jsonObject = gson.fromJson(jsonString, JsonObject::class.java)
                val status = jsonObject.get("status").asInt
                val msg = jsonObject.get("msg").asString
                
                if (status == 0) {
                    val resultJson = jsonObject.get("result").toString()
                    val response = gson.fromJson(resultJson, LunarCalendarResponse::class.java)
                    Result.success(response)
                } else {
                    Result.failure(Exception("API error: $msg"))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error parsing response", e)
                Result.failure(e)
            }
        }
    }
} 