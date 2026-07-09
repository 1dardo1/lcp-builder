import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Título de la app, nombre propio, no se traduce.
  ///
  /// In es, this message translates to:
  /// **'LCP Builder'**
  String get appTitle;

  /// No description provided for @homeCrear.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get homeCrear;

  /// No description provided for @homeMostrar.
  ///
  /// In es, this message translates to:
  /// **'Mostrar'**
  String get homeMostrar;

  /// No description provided for @homeEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get homeEditar;

  /// No description provided for @noImplementado.
  ///
  /// In es, this message translates to:
  /// **'Aún no se ha implementado.'**
  String get noImplementado;

  /// No description provided for @crearMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get crearMenuTitle;

  /// No description provided for @entidadCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 entidad en el .lcp actual} other{{count} entidades en el .lcp actual}}'**
  String entidadCount(int count);

  /// No description provided for @finalizarLcp.
  ///
  /// In es, this message translates to:
  /// **'Finalizar lcp'**
  String get finalizarLcp;

  /// No description provided for @continuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continuar;

  /// No description provided for @errorPrefix.
  ///
  /// In es, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @nombrePaqueteTitle.
  ///
  /// In es, this message translates to:
  /// **'Nombre del paquete'**
  String get nombrePaqueteTitle;

  /// No description provided for @nombrePaqueteLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre (identifica el .lcp en COMP/CON)'**
  String get nombrePaqueteLabel;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @generadoSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Generado: {path}'**
  String generadoSnackbar(String path);

  /// No description provided for @ayuda.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get ayuda;

  /// No description provided for @cerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get cerrar;

  /// No description provided for @requerido.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get requerido;

  /// No description provided for @noCoincidePattern.
  ///
  /// In es, this message translates to:
  /// **'No coincide con: {hint}'**
  String noCoincidePattern(String hint);

  /// No description provided for @quitar.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get quitar;

  /// No description provided for @anadirCampo.
  ///
  /// In es, this message translates to:
  /// **'Añadir {label}'**
  String anadirCampo(String label);

  /// No description provided for @crearReferencia.
  ///
  /// In es, this message translates to:
  /// **'Crear {label}'**
  String crearReferencia(String label);

  /// No description provided for @idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @mostrarMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'Mostrar'**
  String get mostrarMenuTitle;

  /// No description provided for @abrirLcp.
  ///
  /// In es, this message translates to:
  /// **'Abrir un .lcp'**
  String get abrirLcp;

  /// No description provided for @abrirCarpeta.
  ///
  /// In es, this message translates to:
  /// **'Abrir una carpeta'**
  String get abrirCarpeta;

  /// No description provided for @carpetaSinLcp.
  ///
  /// In es, this message translates to:
  /// **'Esta carpeta no tiene ningún archivo .lcp.'**
  String get carpetaSinLcp;

  /// No description provided for @campoFaltante.
  ///
  /// In es, this message translates to:
  /// **'Falta: {label}'**
  String campoFaltante(String label);

  /// No description provided for @nElementos.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 elemento} other{{count} elementos}}'**
  String nElementos(int count);

  /// No description provided for @tipoCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 entidad} other{{count} entidades}}'**
  String tipoCount(int count);

  /// No description provided for @editar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @eliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get eliminar;

  /// No description provided for @confirmarEliminarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar entidad'**
  String get confirmarEliminarTitulo;

  /// No description provided for @confirmarEliminarMensaje.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta entidad? Esta acción no se puede deshacer.'**
  String get confirmarEliminarMensaje;

  /// No description provided for @guardarCambios.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get guardarCambios;

  /// No description provided for @guardarLcp.
  ///
  /// In es, this message translates to:
  /// **'Guardar .lcp'**
  String get guardarLcp;

  /// No description provided for @sinEntidades.
  ///
  /// In es, this message translates to:
  /// **'No quedan entidades de este tipo.'**
  String get sinEntidades;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
