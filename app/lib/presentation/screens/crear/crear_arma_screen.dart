import 'package:flutter/material.dart';

import '../../../application/use_cases/crear_arma_use_case.dart';
import '../../../domain/domain.dart';
import '../../../infrastructure/file_system/local_file_writer.dart';
import '../../../infrastructure/lcp/zip_content_pack_exporter.dart';
import '../../forms/generic_form_controller.dart';
import '../../forms/generic_form_view.dart';
import '../../forms/weapon_form_schema.dart';

/// Pantalla Crear (arma) — primer uso real del motor genérico. Sin diseño
/// de Figma todavía (`vault/UI-UX`): Material por defecto, funcional, no
/// definitivo. La ruta de guardado es fija (no hay selector de archivo
/// todavía — ese es un adapter de plataforma pendiente, ver ADR-002).
class CrearArmaScreen extends StatefulWidget {
  const CrearArmaScreen({super.key});

  @override
  State<CrearArmaScreen> createState() => _CrearArmaScreenState();
}

class _CrearArmaScreenState extends State<CrearArmaScreen> {
  final _controller = GenericFormController();
  final _schema = buildWeaponFormSchema();
  String? _resultMessage;

  Future<void> _crear() async {
    try {
      final weapon = weaponFromFormValues(_controller.values);
      final manifest = ILcpManifestData(
        name: '${weapon.name} — LCP Builder',
        author: 'LCP Builder',
        description: 'Generado desde el flujo Crear.',
        version: '0.1.0',
        v3: true,
      );
      final useCase = CrearArmaUseCase(
        exporter: ZipContentPackExporter(),
        fileWriter: LocalFileWriter(),
      );
      const outputPath = 'arma_creada.lcp';
      await useCase(weapon: weapon, manifest: manifest, outputPath: outputPath);
      setState(() => _resultMessage = 'Generado: $outputPath');
    } catch (e) {
      setState(() => _resultMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear arma')),
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
