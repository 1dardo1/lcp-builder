package com.example.lcp_builder

import android.app.Activity
import android.app.Instrumentation
import android.content.Intent
import androidx.core.content.FileProvider
import androidx.test.espresso.intent.Intents
import androidx.test.espresso.intent.Intents.intending
import androidx.test.espresso.intent.matcher.IntentMatchers.hasAction
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.integration_test.FlutterTestRunner
import java.io.File
import org.junit.Rule
import org.junit.runner.RunWith
import org.junit.runner.notification.RunNotifier

/**
 * Runner de test de aceptación — envuelve el [FlutterTestRunner] oficial
 * del paquete `integration_test` (que se limita a lanzar la Activity vía
 * `ActivityTestRule.launchActivity` y esperar los resultados que reporte
 * el lado Dart, ver su código fuente en
 * `packages/integration_test/android/.../FlutterTestRunner.java`) para
 * inicializar Espresso-Intents ANTES de que arranque la app.
 *
 * No se puede hacer esto con un `@Before` normal en [MainActivityTest]:
 * `FlutterTestRunner` es un `org.junit.runner.Runner` a medida, no ejecuta
 * el ciclo de vida estándar de JUnit4 (llama a `launchActivity` a mano),
 * así que un `@Before` ahí nunca llegaría a invocarse.
 *
 * Intercepta `ACTION_CREATE_DOCUMENT`/`ACTION_OPEN_DOCUMENT` (ver
 * `MainActivity.kt`) antes de que se abra el selector real de Android
 * (otra app, DocumentsUI, frágil de automatizar) y responde con la URI
 * de un mismo archivo servido por el FileProvider de test (ver
 * `AndroidManifest.xml` de `debug`) — el mismo `.lcp` que "crea" el test
 * hace de origen al "editarlo" después, como pediría un uso real. Todo
 * lo que viene después de esa URI sigue siendo real: `ContentResolver`,
 * permisos, truncado — el código exacto donde vivían los tres bugs de
 * guardado ya corregidos (ver PRs #37/#38/#39).
 */
class AcceptanceTestRunner(testClass: Class<*>) : FlutterTestRunner(testClass) {
    override fun run(notifier: RunNotifier) {
        Intents.init()
        try {
            val context = InstrumentationRegistry.getInstrumentation().targetContext
            val dir = File(context.cacheDir, "acceptance_test").apply { mkdirs() }
            val lcpFile = File(dir, "acceptance.lcp")
            val uri = FileProvider.getUriForFile(
                context,
                "com.example.lcp_builder.acceptancetest.fileprovider",
                lcpFile,
            )
            for (action in listOf(Intent.ACTION_CREATE_DOCUMENT, Intent.ACTION_OPEN_DOCUMENT)) {
                intending(hasAction(action)).respondWith(
                    Instrumentation.ActivityResult(Activity.RESULT_OK, Intent().setData(uri)),
                )
            }
            super.run(notifier)
        } finally {
            Intents.release()
        }
    }
}

@RunWith(AcceptanceTestRunner::class)
class MainActivityTest {
    @Rule
    @JvmField
    val rule = ActivityTestRule(MainActivity::class.java, true, false)
}
