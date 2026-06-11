package com.example.mobile

import android.annotation.SuppressLint
import android.os.Build
import android.telephony.SubscriptionManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "bariox/sim"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getActiveSims" -> result.success(activeSims())
                    else -> result.notImplemented()
                }
            }
    }

    @SuppressLint("MissingPermission")
    private fun activeSims(): List<Map<String, Any?>> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP_MR1) return emptyList()
        val manager = getSystemService(SubscriptionManager::class.java) ?: return emptyList()
        val list = try {
            manager.activeSubscriptionInfoList ?: emptyList()
        } catch (e: SecurityException) {
            // READ_PHONE_STATE not granted yet — return empty so the UI can prompt.
            emptyList()
        }
        return list.map { info ->
            mapOf(
                "subscriptionId" to info.subscriptionId,
                "slotIndex" to info.simSlotIndex,
                "carrierName" to (info.carrierName?.toString() ?: ""),
                "displayName" to (info.displayName?.toString() ?: ""),
                "countryIso" to (info.countryIso ?: ""),
                "number" to (info.number ?: ""),
            )
        }
    }
}
