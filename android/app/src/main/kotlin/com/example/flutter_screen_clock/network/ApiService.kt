package com.example.flutter_screen_clock.network

import retrofit2.http.GET
import retrofit2.http.Query

interface ApiService {
    @GET("/huangli/date")
    suspend fun getLunarCalendar(
        @Query("appkey") appkey: String,
        @Query("year") year: Int,
        @Query("month") month: Int,
        @Query("day") day: Int
    ): String
} 