package com.jobloyal.user

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.findNavController
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.messaging.FirebaseMessaging
import com.jobloyal.R
import com.jobloyal.jobber.JobberViewModel
import com.jobloyal.utility.AlertDialogFactory
import com.jobloyal.utility.Const
import com.jobloyal.utility.RxActivity
import com.jobloyal.utility.toast
import java.util.*


class UserActivity : RxActivity() {

    lateinit var viewModel : UserViewModel
    var  timer : Timer? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel = ViewModelProvider(this).get(UserViewModel::class.java)
        setContentView(R.layout.user_activity)
        init()
        subscribeUpdate ()
        settingFirebaseToken()
    }
    private fun subscribeUpdate () {
        addToDisposableBag(viewModel.update.subscribe {
            AlertDialogFactory(this).updateDialog(it.force ?: false, it.description ?: getString(R.string.defaultDescriptionUpdate), {alert ->
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
    private fun init () {
        addToDisposableBag(viewModel.lastRequest.subscribe {
            if (it.data != null) {
                val ps = viewModel.lastStatus
                if (viewModel.lastStatus != it.data?.status) {
                    viewModel.lastStatus = it.data?.status
                    if (ps != null && it.data?.status != "created"  && it.data?.status != "verified"  && findNavController(R.id.nav_host_fragment).currentDestination?.id == R.id.jobberPageFragment) {
                        //do not close jobberPage because it subscribe this observable and when be new it's update automatically
                    }
                    else {
                        findNavController(R.id.nav_host_fragment).popBackStack(
                            R.id.userMainFragment,
                            false
                        )
                    }
                    if (it.data?.status == "created") {
                        findNavController(R.id.nav_host_fragment).navigate(R.id.action_userMainFragment_to_userWaitingFragment)
                    }
                    else if (it.data?.status == "verified") {
                        findNavController(R.id.nav_host_fragment).navigate(R.id.userRateFragment)
                    }
                }
            }
            else {
                if (viewModel.lastStatus != null) {
                    viewModel.lastStatus = null
                    findNavController(R.id.nav_host_fragment).popBackStack(
                        R.id.userMainFragment,
                        false
                    )
                }
            }
        })
        viewModel.getLastRequestDetail()
        timer = Timer()
//        timer?.scheduleAtFixedRate(object : TimerTask() {
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

//    override fun onBackPressed() {
//        val dest = findNavController(R.id.nav_host_fragment).currentDestination?.id
//        if (viewModel.lastRequest.value?.data != null
//            && dest != R.id.jobberPageFragment
//            && dest != R.id.userProfileFragment
//            && dest != R.id.userEditProfileFragment
//        ) {
//            toast(R.string.cannotToBack)
//        }
//        else {
//            super.onBackPressed()
//        }
//    }

    override fun connectionDelegateShowNoConnection(
        code: Int
    ) {
        timer?.cancel()
        timer = null
        if (code == 403) {
            if (viewModel.suspendStatus.value != true) {
                findNavController(R.id.nav_host_fragment).popBackStack(
                    R.id.userMainFragment,
                    false
                )
                viewModel.suspendStatus.onNext(true)
            }
        }
        else {
            super.connectionDelegateShowNoConnection(code)
        }
    }
}