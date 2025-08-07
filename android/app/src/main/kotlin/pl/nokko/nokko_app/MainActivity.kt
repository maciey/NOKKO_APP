package pl.nokko.nokko_app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val BATTERY_OPTIMIZATION_CHANNEL = "nokko.app/battery_optimization"
    private val WAKE_DEVICE_CHANNEL = "nokko.app/wake_device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Kanał dla zarządzania optymalizacją baterii
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_OPTIMIZATION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestExemption" -> {
                        requestBatteryOptimizationExemption()
                        result.success(true)
                    }
                    "isOptimizationDisabled" -> {
                        result.success(isBatteryOptimizationDisabled())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }

        // Kanał dla wybudzania urządzenia
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WAKE_DEVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "wakeUp" -> {
                        wakeUpDevice()
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    /**
     * Żądanie wyłączenia aplikacji z optymalizacji baterii
     */
    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            val packageName = packageName

            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                }
                try {
                    startActivity(intent)
                } catch (e: Exception) {
                    // Fallback - otwórz ustawienia optymalizacji baterii
                    val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    startActivity(fallbackIntent)
                }
            }
        }
    }

    /**
     * Sprawdzenie czy optymalizacja baterii jest wyłączona
     */
    private fun isBatteryOptimizationDisabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            powerManager.isIgnoringBatteryOptimizations(packageName)
        } else {
            true
        }
    }

    /**
     * Wybudzenie urządzenia i ekranu
     */
    private fun wakeUpDevice() {
        try {
            // Wybudzenie ekranu przez krótki czas
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)
            } else {
                @Suppress("DEPRECATION")
                window.addFlags(
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                )
            }

            // Opcjonalnie: wybudzenie urządzenia przez PowerManager
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                @Suppress("DEPRECATION")
                val wakeLock = powerManager.newWakeLock(
                    PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                    "NOKKO::WakeLock"
                )
                wakeLock.acquire(3000) // 3 sekundy
                wakeLock.release()
            }

        } catch (e: Exception) {
            // Logowanie błędu (w produkcji lepiej użyć Log.e)
            println("Błąd wybudzania urządzenia: ${e.message}")
        }
    }
}
