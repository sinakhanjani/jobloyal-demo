package com.jobloyal.utility;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import java.util.Calendar;

public class LocalAlarmManager {
    public static void startAlarmBroadcastReceiver(Context context) {
        Intent _intent = new Intent(context, AlarmBroadcastReceiver.class);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, _intent, 0);
        AlarmManager alarmManager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
        alarmManager.cancel(pendingIntent);
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.set(Calendar.HOUR_OF_DAY, 7);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.add(Calendar.DATE, 1);
        alarmManager.set(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), pendingIntent);
    }
    public static void cancelAlarm (Context context) {
//        Intent _intent = new Intent(context, AlarmBroadcastReceiver.class);
//        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, _intent, 0);
//        AlarmManager alarmManager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
//        alarmManager.cancel(pendingIntent);

        Intent _intent = new Intent(context, AlarmBroadcastReceiver.class);
        AlarmManager alarmManager =
                (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        PendingIntent pendingIntent =
                PendingIntent.getService(context, 0, _intent,
                        PendingIntent.FLAG_NO_CREATE);
        if (pendingIntent != null && alarmManager != null) {
            alarmManager.cancel(pendingIntent);
        }
    }
}
