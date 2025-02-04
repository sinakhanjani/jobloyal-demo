package com.jobloyal.model

import com.google.gson.annotations.SerializedName

class ResponseArrayModel<T> : ResponseModelParent<ArrayModel<T>>()

data class ArrayModel<T> (@SerializedName("items") var items : List<T>?, @SerializedName("request_life_time") var requestLifeTime : Int)