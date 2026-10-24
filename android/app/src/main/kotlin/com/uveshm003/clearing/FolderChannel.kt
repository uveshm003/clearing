package com.uveshm003.clearing

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.BatteryManager
import androidx.documentfile.provider.DocumentFile
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The folder automatic backups go to (FR-17a), through the Storage Access
 * Framework: the user picks a folder once and Clearing keeps permission to
 * write there, and only there. Dart side: `lib/data/backup_folder.dart`.
 *
 * Registered on the app's engine and on the headless one that runs the
 * nightly backup; only the app's can show the picker.
 */
class FolderChannel(
    private val context: Context,
    private val activity: () -> Activity?,
) : MethodChannel.MethodCallHandler {
    private var pending: MethodChannel.Result? = null

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "pick" -> pick(result)
                "describe" -> result.success(describe(call.argument<String>("folder")!!))
                "write" -> {
                    write(
                        call.argument<String>("folder")!!,
                        call.argument<String>("name")!!,
                        call.argument<ByteArray>("bytes")!!,
                    )
                    result.success(null)
                }
                "list" -> result.success(list(call.argument<String>("folder")!!))
                "read" -> result.success(
                    read(call.argument<String>("folder")!!, call.argument<String>("name")!!),
                )
                "delete" -> {
                    tree(call.argument<String>("folder")!!)
                        ?.findFile(call.argument<String>("name")!!)
                        ?.delete()
                    result.success(null)
                }
                "batteryOk" -> result.success(batteryOk())
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("folder", e.message, null)
        }
    }

    private fun pick(result: MethodChannel.Result) {
        val activity = activity() ?: return result.success(null)
        pending?.success(null)
        pending = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
        )
        activity.startActivityForResult(intent, REQUEST_PICK)
    }

    /** Called by [MainActivity.onActivityResult]; true if it was ours. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_PICK) return false
        val result = pending ?: return true
        pending = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        context.contentResolver.takePersistableUriPermission(
            uri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
        )
        result.success(uri.toString())
        return true
    }

    private fun tree(folder: String): DocumentFile? =
        DocumentFile.fromTreeUri(context, Uri.parse(folder))

    private fun describe(folder: String): String? {
        val segment = Uri.parse(folder).lastPathSegment ?: return null
        // "primary:Documents/Clearing" reads better as "Documents/Clearing".
        return segment.substringAfter(':').ifEmpty { tree(folder)?.name }
    }

    private fun write(folder: String, name: String, bytes: ByteArray) {
        val dir = tree(folder) ?: throw IllegalStateException("No folder")
        val file = dir.findFile(name)
            ?: dir.createFile("application/json", name)
            ?: throw IllegalStateException("Can't create $name")
        context.contentResolver.openOutputStream(file.uri, "wt").use { out ->
            requireNotNull(out).write(bytes)
        }
    }

    private fun list(folder: String): List<Map<String, Any?>> =
        tree(folder)?.listFiles()?.filter { it.isFile }?.map {
            mapOf("name" to it.name, "size" to it.length(), "modified" to it.lastModified())
        } ?: emptyList()

    private fun read(folder: String, name: String): String? {
        val file = tree(folder)?.findFile(name) ?: return null
        return context.contentResolver.openInputStream(file.uri)?.use {
            it.readBytes().toString(Charsets.UTF_8)
        }
    }

    /** Charging, or above 30%: a kind time for a backup. */
    private fun batteryOk(): Boolean {
        val battery = context.getSystemService(BatteryManager::class.java) ?: return true
        if (battery.isCharging) return true
        return battery.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) >= 30
    }

    companion object {
        const val CHANNEL = "clearing/folder"
        private const val REQUEST_PICK = 4417
    }
}
