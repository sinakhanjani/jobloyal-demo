package com.jobloyal.utility

import android.content.Context

class Const {
    companion object {
        public const val BASE_URL = "https://api.jobloyal.com/v1/" //have SSL
        private var token : String? = null

        fun getToken (context : Context? = null, refresh : Boolean = false) : String? {
            if (token == null || refresh)
                token = "Bearer " + (context?.getSharedPreferences("settings", Context.MODE_PRIVATE)?.getString("token","") ?: "")
            return token
        }
        fun resetToken (context: Context) {
            context.getSharedPreferences("settings", Context.MODE_PRIVATE).edit().putString("token", "").putBoolean("FCMSENT", false).apply()
            context.getSharedPreferences("settings", Context.MODE_PRIVATE).edit().putInt("alarmState", 0).apply()
            token = "";
        }

        fun Context.getIsJobberApp () : Boolean? {
            return getSharedPreferences("settings", Context.MODE_PRIVATE)?.getBoolean("isJobberApp", false)
        }

        fun getRegisteredLanguage (context: Context) : String? {
            return context.getSharedPreferences("settings", Context.MODE_PRIVATE)?.getString("language", null)
        }
        fun registerLanguage (context: Context,lang: String) {
            context.getSharedPreferences("settings", Context.MODE_PRIVATE)?.edit()?.putString("language", lang)?.apply()
        }

        fun isFcmSent (context : Context) : Boolean {
            return context.getSharedPreferences("settings", Context.MODE_PRIVATE)?.getBoolean("FCMSENT",false) ?: false
        }
        fun setFCMSent (context : Context) {
            context.getSharedPreferences("settings", Context.MODE_PRIVATE)?.edit()?.putBoolean("FCMSENT", true)?.apply()
        }
    }
}