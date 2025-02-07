package com.jobloyal.utility


import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.jobloyal.MainActivity
import com.jobloyal.MyApplication
import com.jobloyal.R
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.jobber.JobberViewModel
import com.jobloyal.user.UserActivity
import com.jobloyal.user.UserViewModel
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class MyFirebaseMessagingService : FirebaseMessagingService() {

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    // [START receive_message]
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // [START_EXCLUDE]
        // There are two types of messages data messages and notification messages. Data messages are handled
        // here in onMessageReceived whether the app is in the foreground or background. Data messages are the type
        // traditionally used with GCM. Notification messages are only received here in onMessageReceived when the app
        // is in the foreground. When the app is in the background an automatically generated notification is displayed.
        // When the user taps on the notification they are returned to the app. Messages containing both notification
        // and data payloads are treated as notification messages. The Firebase console always sends notification
        // messages. For more see: https://firebase.google.com/docs/cloud-messaging/concept-options
        // [END_EXCLUDE]

        // TODO(developer): Handle FCM messages here.
        // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
        Log.d(TAG, "From: ${remoteMessage.from}")
        Log.d(TAG, "From: ${remoteMessage.data}")

        // Check if message contains a data payload.
        if (remoteMessage.data.isNotEmpty()) {
            val method = remoteMessage.data["method"]
            if (method == "UPT") {
                val activity = (application as? MyApplication)?.getCurrentActivity()
                if (activity is JobberActivity) {
                    activity.viewModel.getLastRequestDetail()
                } else if (activity is UserActivity) {
                    activity.viewModel.getLastRequestDetail()
                }
            } else if (method == "NEW") {
                val activity = (application as? MyApplication)?.getCurrentActivity()
                if (activity is JobberActivity) {
                    if (activity.jobberAreSeeingRequestTab()) {
                        activity.viewModel.sendNewRequestToObservable(remoteMessage.data["data"])
                     } else {
                        remoteMessage.notification?.let {
                            sendNotification(
                                it.title ?: "new request",
                                it.body ?: "a new request has been created now"
                            )
                        }
                    }
                }
            } else if (method == "CNL") {
                val activity = (application as? MyApplication)?.getCurrentActivity()
                if (activity is JobberActivity) {
                    if (activity.jobberAreSeeingRequestTab()) {
                        activity.viewModel.canceledRequestToObservable(remoteMessage.data["data"])
                    }
                }
                else if (activity is UserActivity){
                    remoteMessage.notification?.let {
                        sendNotification(
                            it.title ?: "your request has been canceled",
                            it.body ?: "jobber canceled your request"
                        )
                        activity.viewModel.getLastRequestDetail()
                    }
                }
            }
            else if (method == "DSP") {
                remoteMessage.notification?.let {
                    if (it.title != null && it.body != null)
                    sendNotification(
                        it.title!!,
                        it.body!!
                    )
                }
            }

        }

//        // Check if message contains a notification payload.
//        remoteMessage.notification?.let {
//
//        }

        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
    }
    // [END receive_message]

    // [START on_new_token]
    /**
     * Called if the FCM registration token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the
     * FCM registration token is initially generated so this is where you would retrieve the token.
     */
    override fun onNewToken(token: String) {
        Log.d(TAG, "Refreshed token: $token")
        sendRegistrationToServer(token)
    }
    // [END on_new_token]

    /**
     * Schedule async work using WorkManager.
     */
    private fun scheduleJob() {

    }

    /**
     * Handle time allotted to BroadcastReceivers.
     */
    private fun handleNow() {
        Log.d(TAG, "Short lived task is done.")
    }

    /**
     * Persist token to third-party servers.
     *
     * Modify this method to associate the user's FCM registration token with any server-side account
     * maintained by your application.
     *
     * @param token The new token.
     */
    private fun sendRegistrationToServer(token: String?) {
        if (Const.getToken()?.length ?: 0 > 10 && token != null) {
            if (getIsJobberApp() == true) {
                JobberViewModel(application).sendFCMToken(token)
            } else {
                UserViewModel(application).sendFCMToken(token)
            }
        }
    }

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     * @param messageBody FCM message body received.
     */
    private fun sendNotification(title: String, messageBody: String) {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pendingIntent = PendingIntent.getActivity(
            this, 0 /* Request code */, intent,
            PendingIntent.FLAG_ONE_SHOT
        )

        val channelId = "REQUESTS"
        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(messageBody)
            .setAutoCancel(true)
            .setSound(defaultSoundUri)
            .setContentIntent(pendingIntent)

        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "New Requests",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(channel)
        }

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build())
    }

    companion object {

        private const val TAG = "MyFirebaseMsgService"
    }
}