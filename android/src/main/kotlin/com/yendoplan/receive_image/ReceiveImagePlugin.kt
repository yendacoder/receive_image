package com.yendoplan.receive_image

import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Parcelable
import android.provider.OpenableColumns
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.*


class ReceiveImagePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler,
    ActivityAware {
    private var file: File? = null
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "receive_image")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "receive_image/files")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getInitialFile") {
            result.success(file?.absolutePath)
            file = null
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun updateBinding(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(fun(intent: Intent?): Boolean {
            intent?.let { handleIntent(it, binding.activity) }
            return false
        })
        handleIntent(binding.activity.intent, binding.activity)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        updateBinding(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // do nothing
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        updateBinding(binding)
    }

    override fun onDetachedFromActivity() {
        // do nothing
    }

    private fun copyFromStream(inputStream: InputStream, file: File): File {
        val outputStream: OutputStream = FileOutputStream(file)
        val buffer = ByteArray(1024)
        var length: Int
        while (inputStream.read(buffer).also { length = it } > 0) {
            outputStream.write(buffer, 0, length)
        }
        outputStream.close()
        inputStream.close()
        return file
    }

    private fun getNameFromUri(uri: Uri, context: Context): String {
        var name: String? = null
        val proj = arrayOf(
            OpenableColumns.DISPLAY_NAME
        )
        context.contentResolver.query(uri, proj, null, null, null)?.use { metadataCursor ->
            if (metadataCursor.moveToFirst()) {
                name = metadataCursor.getString(0)
            }
        }
        return name ?: throw IOException("Cannot read file name from uri $uri")
    }

    private fun handleIntent(intent: Intent, context: Context) {
        (intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as? Uri)?.let {
            try {
                context.contentResolver.openInputStream(it).use { stream ->
                    if (stream != null) {
                        val res = copyFromStream(
                            stream,
                            File(context.cacheDir, getNameFromUri(it, context))
                        )
                        if (eventSink == null) {
                            file = res
                        } else {
                            eventSink?.success(res.absolutePath)
                        }
                    }
                }
            } catch (e: IOException) {
                Log.e("ReceiveImage", "Unable to read input stream", e)
            }
        }
    }
}
