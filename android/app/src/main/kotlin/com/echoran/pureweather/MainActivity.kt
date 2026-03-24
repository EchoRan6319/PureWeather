package com.echoran.pureweather

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.WallpaperManager
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val wallpaperChannelName = "com.echoran.pureweather/wallpaper"
        private const val liveUpdateChannelName = "com.echoran.pureweather/live_update"
        private const val liveUpdateNotificationChannelId = "weather_live_updates"
        private const val liveUpdateNotificationId = 9001
        private const val android16ApiLevel = 36
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupWallpaperChannel(flutterEngine)
        setupLiveUpdateChannel(flutterEngine)
    }

    private fun setupWallpaperChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            wallpaperChannelName,
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "getWallpaperPrimaryColor" -> {
                    val color = getWallpaperPrimaryColor()
                    if (color != null) {
                        result.success(color)
                    } else {
                        result.error("UNAVAILABLE", "Wallpaper colors not available.", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun setupLiveUpdateChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            liveUpdateChannelName,
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "isSupported" -> {
                    result.success(Build.VERSION.SDK_INT >= android16ApiLevel)
                }

                "canPostPromotedNotifications" -> {
                    result.success(canPostPromotedNotifications())
                }

                "openPromotedNotificationSettings" -> {
                    result.success(openPromotedNotificationSettings())
                }

                "showWeatherLiveUpdate" -> {
                    val title = call.argument<String>("title").orEmpty()
                    val content = call.argument<String>("content").orEmpty()
                    result.success(showWeatherLiveUpdate(title, content))
                }

                "scheduleLiveUpdate" -> {
                    val id = call.argument<Int>("id")
                    val triggerAtMillis = call.argument<Long>("triggerAtMillis")
                    val title = call.argument<String>("title")
                    val content = call.argument<String>("content")

                    if (id == null || triggerAtMillis == null || title == null || content == null) {
                        result.success(
                            failedResult(
                                code = "INVALID_ARGS",
                                message = "缺少调度实时更新通知的必要参数",
                            ),
                        )
                    } else {
                        result.success(
                            scheduleLiveUpdate(
                                id = id,
                                triggerAtMillis = triggerAtMillis,
                                title = title,
                                content = content,
                            ),
                        )
                    }
                }

                "cancelScheduledLiveUpdate" -> {
                    val id = call.argument<Int>("id")
                    if (id == null) {
                        result.success(false)
                    } else {
                        result.success(cancelScheduledLiveUpdate(id))
                    }
                }

                "cancelWeatherLiveUpdate" -> {
                    cancelWeatherLiveUpdate()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun showWeatherLiveUpdate(title: String, content: String): Map<String, Any> {
        if (!hasNotificationPermission()) {
            return failedResult(
                code = "NOTIFICATION_PERMISSION_DENIED",
                message = "未授予通知权限",
            )
        }
        if (!canPostPromotedNotifications()) {
            return failedResult(
                code = "PROMOTED_PERMISSION_DENIED",
                message = "系统未允许发布 Promoted 实时更新通知",
            )
        }

        createLiveUpdateChannelIfNeeded()

        val launchIntent =
            packageManager.getLaunchIntentForPackage(packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            } ?: Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }

        val contentIntent =
            PendingIntent.getActivity(
                this,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

        val builder =
            NotificationCompat
                .Builder(this, liveUpdateNotificationChannelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(content)
                .setStyle(NotificationCompat.BigTextStyle().bigText(content))
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setCategory(NotificationCompat.CATEGORY_STATUS)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setOnlyAlertOnce(true)
                .setOngoing(true)
                .setShowWhen(true)
                .setWhen(System.currentTimeMillis())
                .setContentIntent(contentIntent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            builder.setRequestPromotedOngoing(true)
        }

        val notification = builder.build()
        if (
            Build.VERSION.SDK_INT >= android16ApiLevel &&
            !notification.hasPromotableCharacteristics()
        ) {
            return failedResult(
                code = "NOT_PROMOTABLE_CHARACTERISTICS",
                message = "通知不满足 promotable characteristics",
            )
        }

        NotificationManagerCompat.from(this).notify(liveUpdateNotificationId, notification)
        return successResult()
    }

    private fun cancelWeatherLiveUpdate() {
        NotificationManagerCompat.from(this).cancel(liveUpdateNotificationId)
    }

    private fun scheduleLiveUpdate(
        id: Int,
        triggerAtMillis: Long,
        title: String,
        content: String,
    ): Map<String, Any> {
        val alarmManager = getSystemService(AlarmManager::class.java)
            ?: return failedResult(
                code = "ALARM_MANAGER_UNAVAILABLE",
                message = "无法获取 AlarmManager",
            )

        val intent =
            Intent(this, LiveUpdateAlarmReceiver::class.java).apply {
                putExtra(LiveUpdateAlarmReceiver.EXTRA_NOTIFICATION_ID, id)
                putExtra(LiveUpdateAlarmReceiver.EXTRA_TITLE, title)
                putExtra(LiveUpdateAlarmReceiver.EXTRA_CONTENT, content)
            }
        val pendingIntent =
            PendingIntent.getBroadcast(
                this,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent,
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent,
            )
        }

        return successResult(
            code = "SCHEDULED",
            message = "已调度实时更新通知",
        )
    }

    private fun cancelScheduledLiveUpdate(id: Int): Boolean {
        val alarmManager = getSystemService(AlarmManager::class.java) ?: return false
        val intent = Intent(this, LiveUpdateAlarmReceiver::class.java)
        val pendingIntent =
            PendingIntent.getBroadcast(
                this,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
        return true
    }

    private fun createLiveUpdateChannelIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel =
            NotificationChannel(
                liveUpdateNotificationChannelId,
                "天气实时更新",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "持续显示当前天气并实时刷新"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }

        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }

    private fun canPostPromotedNotifications(): Boolean {
        if (Build.VERSION.SDK_INT < android16ApiLevel) return false
        val manager = getSystemService(NotificationManager::class.java) ?: return false
        return manager.canPostPromotedNotifications()
    }

    private fun openPromotedNotificationSettings(): Boolean {
        if (Build.VERSION.SDK_INT < android16ApiLevel) return false
        return try {
            val intent =
                Intent(Settings.ACTION_APP_NOTIFICATION_PROMOTION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun hasNotificationPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
        )
    }

    private fun successResult(
        code: String = "POSTED",
        message: String = "实时更新通知已发送",
    ): Map<String, Any> {
        return mapOf(
            "success" to true,
            "code" to code,
            "message" to message,
        )
    }

    private fun failedResult(code: String, message: String): Map<String, Any> {
        return mapOf(
            "success" to false,
            "code" to code,
            "message" to message,
        )
    }

    private fun getWallpaperPrimaryColor(): Int? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            val wallpaperManager = WallpaperManager.getInstance(this)
            val colors = wallpaperManager.getWallpaperColors(WallpaperManager.FLAG_SYSTEM)
            if (colors != null) {
                // Return ARGB format
                return colors.primaryColor?.toArgb()
            }
        }
        return null
    }
}
