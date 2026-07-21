// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LCP Builder';

  @override
  String get homeCrear => 'Create';

  @override
  String get homeMostrar => 'Show';

  @override
  String get homeEditar => 'Edit';

  @override
  String get noImplementado => 'Not implemented yet.';

  @override
  String get crearMenuTitle => 'Create';

  @override
  String entidadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entities in the current .lcp',
      one: '1 entity in the current .lcp',
    );
    return '$_temp0';
  }

  @override
  String get finalizarLcp => 'Finalize lcp';

  @override
  String get continuar => 'Continue';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get nombrePaqueteTitle => 'Package name';

  @override
  String get nombrePaqueteLabel => 'Name (identifies the .lcp in COMP/CON)';

  @override
  String get cancelar => 'Cancel';

  @override
  String generadoSnackbar(String path) {
    return 'Generated: $path';
  }

  @override
  String get ayuda => 'Help';

  @override
  String get cerrar => 'Close';

  @override
  String get requerido => 'Required';

  @override
  String get revisaCamposMarcados => 'Check the fields marked in red.';

  @override
  String noCoincidePattern(String hint) {
    return 'Doesn\'t match: $hint';
  }

  @override
  String get quitar => 'Remove';

  @override
  String anadirCampo(String label) {
    return 'Add $label';
  }

  @override
  String crearReferencia(String label) {
    return 'Create $label';
  }

  @override
  String get idioma => 'Language';

  @override
  String get mostrarMenuTitle => 'Show';

  @override
  String get abrirLcp => 'Open a .lcp';

  @override
  String get abrirCarpeta => 'Open a folder';

  @override
  String get carpetaSinLcp => 'This folder has no .lcp files.';

  @override
  String campoFaltante(String label) {
    return 'Missing: $label';
  }

  @override
  String nElementos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String tipoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entities',
      one: '1 entity',
    );
    return '$_temp0';
  }

  @override
  String get editar => 'Edit';

  @override
  String get eliminar => 'Delete';

  @override
  String get confirmarEliminarTitulo => 'Delete entity';

  @override
  String get confirmarEliminarMensaje =>
      'Are you sure you want to delete this entity? This action cannot be undone.';

  @override
  String get guardarCambios => 'Save changes';

  @override
  String get guardarLcp => 'Save .lcp';

  @override
  String get sinEntidades => 'No entities of this type left.';

  @override
  String get crearTipoNuevo => 'Create new entity type';

  @override
  String get elegirTipoTitle => 'Choose entity type';

  @override
  String get editarPaquete => 'Edit package';

  @override
  String get manifestAutor => 'Author';

  @override
  String get manifestVersion => 'Version (X.Y.Z)';

  @override
  String get manifestDescripcion => 'Description';
}
