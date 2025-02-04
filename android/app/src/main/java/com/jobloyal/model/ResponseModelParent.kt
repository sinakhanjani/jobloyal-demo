package com.jobloyal.model

open class ResponseModelParent<T> () {

    var success : Boolean = false
    var message : String? = null
    var code : Int? = null
    var data : T? = null

}