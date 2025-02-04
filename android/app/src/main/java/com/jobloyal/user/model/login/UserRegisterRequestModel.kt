package com.jobloyal.user.model.login

data class UserRegisterRequestModel(
    val address: String?,
    val birthday: String?,
    val email: String?,
    val family: String?,
    val gender: Boolean?,
    val name: String?,
    val region: String?,
)