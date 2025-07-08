package com.example.score_counter

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL
import com.example.live_activities.LiveActivityManager
import androidx.core.graphics.scale
import androidx.core.graphics.toColorInt

class CustomLiveActivityManager(context: Context) :
    LiveActivityManager(context) {
    private val context: Context = context.applicationContext
    private val pendingIntent = PendingIntent.getActivity(
        context, 200, Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    private val remoteViews = RemoteViews(
        context.packageName, R.layout.live_activity
    )

    // Create notification channel
    init {
        createNotificationChannel()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "score_counter_channel"
            val channelName = "Score Counter Live Activity"
            val channelDescription = "Displays ongoing game scores"
            val importance = NotificationManager.IMPORTANCE_HIGH  // Changed from DEFAULT to HIGH
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                setShowBadge(true)
                enableLights(true)
                enableVibration(true)
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    // This function will update the RemoteViews with the data
    private suspend fun updateRemoteViews(
        players: List<*>
    ) {
        val playerCount = players.size
        
        // Clear existing views before adding new ones
        remoteViews.removeAllViews(R.id.player_container)

        for (i in 0 until playerCount){
            val playerData = players[i] as Map<String, Any>
            val subViews = RemoteViews(context.packageName, R.layout.player_info)

            val colorInt = try {
                playerData["color"].toString().toColorInt()
            } catch (e: IllegalArgumentException) {
                // fallback to white if parse fails
                Color.WHITE
            }

            subViews.setTextViewText(R.id.player_name, playerData["name"].toString())
            subViews.setTextViewText(R.id.player_score, playerData["score"].toString())
            subViews.setInt(
                R.id.player_circle,
                "setColorFilter",
                colorInt
            )

            if (i == playerCount - 1){
                subViews.setViewVisibility(R.id.separator, View.GONE)
            }

            remoteViews.addView(R.id.player_container, subViews)
        }
    }


    // This function will be called by the plugin to build the notification
    // [notification] is the Notification.Builder instance used by the plugin
    // [event] is the event type ("create" or "update")
    // [data] is the data passed to the plugin
    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>
    ): Notification {
        val players = data["players"] as List<*>
        val gameMode = data["gameMode"] as String
        val channelId = data["channelId"] as? String ?: "score_counter_channel"

        updateRemoteViews(players)

        // For Android O and above, set the channel ID
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notification.setChannelId(channelId)
        }

        return notification
            .setSmallIcon(R.drawable.pool_ball_icon)
            .setOngoing(true)
            .setContentTitle(gameMode)
            .setContentIntent(pendingIntent)
            .setContentText("Game in progress")  // Added content text
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews) // Collapsed view
            .setCustomBigContentView(remoteViews) // Expanded view
            .setPriority(Notification.PRIORITY_HIGH)  // Changed from LOW to HIGH
            .setCategory(Notification.CATEGORY_EVENT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }
}