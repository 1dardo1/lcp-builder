// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LCP Builder';

  @override
  String get homeCrear => 'Crear';

  @override
  String get homeMostrar => 'Mostrar';

  @override
  String get homeEditar => 'Editar';

  @override
  String get noImplementado => 'Aún no se ha implementado.';

  @override
  String get crearMenuTitle => 'Crear';

  @override
  String entidadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entidades en el .lcp actual',
      one: '1 entidad en el .lcp actual',
    );
    return '$_temp0';
  }

  @override
  String get finalizarLcp => 'Finalizar lcp';

  @override
  String get continuar => 'Continuar';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get nombrePaqueteTitle => 'Nombre del paquete';

  @override
  String get nombrePaqueteLabel => 'Nombre (identifica el .lcp en COMP/CON)';

  @override
  String get cancelar => 'Cancelar';

  @override
  String generadoSnackbar(String path) {
    return 'Generado: $path';
  }

  @override
  String get ayuda => 'Ayuda';

  @override
  String get cerrar => 'Cerrar';

  @override
  String get requerido => 'Requerido';

  @override
  String get revisaCamposMarcados => 'Revisa los campos marcados en rojo.';

  @override
  String noCoincidePattern(String hint) {
    return 'No coincide con: $hint';
  }

  @override
  String get quitar => 'Quitar';

  @override
  String anadirCampo(String label) {
    return 'Añadir $label';
  }

  @override
  String crearReferencia(String label) {
    return 'Crear $label';
  }

  @override
  String get idioma => 'Idioma';

  @override
  String get mostrarMenuTitle => 'Mostrar';

  @override
  String get abrirLcp => 'Abrir un .lcp';

  @override
  String get abrirCarpeta => 'Abrir una carpeta';

  @override
  String get carpetaSinLcp => 'Esta carpeta no tiene ningún archivo .lcp.';

  @override
  String campoFaltante(String label) {
    return 'Falta: $label';
  }

  @override
  String nElementos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String tipoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entidades',
      one: '1 entidad',
    );
    return '$_temp0';
  }

  @override
  String get editar => 'Editar';

  @override
  String get eliminar => 'Eliminar';

  @override
  String get confirmarEliminarTitulo => 'Eliminar entidad';

  @override
  String get confirmarEliminarMensaje =>
      '¿Seguro que quieres eliminar esta entidad? Esta acción no se puede deshacer.';

  @override
  String get guardarCambios => 'Guardar cambios';

  @override
  String get guardarLcp => 'Guardar .lcp';

  @override
  String get sinEntidades => 'No quedan entidades de este tipo.';

  @override
  String get crearTipoNuevo => 'Crear entidad de tipo nuevo';

  @override
  String get elegirTipoTitle => 'Elegir tipo de entidad';

  @override
  String get editarPaquete => 'Editar paquete';

  @override
  String get manifestAutor => 'Autor';

  @override
  String get manifestVersion => 'Versión (X.Y.Z)';

  @override
  String get manifestDescripcion => 'Descripción';
}
