package com.example.lcp_builder

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
import android.system.Os
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Canal nativo mínimo de los flujos Crear/Mostrar/Editar en Android — ver
 * `lib/presentation/platform/lcp_save_location.dart`,
 * `lib/presentation/platform/lcp_edit_location.dart`,
 * `lib/infrastructure/file_system/android_saf_file_writer.dart` y
 * `lib/infrastructure/file_system/android_saf_file_reader.dart` /
 * `android_saf_directory_lister.dart`.
 *
 * `file_selector` no implementa guardado en Android, y su `openFile()`
 * solo entrega una copia local en caché (útil para leer, pero sin URI
 * `content://` viva para escribir de vuelta) — así que se habla
 * directamente con el Storage Access Framework: `ACTION_CREATE_DOCUMENT`
 * para elegir dónde guardar, `ACTION_OPEN_DOCUMENT` para elegir un `.lcp`
 * existente conservando permiso de escritura (necesario para Editar,
 * no para Mostrar — ver `lcp_edit_location.dart`), `DocumentsContract`
 * para listar los `.lcp` de una carpeta ya elegida, y `ContentResolver`
 * para leer/escribir esas URIs `content://`, ya que `dart:io` no sabe
 * hacerlo.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.example.lcp_builder/saf"
    private val createDocumentRequestCode = 4173
    private val openDocumentRequestCode = 4174

    private var pendingCreateDocumentResult: MethodChannel.Result? = null
    private var pendingOpenDocumentResult: MethodChannel.Result? = null

    /**
     * URI content:// fija que `createDocument`/`openDocument` devuelven en
     * vez de abrir el selector nativo del sistema, cuando un test de
     * aceptación la ha armado con `useTestSafDocument`. `null` en uso
     * normal, así que la app real siempre abre el selector de verdad.
     *
     * Existe porque `flutter test integration_test/... -d emulator` conduce
     * la app por el VM service, NO por la instrumentación de Android — así
     * que Espresso-Intents no puede interceptar `ACTION_CREATE_DOCUMENT`/
     * `ACTION_OPEN_DOCUMENT`, el selector real (DocumentsUI) se abre sin
     * que nada lo conteste, y el `await` de Dart se cuelga para siempre.
     * Armando esta URI, el test se salta esa UI imposible de automatizar
     * pero sigue ejerciendo el camino REAL de escritura/lectura SAF
     * (`writeBytes`/`readBytes`: `ContentResolver`, `Os.ftruncate`) — justo
     * el código donde vivían los bugs de guardado corregidos (#37/#38/#39).
     */
    private var testSafUriOverride: Uri? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "createDocument" -> {
                        val suggestedName = call.argument<String>("suggestedName") ?: "paquete.lcp"
                        startCreateDocument(suggestedName, result)
                    }
                    "openDocument" -> startOpenDocument(result)
                    "useTestSafDocument" -> useTestSafDocument(result)
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

    /**
     * Arma [testSafUriOverride] con un content:// del FileProvider de test
     * (source set `debug`, ver `AndroidManifest.xml`) a un archivo en la
     * caché de la app. SOLO lo llama un test de aceptación; la app normal
     * nunca lo invoca. Devuelve la URI también, por si el test la quiere.
     */
    private fun useTestSafDocument(result: MethodChannel.Result) {
        try {
            val dir = File(cacheDir, "acceptance_test").apply { mkdirs() }
            val file = File(dir, "acceptance.lcp")
            if (!file.exists()) file.createNewFile()
            val uri = FileProvider.getUriForFile(
                this,
                "com.example.lcp_builder.acceptancetest.fileprovider",
                file,
            )
            testSafUriOverride = uri
            result.success(uri.toString())
        } catch (e: Exception) {
            result.error("use_test_saf_document_failed", e.message, null)
        }
    }

    private fun startCreateDocument(suggestedName: String, result: MethodChannel.Result) {
        testSafUriOverride?.let {
            result.success(it.toString())
            return
        }
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
        if (requestCode == openDocumentRequestCode) {
            val result = pendingOpenDocumentResult
            pendingOpenDocumentResult = null
            if (resultCode == Activity.RESULT_OK) {
                val uri: Uri? = data?.data
                if (uri != null) {
                    try {
                        // Persiste el permiso de lectura/escritura más
                        // allá de esta única `Activity.RESULT_OK` — sin
                        // esto, Editar podría perder el permiso si el
                        // proceso se recicla entre abrir el `.lcp` y
                        // guardarlo. Algunos proveedores de documentos no
                        // soportan permiso persistente; si falla, el
                        // permiso temporal de esta sesión sigue siendo
                        // válido mientras la app no se reinicie.
                        contentResolver.takePersistableUriPermission(
                            uri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                        )
                    } catch (e: SecurityException) {
                        // Ver comentario de arriba.
                    }
                }
                result?.success(uri?.toString())
            } else {
                result?.success(null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun startOpenDocument(result: MethodChannel.Result) {
        testSafUriOverride?.let {
            result.success(it.toString())
            return
        }
        if (pendingOpenDocumentResult != null) {
            result.error("already_in_progress", "Ya hay un selector de apertura abierto", null)
            return
        }
        pendingOpenDocumentResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            // "*/*" en vez de un tipo MIME concreto: ".lcp" no tiene un
            // tipo MIME registrado, y distintos proveedores de documentos
            // lo reportan de forma distinta (application/octet-stream,
            // application/zip...) — filtrar por tipo aquí arriesgaría
            // excluir el propio archivo que el usuario quiere abrir.
            type = "*/*"
            // Editar necesita escribir de vuelta en el mismo documento
            // (a diferencia de Mostrar, que solo lee) — pedirlo aquí,
            // antes de lanzar el selector, es lo que hace que la URI que
            // devuelva tenga de verdad permiso de escritura concedido.
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        }
        try {
            startActivityForResult(intent, openDocumentRequestCode)
        } catch (e: Exception) {
            pendingOpenDocumentResult = null
            result.error("open_document_failed", e.message, null)
        }
    }

    /**
     * Escribe [bytes] en [uriString], sustituyendo el contenido anterior
     * por completo. No basta con el modo `"wt"` de
     * `ContentResolver.openOutputStream` (que en teoría ya trunca antes
     * de escribir): algunos proveedores de documentos no lo respetan del
     * todo, y si el contenido nuevo es más corto que el anterior quedan
     * bytes viejos al final del archivo — que para un `.zip` (formato de
     * `.lcp`) corrompe justo el directorio central del final, haciendo
     * que `lcp_manifest.json` deje de encontrarse al releer. Se trunca
     * explícitamente vía `Os.ftruncate` (la propia syscall POSIX, no
     * sujeta a cómo cada proveedor interprete la cadena de modo) antes de
     * escribir, como refuerzo.
     */
    private fun writeBytes(uriString: String, bytes: ByteArray, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(uriString)
            val pfd = contentResolver.openFileDescriptor(uri, "rwt")
                ?: throw IllegalStateException("No se pudo abrir el destino para escritura")
            pfd.use {
                try {
                    Os.ftruncate(it.fileDescriptor, 0)
                } catch (e: Exception) {
                    // Si el descriptor no soporta ftruncate, seguimos con
                    // el truncado que ya pide el propio modo "rwt" —
                    // mejor esfuerzo, no bloqueante.
                }
                ParcelFileDescriptor.AutoCloseOutputStream(it).use { stream ->
                    stream.write(bytes)
                }
            }
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
