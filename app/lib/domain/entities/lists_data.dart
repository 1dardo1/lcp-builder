/// Sección 17.5 del modelo de dominio.
///
/// Entidad: único objeto por LCP (no un array de instancias como el resto
/// de catálogos). Cada campo amplía las opciones ya presentes en COMP/CON
/// sin sustituirlas. Confirma la fusión ya anotada en el vault:
/// `tables.json` (v2) se renombró a `lists.json` (v3), mismo contenido.
class IListsData {
  final List<String>? pilotNames; // rolleable en Create New Pilot
  final List<String>? callsigns; // rolleable en Create New Pilot
  final List<String>? teamNames; // rolleable en Add New Group
  final List<String>? mechNames; // rolleable en Add New Mech to Hangar
  final List<String>? quirks; // tabla rolleable para pilotos Flash Cloned

  const IListsData({
    this.pilotNames,
    this.callsigns,
    this.teamNames,
    this.mechNames,
    this.quirks,
  });
}
