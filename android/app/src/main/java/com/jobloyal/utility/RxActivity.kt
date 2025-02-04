package com.jobloyal.utility

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.jobloyal.MainActivity
import com.jobloyal.MyApplication
import com.jobloyal.R
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable


open class RxActivity : AppCompatActivity() , ConnectionDelegate {

    var showingConnectionPage = false
    override fun connectionDelegateShowNoConnection(code : Int) {
        when (code) {
            401 -> {
                Const.resetToken(this)
                startActivity(Intent(this,MainActivity::class.java))
            }
            else -> {
                setContentView(R.layout.view_connection_message)
                updateStatusBarColor(Color.WHITE)
                val btn : Button = findViewById(R.id.refreshDataBtn)
                val titleTV : TextView = findViewById(R.id.title_label_connection)
                val descriptionTV : TextView = findViewById(R.id.des_label_connection)
                btn.setOnClickListener {
                    connectionDelegateRefreshData()
                }
            }
        }
    }

    override fun connectionDelegateHideNoConnection() {

    }

    override fun connectionDelegateRefreshData() {
        finish()
        overridePendingTransition(0, 0);
        startActivity(intent);
        overridePendingTransition(0, 0);
    }

    val subscriptions = CompositeDisposable()
    private var mMyApp: MyApplication? = null
    fun addToDisposableBag(disposable: Disposable): Disposable {
        subscriptions.add(disposable)
        return disposable
    }
    override fun onDestroy() {
        super.onDestroy()
        subscriptions.dispose()
        subscriptions.clear()
        clearReferences()
    }

    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mMyApp = this.applicationContext as MyApplication
    }

    override fun onResume() {
        super.onResume()
        mMyApp?.setCurrentActivity(this)
    }

    override fun onPause() {
        clearReferences()
        super.onPause()
    }

    private fun clearReferences() {
        val currActivity = mMyApp?.getCurrentActivity()
        if (this == currActivity)
            mMyApp?.setCurrentActivity(null)
    }
}