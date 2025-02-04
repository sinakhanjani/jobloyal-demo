package com.jobloyal.login

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.jobloyal.R
import com.jobloyal.utility.RxActivity
import com.jobloyal.utility.transparentStatusBar

class LoginActivity : RxActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.login_activity)
        transparentStatusBar(true)

    }
}