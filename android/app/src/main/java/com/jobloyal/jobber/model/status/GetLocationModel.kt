package com.jobloyal.jobber.model.status

data class GetLocationModel(
    val address: String? = null,
    val createdAt: String? = null,
    val id: Int? = null,
    val jobber_id: String? = null,
    val location: String? = null,
    val longitude: Double? = null,
    val latitude: Double? = null,
    val shouldUpdate: Boolean? = null
)