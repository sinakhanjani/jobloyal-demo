package com.jobloyal

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.login.LoginActivity
import com.jobloyal.user.UserActivity
import com.jobloyal.utility.Const
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import com.jobloyal.utility.RxActivity
import io.reactivex.disposables.Disposable
import java.util.*

class MainActivity : RxActivity() {

    lateinit var viewModel : MainActivityViewModel
    var disposable : Disposable? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        viewModel = ViewModelProvider(this).get(MainActivityViewModel::class.java)
        if (checkLanguage()) {
            val handler = Handler(Looper.getMainLooper())
            handler.postDelayed({
                openApp()
            }, 1000)
        }
    }
    private fun openApp () {
        if (Const.getToken()?.length ?: 0 > 13) {
            if (getIsJobberApp() == true) {
                startActivity(Intent(this, JobberActivity::class.java))
            }
            else {
                startActivity(Intent(this, UserActivity::class.java))
            }
        }
        else {
            startActivity(Intent(this, LoginActivity::class.java))
        }
        finish()
    }

    private fun  checkLanguage () : Boolean {
        var region = "en"
        val lang = Locale.getDefault().language
        if (lang == "ch" || lang == "fr") region = "fr"
        val isSameOrUserNotRegistered = Const.getRegisteredLanguage(this) == region || Const.getToken()?.length ?: 0 < 13
        if (!isSameOrUserNotRegistered) {
            Log.i("sdfdfdf","it's here 55")
            disposable = viewModel.registerRegionToServer(region).subscribe { success ->
                Log.i("sdfdfdf","it's here 56")
                if (success)
                    Const.registerLanguage(this, region)
                openApp()
            }
        }
        return isSameOrUserNotRegistered
    }

    override fun onDestroy() {
        super.onDestroy()
        disposable?.dispose()
    }
}