package com.example.lcp_builder

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Canal nativo mínimo del flujo "Finalizar lcp" en Android — ver
 * `lib/presentation/platform/lcp_save_location.dart` y
 * `lib/infrastructure/file_system/android_saf_file_writer.dart`.
 *
 * `file_selector` no implementa guardado en Android, así que se habla
 * directamente con el Storage Access Framework: `ACTION_CREATE_DOCUMENT`
 * para elegir dónde guardar (con selector nativo, sin permisos de
 * almacenamiento en tiempo de ejecución — SAF los concede solo para la
 * URI elegida), y `ContentResolver` para escribir ahí, ya que `dart:io`
 * no sabe leer URIs `content://`.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.example.lcp_builder/saf"
    private val createDocumentRequestCode = 4173

    private var pendingCreateDocumentResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "createDocument" -> {
                        val suggestedName = call.argument<String>("suggestedName") ?: "paquete.lcp"
                        startCreateDocument(suggestedName, result)
                    }
                    "writeBytes" -> {
                        val uriString = call.argument<String>("uri")
                        val bytes = call.argument<ByteArray>("bytes")
                        if (uriString == null || bytes == null) {
                            result.error("invalid_arguments", "Faltan uri o bytes", null)
                        } else {
                            writeBytes(uriString, bytes, result)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startCreateDocument(suggestedName: String, result: MethodChannel.Result) {
        if (pendingCreateDocumentResult != null) {
            result.error("already_in_progress", "Ya hay un selector de guardado abierto", null)
            return
        }
        pendingCreateDocumentResult = result
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            // "application/octet-stream" en vez de un tipo MIME más
            // específico: algunos proveedores de documentos fuerzan la
            // extensión del tipo MIME por encima de EXTRA_TITLE, y
            // queremos conservar ".lcp" tal cual, no que se convierta en
            // ".zip" o similar.
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, suggestedName)
        }
        try {
            startActivityForResult(intent, createDocumentRequestCode)
        } catch (e: Exception) {
            pendingCreateDocumentResult = null
            result.error("create_document_failed", e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == createDocumentRequestCode) {
            val result = pendingCreateDocumentResult
            pendingCreateDocumentResult = null
            if (resultCode == Activity.RESULT_OK) {
                val uri: Uri? = data?.data
                result?.success(uri?.toString())
            } else {
                // El usuario canceló el selector — mismo contrato que
                // `file_selector` en Linux: null significa cancelado.
                result?.success(null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun writeBytes(uriString: String, bytes: ByteArray, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(uriString)
            val stream = contentResolver.openOutputStream(uri, "wt")
                ?: throw IllegalStateException("No se pudo abrir el destino para escritura")
            stream.use { it.write(bytes) }
            result.success(null)
        } catch (e: Exception) {
            result.error("write_failed", e.message, null)
        }
    }
}
