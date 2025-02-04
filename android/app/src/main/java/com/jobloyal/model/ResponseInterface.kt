package com.jobloyal.model

interface ResponseInterface<T> {

    var  success : Boolean;
    var data : T?;
    var message : String?;
    var code : Int?;

}