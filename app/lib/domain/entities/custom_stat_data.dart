/// Sección 15.4 del modelo de dominio.
///
/// Marca explícita de la fuente: funcionalidad "WARNING: EXPERIMENTAL" —
/// tratar con mayor cautela, la propia spec admite que puede cambiar.
///
/// Entidad (no catálogo de selección como [ITagData]): `key` identifica un
/// stat persistente que se aplica a todas las entidades de combate que lo
/// referencien, con efecto global dentro del LCP que lo declara. COMP/CON
/// no puede rastrear dependencias de stats entre LCPs distintos — un stat
/// nuevo debe quedar confinado a un único LCP.
///
/// Cuarta forma de variabilidad por tier de esta spec: `default` admite un
/// string `"X/Y/Z"` (separado por barras), distinto de [TierValue], de
/// [NpcSize] y de la interpolación `{X/Y/Z}` de Eidolons — no se unifican
/// en una sola abstracción porque la fuente tampoco lo hace.
class ICustomStatData {
  final String key; // único globalmente dentro del alcance del LCP
  final String title;
  final bool trackable; // true: stat current/max (como HP); false: solo-máximo (como Hull)
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
