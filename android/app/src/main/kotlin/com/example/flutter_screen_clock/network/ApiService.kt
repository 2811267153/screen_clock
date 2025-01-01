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
    ): BaseResponse<LunarCalendarResponse>
}

data class LunarCalendarResponse(
    val year: String?,
    val month: String?,
    val day: String?,
    val yangli: String?,
    val nongli: String?,
    val star: String?,
    val taishen: String?,
    val wuxing: String?,
    val chong: String?,
    val sha: String?,
    val shengxiao: String?,
    val jiri: String?,
    val zhiri: String?,
    val xiongshen: String?,
    val jishenyiqu: String?,
    val caishen: String?,
    val xishen: String?,
    val fushen: String?,
    val suici: List<String>?,
    val yi: List<String>?,
    val ji: List<String>?,
    val eweek: String?,
    val emonth: String?,
    val week: String?
) 