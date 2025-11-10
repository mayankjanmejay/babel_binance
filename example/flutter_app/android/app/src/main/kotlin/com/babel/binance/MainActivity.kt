package com.babel.binance

import android.content.Context
import android.content.Intent
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.babel.binance/native"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available.", null)
                    }
                }
                "getDeviceInfo" -> {
                    val deviceInfo = getDeviceInfo()
                    result.success(deviceInfo)
                }
                "hapticFeedback" -> {
                    val type = call.argument<String>("type") ?: "light"
                    triggerHapticFeedback(type)
                    result.success(null)
                }
                "shareContent" -> {
                    val text = call.argument<String>("text") ?: ""
                    val subject = call.argument<String>("subject")
                    shareContent(text, subject)
                    result.success(true)
                }
                "openSettings" -> {
                    val section = call.argument<String>("section")
                    openSettings(section)
                    result.success(null)
                }
                "isAppInBackground" -> {
                    result.success(false) // Simplified for example
                }
                "lockScreen" -> {
                    // Requires device admin permissions
                    result.success(null)
                }
                "getScreenBrightness" -> {
                    val brightness = getScreenBrightness()
                    result.success(brightness)
                }
                "setScreenBrightness" -> {
                    val brightness = call.argument<Double>("brightness") ?: 0.5
                    setScreenBrightness(brightness.toFloat())
                    result.success(null)
                }
                "getNetworkInfo" -> {
                    val networkInfo = getNetworkInfo()
                    result.success(networkInfo)
                }
                "copyToClipboard" -> {
                    val text = call.argument<String>("text") ?: ""
                    copyToClipboard(text)
                    result.success(null)
                }
                "isDeviceRooted" -> {
                    val isRooted = isDeviceRooted()
                    result.success(isRooted)
                }
                "getAppVersion" -> {
                    val version = getAppVersion()
                    result.success(version)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        return batteryLevel
    }

    private fun getDeviceInfo(): Map<String, Any> {
        return mapOf(
            "model" to Build.MODEL,
            "manufacturer" to Build.MANUFACTURER,
            "version" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "brand" to Build.BRAND,
            "device" to Build.DEVICE
        )
    }

    private fun triggerHapticFeedback(type: String) {
        // Implementation depends on API level and type
        // This is a simplified version
    }

    private fun shareContent(text: String, subject: String?) {
        val sendIntent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_TEXT, text)
            subject?.let { putExtra(Intent.EXTRA_SUBJECT, it) }
            type = "text/plain"
        }
        val shareIntent = Intent.createChooser(sendIntent, null)
        startActivity(shareIntent)
    }

    private fun openSettings(section: String?) {
        val intent = when (section) {
            "app" -> Intent(Settings.ACTION_APPLICATION_SETTINGS)
            "wifi" -> Intent(Settings.ACTION_WIFI_SETTINGS)
            "bluetooth" -> Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
            "location" -> Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
            else -> Intent(Settings.ACTION_SETTINGS)
        }
        startActivity(intent)
    }

    private fun getScreenBrightness(): Float {
        return try {
            Settings.System.getInt(
                contentResolver,
                Settings.System.SCREEN_BRIGHTNESS
            ) / 255.0f
        } catch (e: Settings.SettingNotFoundException) {
            0.5f
        }
    }

    private fun setScreenBrightness(brightness: Float) {
        val layoutParams = window.attributes
        layoutParams.screenBrightness = brightness
        window.attributes = layoutParams
    }

    private fun getNetworkInfo(): Map<String, Any> {
        // Simplified implementation
        return mapOf(
            "isConnected" to true,
            "type" to "wifi"
        )
    }

    private fun copyToClipboard(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as android.content.ClipboardManager
        val clip = android.content.ClipData.newPlainText("label", text)
        clipboard.setPrimaryClip(clip)
    }

    private fun isDeviceRooted(): Boolean {
        // Simplified root detection
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su"
        )
        return paths.any { java.io.File(it).exists() }
    }

    private fun getAppVersion(): String {
        return try {
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            packageInfo.versionName ?: "1.0.0"
        } catch (e: Exception) {
            "1.0.0"
        }
    }
}
