import 'field_spec.dart';

/// Describe cómo el motor genérico de "Crear" (`CrearEntidadScreen`) debe
/// tratar una entidad concreta, sin que el motor necesite conocer sus 24
/// tipos de dominio. Cada esquema de entidad (`weapon_form_schema.dart`,
/// `manufacturer_form_schema.dart`...) expone una instancia de esta clase.
class EntityCrearConfig {
  /// Título de la pantalla y de la entrada en el menú Crear.
  final String title;

  /// Nombre de archivo dentro del `.lcp` (sin `.json`), ej. `'weapons'`.
  final String contentKey;

  final List<FieldSpec> Function() buildSchema;
  final Object Function(Map<String, dynamic> values) fromFormValues;

  /// Extraen `id`/`name` del objeto de dominio ya ensamblado — el motor
  /// los usa para el nombre de archivo sugerido y el manifest, sin
  /// necesitar un tipo común entre las 24 entidades.
  final String Function(Object content) idOf;
  final String Function(Object content) nameOf;

  const EntityCrearConfig({
    required this.title,
    required this.contentKey,
    required this.buildSchema,
    required this.fromFormValues,
    required this.idOf,
    required this.nameOf,
  });
}
