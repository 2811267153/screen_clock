package com.example.flutter_screen_clock.network

import com.google.gson.annotations.SerializedName

data class BaseResponse<T>(
    @SerializedName("status") val code: Int = 0,
    @SerializedName("msg") val message: String = "",
    @SerializedName("result") val data: T? = null
) {
    fun isSuccess() = code == 0
} 