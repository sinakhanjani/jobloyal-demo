package com.jobloyal.user.model.request

data class CreateNewRequestModel(
    val jobberId: String?,
    val latitude: Double?,
    val longitude: Double?,
    val services : List<ServiceInCreateNewRequest>?
)