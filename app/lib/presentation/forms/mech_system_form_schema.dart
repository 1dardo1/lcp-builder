import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IMechSystemData] (sección 13.4 del modelo de
/// dominio). Sin caso polimórfico propio — el bundle de campos (`id` hasta
/// `activeEffects`) vive en `common_entity_fields.dart`
/// (`mechSystemBaseFields()`/`mechSystemBaseFromValues()`) porque
/// [IWeaponModData] (§13.5) extiende exactamente estos mismos campos y los
/// necesita también.
List<FieldSpec> buildMechSystemFormSchema() => mechSystemBaseFields();

IMechSystemData mechSystemFromFormValues(Map<String, dynamic> values) {
  final base = mechSystemBaseFromValues(values);
  return IMechSystemData(
    id: base.id,
    name: base.name,
    source: base.source,
    license: base.license,
    licenseId: base.licenseId,
    licenseLevel: base.licenseLevel,
    type: base.type,
    effect: base.effect,
    description: base.description,
    sp: base.sp,
    tags: base.tags,
    actions: base.actions,
    bonuses: base.bonuses,
    noBonus: base.noBonus,
    synergies: base.synergies,
    noSynergy: base.noSynergy,
    deployables: base.deployables,
    counters: base.counters,
    integrated: base.integrated,
    specialEquipment: base.specialEquipment,
    activeEffects: base.activeEffects,
  );
}

final mechSystemCrearConfig = EntityCrearConfig(
  title: 'Crear mech system',
  contentKey: 'systems',
  buildSchema: buildMechSystemFormSchema,
  fromFormValues: mechSystemFromFormValues,
  idOf: (content) => (content as IMechSystemData).id,
  nameOf: (content) => (content as IMechSystemData).name,
);
