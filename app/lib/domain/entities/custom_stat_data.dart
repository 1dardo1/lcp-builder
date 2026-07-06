/// Sección 15.4 del modelo de dominio. Marcado "WARNING: EXPERIMENTAL" por
/// la propia fuente — tratar con más cautela que el resto del dominio.
///
/// Entidad (no catálogo de selección como [ITagData]): `key` tiene efecto
/// global dentro del LCP que lo declara, sin identidad compartible entre
/// LCPs. Ver vault MdD §15.4 (incluye la cuarta forma de variabilidad por
/// tier de esta spec, en `default`).
class ICustomStatData {
  final String key; // único globalmente dentro del alcance del LCP
  final String title;
  final bool
  trackable; // true: stat current/max (como HP); false: solo-máximo (como Hull)
  final Object? defaultValue; // num | string "X/Y/Z" — default 0 si se omite
  final String icon; // formato "mdi-ICON_ID"
  final num sort; // puede ser negativo para forzar primera posición

  const ICustomStatData({
    required this.key,
    required this.title,
    required this.trackable,
    this.defaultValue,
    required this.icon,
    required this.sort,
  });
}
