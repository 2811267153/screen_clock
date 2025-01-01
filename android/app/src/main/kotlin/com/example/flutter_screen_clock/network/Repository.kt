package com.example.flutter_screen_clock.network

import android.util.Log
import com.example.flutter_screen_clock.network.HttpClient.createService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import retrofit2.HttpException
import java.io.IOException

object Repository {
    private const val TAG = "Repository"
    private val apiService = createService(ApiService::class.java)

    suspend fun getLunarCalendar(year: Int, month: Int, day: Int): Result<LunarCalendarResponse> {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "Requesting lunar calendar for: $year-$month-$day")
                val response = apiService.getLunarCalendar(
                    appkey = "2c99829512138cc0",
                    year = year,
                    month = month,
                    day = day
                )
                Log.d(TAG, "Raw response: $response")
                
                if (response.isSuccess()) {
                    Result.success(response.data!!)
                } else {
                    val errorMsg = "API error: code=${response.code}, message=${response.message}"
                    Log.e(TAG, errorMsg)
                    Result.failure(Exception(errorMsg))
                }
            } catch (e: HttpException) {
                // HTTP 错误
                val errorMsg = "HTTP ${e.code()}: ${e.message()}"
                Log.e(TAG, errorMsg)
                Result.failure(Exception(errorMsg))
            } catch (e: IOException) {
                // 网络错误
                val errorMsg = "Network error: ${e.message}"
                Log.e(TAG, errorMsg)
                Result.failure(Exception(errorMsg))
            } catch (e: Exception) {
                // 其他错误
                val errorMsg = "Unexpected error: ${e.message}"
                Log.e(TAG, errorMsg, e)
                Result.failure(Exception(errorMsg))
            }
        }
    }
} 