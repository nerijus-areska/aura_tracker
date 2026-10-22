package com.example.aura_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Runs before flutter_local_notifications' ScheduledNotificationBootReceiver
 * (priority=1 vs default 0) and writes a valid empty JSON array to the plugin's
 * SharedPreferences cache. This prevents the "Missing type parameter" crash that
 * occurs when the plugin tries to deserialize stale notification details stored by
 * an older version of the plugin.
 */
class NotificationCacheCleanerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        context.getSharedPreferences("scheduled_notifications", Context.MODE_PRIVATE)
            .edit()
            .putString("scheduled_notifications", "[]")
            .apply()
    }
}
