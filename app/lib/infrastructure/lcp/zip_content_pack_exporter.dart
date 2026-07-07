import 'dart:convert';

import 'package:archive/archive.dart';

import '../../domain/domain.dart';
import '../../domain/ports/content_pack_exporter.dart';
import 'domain_json_mapper.dart';

/// Implementa [ContentPackExporter]: produce los bytes de un `.lcp` —
/// un zip de un solo nivel (sin subcarpetas, requisito del formato) con
/// `lcp_manifest.json` y un archivo por tipo de contenido, tal como lo
/// espera COMP/CON.
///
/// Aquí (y solo aquí, en infraestructura) se conoce el tipo concreto de
/// cada entidad y cómo mapearla a JSON — el puerto (`ContentPackExporter`)
/// no lo sabe, por eso `content` llega como `Object` y se despacha en
/// tiempo de ejecución con un `switch` sobre el tipo real.
class ZipContentPackExporter implements ContentPackExporter {
  @override
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Object>> content,
  }) {
    final archive = Archive();

    void addJsonFile(String name, Object content) {
      final bytes = utf8.encode(
        const JsonEncoder.withIndent('  ').convert(content),
      );
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    addJsonFile('lcp_manifest.json', lcpManifestDataToJson(manifest));
    for (final entry in content.entries) {
      addJsonFile('${entry.key}.json', entry.value.map(_toJson).toList());
    }

    return ZipEncoder().encode(archive);
  }

  Object _toJson(Object item) => switch (item) {
    IWeaponData v => weaponDataToJson(v),
    IManufacturerData v => manufacturerDataToJson(v),
    ITagData v => tagDataToJson(v),
    ISkillData v => skillDataToJson(v),
    IStatusConditionData v => statusConditionDataToJson(v),
    ISitrepData v => sitrepDataToJson(v),
    IEnvironmentData v => environmentDataToJson(v),
    IBackgroundData v => backgroundDataToJson(v),
    IBondData v => bondDataToJson(v),
    IReserveData v => reserveDataToJson(v),
    ICoreBonusData v => coreBonusDataToJson(v),
    ITalentData v => talentDataToJson(v),
    _ => throw ArgumentError(
      'Tipo de contenido sin mapeo JSON: ${item.runtimeType}',
    ),
  };
}
