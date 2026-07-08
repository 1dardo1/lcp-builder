import 'package:flutter/material.dart';

import '../../application/use_cases/crear_contenido_use_case.dart';
import '../../domain/domain.dart';
import '../../infrastructure/file_system/local_file_writer.dart';
import '../../infrastructure/lcp/zip_content_pack_exporter.dart';
import '../platform/lcp_save_location.dart';
import 'crear_session.dart';

/// Pide el nombre del paquete, dónde guardarlo, y exporta todo el contenido
/// acumulado en [session] como un único `.lcp`. Limpia la sesión y vuelve
/// al menú de Crear al terminar con éxito. Común a `CrearMenuScreen` (botón
/// "Finalizar lcp" con la sesión ya llena) y `CrearEntidadScreen` (mismo
/// botón, con la entidad que se estaba rellenando todavía sin añadir).
///
/// [pendingContentKey]/[pendingContent] son la entidad que
/// `CrearEntidadScreen` acaba de ensamblar pero aún no ha añadido a
/// [session] — se añade aquí, después de que el usuario confirme nombre y
/// ubicación, no antes. Si se añadiera antes de esos dos diálogos
/// cancelables, cancelar y volver a pulsar "Finalizar lcp" la duplicaría en
/// la sesión (la entidad ya añadida en el primer intento, más otra vez en
/// el segundo) — el propio ensamblado es idempotente, pero acumularla en
/// `session` no lo es.
///
/// El manifest necesita un `name` propio no reutilizado entre
/// exportaciones — COMP/CON identifica un content pack por su manifest, no
/// por el nombre de archivo (bug real ya documentado en vault "Principios y
/// decisiones clave"), así que se pide explícitamente en vez de usar un
/// valor fijo que colisionaría entre varias sesiones de Crear.
Future<void> finalizarLcp(
  BuildContext context,
  CrearSession session, {
  String? pendingContentKey,
  Object? pendingContent,
}) async {
  final packName = await showDialog<String>(
    context: context,
    builder: (dialogContext) => const _NombrePaqueteDialog(),
  );
  if (packName == null || packName.trim().isEmpty) return;
  if (!context.mounted) return;

  final outputPath = await pickLcpSaveLocation('$packName.lcp');
  if (outputPath == null) return;

  if (pendingContentKey != null && pendingContent != null) {
    session.add(pendingContentKey, pendingContent);
  }

  final manifest = ILcpManifestData(
    name: packName,
    author: 'LCP Builder',
    description: 'Generado desde el flujo Crear.',
    version: '0.1.0',
    v3: true,
  );

  final useCase = CrearContenidoUseCase(
    exporter: ZipContentPackExporter(),
    fileWriter: LocalFileWriter(),
  );

  try {
    await useCase(
      content: session.content,
      manifest: manifest,
      outputPath: outputPath,
    );
    session.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Generado: $outputPath')));
    Navigator.of(context).popUntil((route) => route.isFirst);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

class _NombrePaqueteDialog extends StatefulWidget {
  const _NombrePaqueteDialog();

  @override
  State<_NombrePaqueteDialog> createState() => _NombrePaqueteDialogState();
}

class _NombrePaqueteDialogState extends State<_NombrePaqueteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nombre del paquete'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nombre (identifica el .lcp en COMP/CON)',
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
