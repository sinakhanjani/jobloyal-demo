package com.jobloyal.jobber.model.profile

data class JobberProfileModel(
    val about_us: String?,
    val address: String?,
    val authority: Authority?,
    val authorized: Boolean?,
    val avatar: String?,
    val birthday: String?,
    val createdAt: String?,
    val credit: Double?,
    val email: String?,
    val family: String?,
    val gender: Boolean?,
    val id: String?,
    val identifier: String?,
    val name: String?,
    val phone_number: String?,
    val region: String?,
    val statics: Statics?,
    val updatedAt: String?,
    val zip_code: Int?
)