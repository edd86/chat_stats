package dev.codedd.chat_stats

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "dev.codedd.chat_stats/app_intent"
    private var pendingFilePath: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        if (Intent.ACTION_VIEW == intent.action) {
            val uri = intent.data ?: return
            val copiedPath = copyContentUriToCache(uri)
            if (copiedPath != null) {
                pendingFilePath = copiedPath
                flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                    MethodChannel(messenger, CHANNEL).invokeMethod("onViewFile", copiedPath)
                }
            }
        }
    }

    private fun copyContentUriToCache(uri: Uri): String? {
        return try {
            var fileName = "imported_file"
            if (uri.scheme == "content") {
                contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                    val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (nameIndex != -1 && cursor.moveToFirst()) {
                        val name = cursor.getString(nameIndex)
                        if (!name.isNullOrBlank()) {
                            fileName = name
                        }
                    }
                }
            } else if (uri.scheme == "file") {
                val seg = uri.lastPathSegment
                if (!seg.isNullOrBlank()) {
                    fileName = seg
                }
            }

            val mimeType = contentResolver.getType(uri)
            if (!fileName.contains(".")) {
                if (mimeType == "application/zip" || mimeType?.contains("zip") == true) {
                    fileName += ".zip"
                } else if (mimeType == "text/plain" || mimeType?.contains("text") == true) {
                    fileName += ".txt"
                }
            }

            val destinationFile = File(cacheDir, fileName)
            contentResolver.openInputStream(uri)?.use { inputStream ->
                FileOutputStream(destinationFile).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
            destinationFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialFile" -> {
                    result.success(pendingFilePath)
                    pendingFilePath = null
                }
                "copyUriToCache" -> {
                    val uriStr = call.argument<String>("uri")
                    if (uriStr != null) {
                        val uri = Uri.parse(uriStr)
                        val path = copyContentUriToCache(uri)
                        result.success(path)
                    } else {
                        result.error("INVALID_ARGS", "URI is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
