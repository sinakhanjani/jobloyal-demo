package com.jobloyal.jobber

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.messaging.FirebaseMessaging
import com.jobloyal.R
import com.jobloyal.jobber.main.JobberMainFragment
import com.jobloyal.utility.*
import java.util.*

class JobberActivity : RxActivity() {

    lateinit var viewModel : JobberViewModel
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel = ViewModelProvider(this).get(JobberViewModel::class.java)
        setContentView(R.layout.jobber_activity)
        transparentStatusBar(true)
        setLocalAlarmManager()
        init()
        subscribeUpdate ()
        settingFirebaseToken()

    }

    private fun setLocalAlarmManager () {
        val state = getSharedPreferences("settings", Context.MODE_PRIVATE)?.getInt("alarmState",0) ?: 0
        if (state == 0) {
            LocalAlarmManager.startAlarmBroadcastReceiver(this)
            getSharedPreferences("settings", Context.MODE_PRIVATE)?.edit()?.putInt("alarmState",1)?.apply()
        }
    }
    private fun settingFirebaseToken () {
        if (!Const.isFcmSent(this)) {
            FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
                if (!task.isSuccessful) {
                    return@OnCompleteListener
                }
                val token = task.result

                viewModel.sendFCMToken(token)

            })
        }
    }

    private fun subscribeUpdate () {
        addToDisposableBag(viewModel.update.subscribe {
            AlertDialogFactory(this).updateDialog(it.force ?: false, it.description ?: getString(R.string.defaultDescriptionUpdate), { alert ->
                val link1 = it.link?.split("||")?.getOrNull(0)
                val link2 = it.link?.split("||")?.getOrNull(1)
                try {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(link1)))
                } catch (e: ActivityNotFoundException) {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(link2)))
                }
                if (it.force == false)
                    alert.dismiss()
            },{ alert ->
                if (it.force == true) {
                    this.finish()
                }
                else {
                    alert.dismiss()
                }
            }).show()
        })
        viewModel.checkVersion()
    }

    fun jobberAreSeeingRequestTab () : Boolean {
        if (findNavController(R.id.nav_host_fragment).currentDestination?.id == R.id.mainJobberFragment) {
            if (JobberMainFragment.currentDestination == R.id.navigation_requests) {
                return true
            }
        }
        return false
    }

    private fun init () {
        viewModel.lastRequest.subscribe {
            if (it.data != null) {
                if (viewModel.lastStatus != it.data?.status) {
                    viewModel.lastStatus = it.data?.status
                    viewModel.state = "back_and_refresh";
                    findNavController(R.id.nav_host_fragment).popBackStack(
                        R.id.mainJobberFragment,
                        false
                    )
                    if (it.data?.time_base == false && it.data?.status == "accepted") {
                        findNavController(R.id.nav_host_fragment).navigate(R.id.action_mainJobberFragment_to_jobberWaitingFragment)
                    } else {
                        findNavController(R.id.nav_host_fragment).navigate(R.id.action_mainJobberFragment_to_requestDetailFragment)
                    }
                }
            }
            else {
                if (viewModel.lastStatus != null) {
                    viewModel.lastStatus = null
                    findNavController(R.id.nav_host_fragment).popBackStack(
                        R.id.mainJobberFragment,
                        false
                    )
                }
            }
        }
        viewModel.getLastRequestDetail()
//        Timer().scheduleAtFixedRate(object : TimerTask() {
//            override fun run() {
//                viewModel.getLastRequestDetail()
//            }
//        }, 6000, 6000)

    }

    var firstTime = true
    override fun onResume() {
        super.onResume()
        if (!firstTime)
            viewModel.getLastRequestDetail()
        firstTime = false
    }

    override fun onBackPressed() {
        if (viewModel.lastRequest.value?.data != null) {
            toast(R.string.cannotToBack)
        }
        else {
            super.onBackPressed()
        }
    }

    override fun connectionDelegateShowNoConnection(
        code: Int
    ) {
        if (code == 403) {
            if (findNavController(R.id.nav_host_fragment).currentDestination?.id != R.id.suspendFragment)
                findNavController(R.id.nav_host_fragment).navigate(R.id.suspendFragment)
        }
        else {
            super.connectionDelegateShowNoConnection(code)
        }
    }
}