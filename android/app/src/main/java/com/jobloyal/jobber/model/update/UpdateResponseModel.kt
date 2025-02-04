package com.jobloyal.jobber.model.update

data class UpdateResponseModel(
    val createdAt: String?,
    val description: String?,
    val device_type: String?,
    val force: Boolean?,
    val id: Int?,
    val is_jobber_app: Boolean?,
    val link: String?,
    val period: Int?,
    val updatedAt: String?,
    val version_code: Int?
)