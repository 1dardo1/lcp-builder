import 'package:flutter/material.dart';

import '../../../application/use_cases/crear_contenido_use_case.dart';
import '../../../domain/domain.dart';
import '../../../infrastructure/file_system/local_file_writer.dart';
import '../../../infrastructure/lcp/zip_content_pack_exporter.dart';
import '../../forms/entity_crear_config.dart';
import '../../forms/generic_form_controller.dart';
import '../../forms/generic_form_view.dart';
import '../../platform/lcp_save_location.dart';

/// Pantalla Crear genérica: una sola implementación para las 24 entidades,
/// parametrizada por [EntityCrearConfig]. Sin diseño de Figma todavía
/// (`vault/UI-UX`): Material por defecto, funcional, no definitivo. La
/// ruta de guardado la elige el usuario vía selector nativo
/// (`pickLcpSaveLocation`, adapter de plataforma — ver ADR-002).
class CrearEntidadScreen extends StatefulWidget {
  final EntityCrearConfig config;

  const CrearEntidadScreen({super.key, required this.config});

  @override
  State<CrearEntidadScreen> createState() => _CrearEntidadScreenState();
}

class _CrearEntidadScreenState extends State<CrearEntidadScreen> {
  final _controller = GenericFormController();
  late final _schema = widget.config.buildSchema();
  String? _resultMessage;

  Future<void> _crear() async {
    final config = widget.config;
    try {
      final content = config.fromFormValues(_controller.values);
      final id = config.idOf(content);
      final name = config.nameOf(content);
      final outputPath = await pickLcpSaveLocation('$id.lcp');
      if (outputPath == null) {
        setState(() => _resultMessage = 'Cancelado.');
        return;
      }
      final manifest = ILcpManifestData(
        name: '$name — LCP Builder',
        author: 'LCP Builder',
        description: 'Generado desde el flujo Crear.',
        version: '0.1.0',
        v3: true,
      );
      final useCase = CrearContenidoUseCase(
        exporter: ZipContentPackExporter(),
        fileWriter: LocalFileWriter(),
      );
      await useCase(
        contentKey: config.contentKey,
        content: content,
        manifest: manifest,
        outputPath: outputPath,
      );
      setState(() => _resultMessage = 'Generado: $outputPath');
    } catch (e) {
      setState(() => _resultMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GenericFormView(fields: _schema, controller: _controller),
            const SizedBox(height: 16),
            FilledButton(onPressed: _crear, child: const Text('Crear .lcp')),
            if (_resultMessage != null) ...[
              const SizedBox(height: 8),
              Text(_resultMessage!),
            ],
          ],
        ),
      ),
    );
  }
}
