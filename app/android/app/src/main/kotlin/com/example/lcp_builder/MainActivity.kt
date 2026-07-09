package com.example.lcp_builder

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Canal nativo mínimo de los flujos Crear/Mostrar en Android — ver
 * `lib/presentation/platform/lcp_save_location.dart`,
 * `lib/infrastructure/file_system/android_saf_file_writer.dart` y
 * `lib/infrastructure/file_system/android_saf_file_reader.dart` /
 * `android_saf_directory_lister.dart`.
 *
 * `file_selector` no implementa guardado en Android, y tampoco sabe
 * recorrer el contenido de una carpeta elegida con `getDirectoryPath`
 * (esa parte SÍ la resuelve `file_selector`, solo falta listar lo que
 * hay dentro) — así que se habla directamente con el Storage Access
 * Framework: `ACTION_CREATE_DOCUMENT` para elegir dónde guardar,
 * `DocumentsContract` para listar los `.lcp` de una carpeta ya elegida,
 * y `ContentResolver` para leer/escribir esas URIs `content://`, ya que
 * `dart:io` no sabe hacerlo.
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
                    "readBytes" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString == null) {
                            result.error("invalid_arguments", "Falta uri", null)
                        } else {
                            readBytes(uriString, result)
                        }
                    }
                    "listLcpFiles" -> {
                        val treeUriString = call.argument<String>("treeUri")
                        if (treeUriString == null) {
                            result.error("invalid_arguments", "Falta treeUri", null)
                        } else {
                            listLcpFiles(treeUriString, result)
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

    private fun readBytes(uriString: String, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(uriString)
            val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() }
                ?: throw IllegalStateException("No se pudo abrir el origen para lectura")
            result.success(bytes)
        } catch (e: Exception) {
            result.error("read_failed", e.message, null)
        }
    }

    /**
     * Lista los `.lcp` directos dentro de la carpeta [treeUriString] — la
     * URI de árbol que devuelve `file_selector`'s `getDirectoryPath` en
     * Android. No recorre subcarpetas (mismo criterio que
     * `LocalLcpDirectoryLister` en Linux).
     */
    private fun listLcpFiles(treeUriString: String, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(treeUriString)
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
                treeUri,
                DocumentsContract.getTreeDocumentId(treeUri),
            )
            val projection = arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            )
            val items = mutableListOf<Map<String, String>>()
            contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                val idIndex = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameIndex = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                while (cursor.moveToNext()) {
                    val name = cursor.getString(nameIndex) ?: continue
                    if (!name.lowercase().endsWith(".lcp")) continue
                    val docId = cursor.getString(idIndex)
                    val docUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)
                    items.add(mapOf("uri" to docUri.toString(), "name" to name))
                }
            }
            items.sortBy { it["name"] }
            result.success(items)
        } catch (e: Exception) {
            result.error("list_failed", e.message, null)
        }
    }
}
