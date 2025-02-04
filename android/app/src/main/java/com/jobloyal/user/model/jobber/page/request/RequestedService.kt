package com.jobloyal.user.model.jobber.page.request

data class RequestedService(
    val accepted: Boolean?,
    val count: Int?,
    val is_paid: Boolean?,
    val price: Float?,
    val request_id: String?,
    val title: String?,
    val total_price: Double?,
    val unit: String?
)