package com.jobloyal.user.main

import android.app.Application
import android.content.Context
import com.google.android.gms.maps.model.LatLng
import com.jobloyal.utility.RxViewModel
import java.lang.Appendable

class UserMainViewModel(val app : Application) : RxViewModel(app){

    var location : LatLng? = null
    var zoom : Float? = 15f
    var displayedChild = 0

    fun saveLocationToSharedPreferences () {
        app.getSharedPreferences("settings",Context.MODE_PRIVATE)
            .edit()
            .putString("last_lat",(location?.latitude ?: 47.3767594).toString())
            .putString("last_lng",(location?.longitude ?: 8.5339181).toString())
            .apply()
    }

    fun readLastLocation () {
        if (location == null) {
            val sharedPreferences = app.getSharedPreferences("settings", Context.MODE_PRIVATE)
            location = LatLng(sharedPreferences.getString("last_lat", "47.3767594")?.toDouble() ?: 47.3767594,
                    sharedPreferences.getString("last_lng", "8.5339181")?.toDouble() ?: 8.5339181)
        }
    }
}