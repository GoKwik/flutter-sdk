package com.gokwik.flutter;

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.Base64
import android.util.Log
import android.widget.Toast;

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.Registrar

import java.io.ByteArrayOutputStream

import com.gokwik.sdk.Checkout;
import com.gokwik.sdk.GoKwikPaymentListner;

import org.json.JSONException
import org.json.JSONObject

class FlutterGokwikPlugin internal constructor(registrar: Registrar, channel: MethodChannel) : MethodCallHandler {

    private val activity = registrar.activity()
    private var result: Result? = null
    var hasResponded = false

    override fun onMethodCall(call: MethodCall, result: Result) {
        hasResponded = false

        this.result = result

        when (call.method) {
            "HandlePayment" -> this.handlePayment(call)
            "getInstalledUpiApps" -> this.getInstalledUpiApps()
            else -> result.notImplemented()
        }
    }

    private fun getInstalledUpiApps() {
        val uriBuilder = Uri.Builder()
        uriBuilder.scheme("upi").authority("pay")

        val uri = uriBuilder.build()
        val intent = Intent(Intent.ACTION_VIEW, uri)

        val packageManager = activity.packageManager

        try {
            val activities = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)

            // Convert the activities into a response that can be transferred over the channel.
            val activityResponse = activities.map {
                val packageName = it.activityInfo.packageName
                val drawable = packageManager.getApplicationIcon(packageName)

                val bitmap = getBitmapFromDrawable(drawable)
                val icon = if (bitmap != null) {
                    encodeToBase64(bitmap)
                } else {
                    null
                }

                mapOf(
                        "packageName" to packageName,
                        "icon" to icon,
                        "priority" to it.priority,
                        "preferredOrder" to it.preferredOrder
                )
            }

            result?.success(activityResponse)
        } catch (ex: Exception) {
            Log.e("upi_pay", ex.toString())
            result?.error("getInstalledUpiApps", "exception", ex)
        }
    }

    private fun encodeToBase64(image: Bitmap): String? {
        val byteArrayOS = ByteArrayOutputStream()
        image.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOS)
        return Base64.encodeToString(byteArrayOS.toByteArray(), Base64.NO_WRAP)
    }

    private fun getBitmapFromDrawable(drawable: Drawable): Bitmap? {
        val bmp: Bitmap = Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight())
        drawable.draw(canvas)
        return bmp
    }

    private fun handlePayment(call: MethodCall) {
        val jsonResponse: Map<String,Any>? = call.argument("data")
        val environment = jsonResponse?.get("environment") as Boolean
        try {
            val responseObject = JSONObject(jsonResponse!!)
            Checkout.getInstance().open(activity, gokwikDelegate, responseObject, environment)
        } catch (e: JSONException) {
            //Log.e(TAG, e.getMessage());
            e.printStackTrace()
        }
    }

    private val gokwikDelegate = object : GoKwikPaymentListner {
        override fun onPaymentSuccess(response: JSONObject?) {
            //Toast.makeText(activity, "Payment Success and response: " + response.toString(), Toast.LENGTH_LONG).show();
            result?.success(mapOf("status" to true, "data" to response.toString()))
        }

        override fun onPaymentError(error: String) {
            //Toast.makeText(activity, "Payment Fail: " + error, Toast.LENGTH_LONG).show();
            result?.success(mapOf("status" to false, "data" to error))
        }
    }

    private fun success(o: String) {
        if (!hasResponded) {
            hasResponded = true
            result?.success(o)
        }
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_gokwik")
            val plugin = FlutterGokwikPlugin(registrar, channel)
            //registrar.addGoKwikPaymentListner(plugin)
            channel.setMethodCallHandler(plugin)
        }
    }
}
