import 'package:flutter/widgets.dart';

/// Diccionario de traducción es→en para el contenido dinámico de los
/// esquemas de formulario (`FieldSpec.label`/`helpText`/`patternHint`,
/// `EntityCrearConfig.title`) — a diferencia del "armazón" fijo de la app
/// (menús, botones, diálogos), que usa `AppLocalizations` generado desde
/// ARB (ver `l10n/app_es.arb`/`app_en.arb`).
///
/// Por qué un mapa en vez de restructurar `FieldSpec` para que `label`
/// sea una función de `BuildContext`: las 24 entidades ya tienen ~450
/// strings fijos en español, escritos como literales `const` — pedirle a
/// cada `buildXFormSchema()` que en vez de eso conozca `AppLocalizations`
/// habría significado reescribir las 24 entidades y perder la posibilidad
/// de que sigan siendo `const`. En vez de eso, el texto en español sigue
/// siendo la fuente de verdad (como hasta ahora); este mapa traduce esa
/// misma cadena a inglés en el punto de render (`GenericFormView`), y si
/// una cadena no está en el mapa, se muestra el español sin más — nunca
/// una pantalla en blanco.
final Map<String, String> esToEnFieldText = {
  'AP (ignora armadura)': 'AP (ignores armor)',
  'Accuracy': 'Accuracy',
  'Accuracy asociado': 'Associated accuracy',
  'Actions': 'Actions',
  'Actions (activo)': 'Actions (active)',
  'Actions (mientras esté activo)': 'Actions (while active)',
  'Actions (siempre disponibles)': 'Actions (always available)',
  'Actions (solo disponibles con el piloto UNMOUNTED)':
      'Actions (only available with the pilot UNMOUNTED)',
  'Activación': 'Activation',
  'Active effect': 'Active effect',
  'Active effects': 'Active effects',
  'Active effects (al activar)': 'Active effects (on activation)',
  'Active effects (se aplican al piloto, no al mech)':
      'Active effects (apply to the pilot, not the mech)',
  'Activo': 'Active',
  'Acumulativo': 'Cumulative',
  'Alcance': 'Range',
  'Alcance añadido': 'Added range',
  'Alineación vertical (banner UI)': 'Vertical alignment (UI banner)',
  'Ammo': 'Ammo',
  'AoE': 'AoE',
  'AoE (texto)': 'AoE (text)',
  'Apariencia': 'Appearance',
  'Armor': 'Armor',
  'Asignada automáticamente': 'Automatically assigned',
  'Atributo': 'Attribute',
  'Attack bonus': 'Attack bonus',
  'Añade otro efecto': 'Adds another effect',
  'Añade resist/vulnerability/immunity': 'Adds resist/vulnerability/immunity',
  'Añade special status': 'Adds special status',
  'Añade status/condition': 'Adds status/condition',
  'Barrage': 'Barrage',
  'Bonus': 'Bonus',
  'Bonuses': 'Bonuses',
  'Bonuses (activo)': 'Bonuses (active)',
  'Bonuses (siempre activos)': 'Bonuses (always active)',
  'Build feature (sin efecto en combate)':
      'Build feature (no effect in combat)',
  'Caveat (reglas especiales no trackeadas por COMP/CON)':
      'Caveat (special rules not tracked by COMP/CON)',
  'Cita': 'Quote',
  'Color hexadecimal (sin el "#") usado como acento cuando COMP/CON está en modo claro, ej. "FFDD55".':
      'Hex color (without the "#") used as an accent when COMP/CON is in light mode, e.g. "FFDD55".',
  'Color hexadecimal (sin el "#") usado como acento cuando COMP/CON está en modo oscuro, ej. "552200".':
      'Hex color (without the "#") used as an accent when COMP/CON is in dark mode, e.g. "552200".',
  'Color tema claro (#XXXXXX)': 'Light theme color (#XXXXXX)',
  'Color tema oscuro (#XXXXXX)': 'Dark theme color (#XXXXXX)',
  'Condiciones de victoria (no confirmado de forma cruzada)':
      'Victory conditions (not cross-verified)',
  'Condición': 'Condition',
  'Condición de gating': 'Gating condition',
  'Consejos de cómo jugar/usar este NPC en mesa, para el máster.':
      'Tips on how to play/use this NPC at the table, for the GM.',
  'Consumible': 'Consumable',
  'Contenido SVG del icono del fabricante. Opcional.':
      "SVG content of the manufacturer's icon. Optional.",
  'Contenido SVG del icono. Opcional.': 'SVG content of the icon. Optional.',
  'Core system': 'Core system',
  'Coste': 'Cost',
  'Coste (si el padre es limited)': 'Cost (if the parent is limited)',
  'Coste (si es limited)': 'Cost (if limited)',
  'Coste (si tiene tag limited)': 'Cost (if it has the limited tag)',
  'Coste en System Points del arma. Si se omite, cuenta como 0.':
      "The weapon's System Points cost. If omitted, counts as 0.",
  'Counters': 'Counters',
  'Cover': 'Cover',
  'Cuándo se activa este efecto, si no es siempre (texto libre).':
      'When this effect activates, if not always (free text).',
  'Cómo cambia visualmente el eidolon en esta capa.':
      "How the eidolon's appearance changes at this layer.",
  'Cómo se colocan los mechs en el mapa al empezar.':
      'How mechs are placed on the map at the start.',
  'Cómo termina/se sale de la misión.': 'How the mission ends/is exited.',
  'Datos de la armadura de piloto': 'Pilot armor data',
  'Datos de reaction': 'Reaction data',
  'Datos de tech': 'Tech data',
  'Datos de weapon': 'Weapon data',
  'Datos del arma de piloto': 'Pilot weapon data',
  'Datos del gear de piloto': 'Pilot gear data',
  'Daño': 'Damage',
  'Daño añadido (regla de fusión por tipo, ver vault §13.5)':
      'Added damage (merge-by-type rule, see vault §13.5)',
  'Daño extra': 'Bonus damage',
  'Daño por tier (3 enteros)': 'Damage by tier (3 integers)',
  'De dónde viene este power (ej. clock, minor ideal...).':
      'Where this power comes from (e.g. clock, minor ideal...).',
  'Deployables': 'Deployables',
  'Deployables (solo disponibles con el piloto UNMOUNTED)':
      'Deployables (only available with the pilot UNMOUNTED)',
  'Deprecated': 'Deprecated',
  'Desactivación': 'Deactivation',
  'Descripción': 'Description',
  'Descripción (puede contener {VAL})': 'Description (may contain {VAL})',
  'Descripción (terso)': 'Description (terse)',
  'Descripción corta': 'Short description',
  'Despliegue': 'Deployment',
  'Detalle': 'Detail',
  'Detalle (flavor text)': 'Detail (flavor text)',
  'Duración': 'Duration',
  'Duración de uso': 'Usage duration',
  'E-Defense': 'E-Defense',
  'Efecto': 'Effect',
  'Efecto (activo)': 'Effect (active)',
  'Efecto (pasivo)': 'Effect (passive)',
  'Efecto al instalar en un mount': 'Effect when installed on a mount',
  'Efectos': 'Effects',
  'El ID de la NPC Class o Template de la que viene esta feature.':
      'The ID of the NPC Class or Template this feature comes from.',
  'El ID de la feature que esta modifica, no su nombre visible.':
      'The ID of the feature this one modifies, not its display name.',
  'El ID de otro sistema/equipo incluido gratis, no su nombre.':
      'The ID of another system/equipment included for free, not its name.',
  'El ID de otro sistema/equipo que se instala automáticamente con este core bonus, no su nombre visible.':
      'The ID of another system/equipment automatically installed with this core bonus, not its display name.',
  'El ID de otro sistema/equipo que viene incluido gratis con este, no su nombre visible.':
      'The ID of another system/equipment included for free with this one, not its display name.',
  'El ID de otro template incompatible con este, no su nombre.':
      'The ID of another template incompatible with this one, not its name.',
  'El ID de un trigger (skill), no su nombre visible.':
      'The ID of a trigger (skill), not its display name.',
  'El ID del equipo especial asociado, no su nombre visible.':
      'The ID of the associated special equipment, not its display name.',
  'El ID del equipo especial que se desbloquea, no su nombre.':
      'The ID of the special equipment being unlocked, not its name.',
  'El ID del fabricante (Manufacturer), NO su nombre visible. Ej.: si el fabricante se llama "General Manufacturing Systems" pero su ID es "GMS", aquí va "GMS". Si el fabricante todavía no existe, usa el botón de abajo para crearlo sin salir de este formulario.':
      'The manufacturer\'s ID, NOT its display name. E.g.: if the manufacturer is called "General Manufacturing Systems" but its ID is "GMS", this field takes "GMS". If the manufacturer doesn\'t exist yet, use the button below to create it without leaving this form.',
  'El ID del fabricante (Manufacturer), no su nombre visible.':
      "The manufacturer's ID, not its display name.",
  'El ID del fabricante requerido para esta specialty, no su nombre visible.':
      "The ID of the manufacturer required for this specialty, not its display name.",
  'El ID del frame (Frame) al que pertenece esta arma — no su nombre visible. Si el frame todavía no existe, créalo con el botón de abajo; el id que le pongas ahí es el que va aquí.':
      "The ID of the frame this weapon belongs to — not its display name. If the frame doesn't exist yet, create it with the button below; the id you give it there is the one that goes here.",
  'El ID del frame al que pertenece, no su nombre visible.':
      "The ID of the frame it belongs to, not its display name.",
  'El ID del status o condition (ej. "immobilized", "stunned"), no su nombre visible. Si todavía no existe, créalo primero desde "Crear status/condition" en el menú.':
      'The ID of the status/condition (e.g. "immobilized", "stunned"), not its display name. If it doesn\'t exist yet, create it first from "Create status/condition" in the menu.',
  'El ID del status/condition al que es inmune, no su nombre.':
      'The ID of the status/condition it is immune to, not its name.',
  'El ID del tag (Tag), no su nombre visible. Si el tag todavía no existe, usa el botón de crear tag desde el menú.':
      "The tag's ID, not its display name. If the tag doesn't exist yet, use the create-tag button from the menu.",
  'El identificador corto que usarán otras entidades para referenciar este fabricante (ej. en el campo "Fabricante" de un arma). Minúsculas o mayúsculas, sin espacios.':
      'The short identifier other entities will use to reference this manufacturer (e.g. in a weapon\'s "Manufacturer" field). Upper or lower case, no spaces.',
  'El nombre completo que verá el jugador en COMP/CON.':
      'The full name the player will see in COMP/CON.',
  'El nombre de la parte activa del core system (la que se activa).':
      "The name of the core system's active half (the one that gets activated).",
  'El nombre de la parte pasiva del core system, si tiene una.':
      "The name of the core system's passive half, if it has one.",
  'El nombre del atributo especial a quitar (debe coincidir exactamente con el que se añadió en otro sitio).':
      'The name of the special attribute to remove (must match exactly the one added elsewhere).',
  'El nombre que verá el jugador en COMP/CON, ej. "Rifle pesado".':
      'The name the player will see in COMP/CON, e.g. "Heavy Rifle".',
  'El nombre que verá el jugador en COMP/CON.':
      'The name the player will see in COMP/CON.',
  'El nombre visible de esta capa del eidolon.':
      "This eidolon layer's display name.",
  'El nombre visible de este efecto activo, ej. "Overcharged".':
      'The display name of this active effect, e.g. "Overcharged".',
  'El nombre visible de este perfil de disparo del arma.':
      "This weapon firing profile's display name.",
  'El nombre visible de este power del bond.':
      "This bond power's display name.",
  'El nombre visible de este rank del talento.':
      "This talent rank's display name.",
  'El nombre visible de este tipo de munición.':
      'The display name of this ammo type.',
  'El nombre visible de este trait del frame.':
      "This frame trait's display name.",
  'El nombre visible de la acción, ej. "Skirmish".':
      'The display name of the action, e.g. "Skirmish".',
  'El nombre visible de la clase de NPC, ej. "Guard".':
      'The display name of the NPC class, e.g. "Guard".',
  'El nombre visible de la feature.': "The feature's display name.",
  'El nombre visible de la licencia (normalmente el nombre del frame al que pertenece el arma), ej. "GMS Everest". A diferencia de "ID de la licencia" de abajo, aquí va el nombre, no el id.':
      'The license\'s display name (usually the name of the frame the weapon belongs to), e.g. "GMS Everest". Unlike "License ID" below, this field takes the name, not the id.',
  'El nombre visible de la reserve, ej. "Bounty Reserve".':
      'The display name of the reserve, e.g. "Bounty Reserve".',
  'El nombre visible de la situación/misión.':
      'The display name of the situation/mission.',
  'El nombre visible del background, ej. "Colony Kid".':
      'The display name of the background, e.g. "Colony Kid".',
  'El nombre visible del bond, ej. "The Hunter".':
      'The display name of the bond, e.g. "The Hunter".',
  'El nombre visible del contador, ej. "Cargas de granada".':
      'The display name of the counter, e.g. "Grenade charges".',
  'El nombre visible del core bonus.': "The core bonus's display name.",
  'El nombre visible del core system, ej. "Sunder Cannon".':
      'The display name of the core system, e.g. "Sunder Cannon".',
  'El nombre visible del deployable, ej. "Recon Drone".':
      "The deployable's display name, e.g. \"Recon Drone\".",
  'El nombre visible del entorno, ej. "Sistema de Dombrovski".':
      'The display name of the environment, e.g. "Dombrovski System".',
  'El nombre visible del frame, ej. "Everest".':
      'The display name of the frame, e.g. "Everest".',
  'El nombre visible del pilot gear.': "The pilot gear's display name.",
  'El nombre visible del tag, ej. "Limited".':
      'The display name of the tag, e.g. "Limited".',
  'El nombre visible del talento, ej. "Gunslinger".':
      'The display name of the talent, e.g. "Gunslinger".',
  'El nombre visible del template, ej. "Elite".':
      'The display name of the template, e.g. "Elite".',
  'El nombre visible del trigger, ej. "Assault".':
      'The display name of the trigger, e.g. "Assault".',
  'El nombre visible, ej. "Stunned".':
      'The display name, e.g. "Stunned".',
  'El stat contra el que tira el objetivo, en minúsculas (ej. "hull", "agility", "systems", "engineering").':
      'The stat the target rolls against, lowercase (e.g. "hull", "agility", "systems", "engineering").',
  'El tipo de mount que ocupa el arma en el frame (Main, Heavy, Aux, Flex...). Determina en qué hueco del mech se puede instalar.':
      'The type of mount the weapon occupies on the frame (Main, Heavy, Aux, Flex...). Determines which slot on the mech it can be installed in.',
  'Escribe exactamente "Drone", "Mine" o "Deployable" para los tipos estándar, o cualquier otro texto para un tipo personalizado.':
      'Type exactly "Drone", "Mine" or "Deployable" for the standard types, or any other text for a custom type.',
  'Este bonus todavía no tiene forma confirmada en el modelo de dominio — escribe el valor tal cual aparece en la spec oficial.':
      "This bonus doesn't have a confirmed shape in the domain model yet — enter the value exactly as it appears in the official spec.",
  'Estructurado': 'Structured',
  'Etiqueta (default: el nombre)': 'Label (default: the name)',
  'Etiqueta libre para agrupar en la UI, ej. "Striker", "Tank".':
      'Free-text label to group items in the UI, e.g. "Striker", "Tank".',
  'Evasion': 'Evasion',
  'Exclusivo (relacional entre los ranks de este talento)':
      'Exclusive (relational between this talent\'s ranks)',
  'Extracción': 'Extraction',
  'Fabricante (Manufacturer ID)': 'Manufacturer (Manufacturer ID)',
  'Fabricante (debe coincidir con un Manufacturer ID)':
      'Manufacturer (must match a Manufacturer ID)',
  'Fabricante (source)': 'Manufacturer (source)',
  'Fabricante (source; opcional solo en License Collection)':
      'Manufacturer (source; optional only in License Collection)',
  'Familia (solo posición en la lista)': 'Family (list position only)',
  'Features': 'Features',
  'Flavor (texto de Compendium)': 'Flavor (Compendium text)',
  'Force tag (bloquea el tag NPC, no editable por el usuario)':
      'Force tag (locks the NPC tag, not user-editable)',
  'Forma del área de efecto, como aparece en la tarjeta — ej. "3-cone", "1-line", "burst 1".':
      'Shape of the area of effect, as it appears on the card — e.g. "3-cone", "1-line", "burst 1".',
  'Frase corta que resume qué representa este trigger.':
      'Short phrase summarizing what this trigger represents.',
  'Frecuencia': 'Frequency',
  'Fórmula': 'Formula',
  'Fórmula (ej. {grit}+2)': 'Formula (e.g. {grit}+2)',
  'Fórmula en vez de número fijo — usa llaves para referirte a un stat del piloto/mech, ej. "{grit}+2" o "{level}".':
      'Formula instead of a fixed number — use braces to refer to a pilot/mech stat, e.g. "{grit}+2" or "{level}".',
  'Gear': 'Gear',
  'HP': 'HP',
  'Heat cap': 'Heat cap',
  'Hints (dirigido a jugadores)': 'Hints (aimed at players)',
  'Hostile characters (dinámico, resuelto por COMP/CON)':
      'Hostile characters (dynamic, resolved by COMP/CON)',
  'ID': 'ID',
  'ID (acrónimo, ej. GMS)': 'ID (acronym, e.g. GMS)',
  'ID de la licencia (frame)': 'License ID (frame)',
  'ID de la licencia (frame; opcional solo en License Collection)':
      'License ID (frame; optional only in License Collection)',
  'ID de la licencia principal (requerido si es variante)':
      'Primary license ID (required if it is a variant)',
  'ID de skill': 'Skill ID',
  'ID de status/condition': 'Status/condition ID',
  'ID del tag': 'Tag ID',
  'ID del tag (ej. tg_accurate)': 'Tag ID (e.g. tg_accurate)',
  'Icono (SVG)': 'Icon (SVG)',
  'Icono (URL, si no hay SVG)': 'Icon (URL, if there is no SVG)',
  'Ideal': 'Ideal',
  'Ideales mayores (2-5 típicamente)': 'Major ideals (typically 2-5)',
  'Ideales menores (2-5 típicamente)': 'Minor ideals (typically 2-5)',
  'Identificador con el que otras entidades referencian este status/condition (ej. en `IStatusEffectData.id`). Minúsculas, sin espacios.':
      'The identifier other entities use to reference this status/condition (e.g. in `IStatusEffectData.id`). Lowercase, no spaces.',
  'Identificador con el que otras entidades referencian este tag (ej. "limited"). Minúsculas, sin espacios.':
      'The identifier other entities use to reference this tag (e.g. "limited"). Lowercase, no spaces.',
  'Identificador interno de este contador. Minúsculas, sin espacios.':
      "This counter's internal identifier. Lowercase, no spaces.",
  'Identificador único de la clase de NPC. Minúsculas, sin espacios.':
      'Unique identifier of the NPC class. Lowercase, no spaces.',
  'Identificador único de la feature. Minúsculas, sin espacios.':
      "Unique identifier of the feature. Lowercase, no spaces.",
  'Identificador único de la reserve. Minúsculas, sin espacios.':
      'Unique identifier of the reserve. Lowercase, no spaces.',
  'Identificador único del arma dentro de todo el .lcp (y, en la práctica, dentro de todo COMP/CON). Minúsculas, sin espacios — ej. "mw_rifle_pesado". No es el nombre visible, eso va en "Nombre".':
      'Unique identifier of the weapon within the whole .lcp (and, in practice, within all of COMP/CON). Lowercase, no spaces — e.g. "mw_heavy_rifle". Not the display name, that goes in "Name".',
  'Identificador único del background. Minúsculas, sin espacios.':
      'Unique identifier of the background. Lowercase, no spaces.',
  'Identificador único del bond. Minúsculas, sin espacios.':
      'Unique identifier of the bond. Lowercase, no spaces.',
  'Identificador único del core bonus. Minúsculas, sin espacios.':
      'Unique identifier of the core bonus. Lowercase, no spaces.',
  'Identificador único del eidolon layer. Minúsculas, sin espacios.':
      'Unique identifier of the eidolon layer. Lowercase, no spaces.',
  'Identificador único del entorno. Minúsculas, sin espacios.':
      'Unique identifier of the environment. Lowercase, no spaces.',
  'Identificador único del frame. Minúsculas, sin espacios.':
      'Unique identifier of the frame. Lowercase, no spaces.',
  'Identificador único del pilot gear. Minúsculas, sin espacios.':
      'Unique identifier of the pilot gear. Lowercase, no spaces.',
  'Identificador único del sitrep. Minúsculas, sin espacios.':
      'Unique identifier of the sitrep. Lowercase, no spaces.',
  'Identificador único del talento. Minúsculas, sin espacios.':
      'Unique identifier of the talent. Lowercase, no spaces.',
  'Identificador único del template. Minúsculas, sin espacios.':
      'Unique identifier of the template. Lowercase, no spaces.',
  'Identificador único del trigger. Minúsculas, sin espacios.':
      'Unique identifier of the trigger. Lowercase, no spaces.',
  'Identificador único dentro del .lcp. Minúsculas, sin espacios — no es el nombre visible, eso va en "Nombre".':
      'Unique identifier within the .lcp. Lowercase, no spaces — not the display name, that goes in "Name".',
  'Ignora bonuses': 'Ignores bonuses',
  'Ignora core bonuses de mount': 'Ignores mount core bonuses',
  'Ignora synergies': 'Ignores synergies',
  'Imagen (URL)': 'Image (URL)',
  'Immunity': 'Immunity',
  'Info': 'Info',
  'Instancias': 'Instances',
  'Integrated (IDs)': 'Integrated (IDs)',
  'Integrated (IDs, instalado automáticamente)':
      'Integrated (IDs, automatically installed)',
  'Integrated (IDs, sin validar referencias circulares)':
      'Integrated (IDs, circular references not validated)',
  'Licencia (nombre de display)': 'License (display name)',
  'Licencia (opcional solo en License Collection)':
      'License (optional only in License Collection)',
  'Location': 'Location',
  'Locations (al menos una)': 'Locations (at least one)',
  'Mech': 'Mech',
  'Mechtype': 'Mechtype',
  'Mechtype (al menos uno, solo hint de UI)':
      'Mechtype (at least one, UI hint only)',
  'Mitad de daño con save': 'Half damage on save',
  'Modifica a (ID de otra feature)': 'Modifies (ID of another feature)',
  'Mount': 'Mount',
  'Mounts (al menos uno)': 'Mounts (at least one)',
  'Máximo': 'Maximum',
  'Mínimo': 'Minimum',
  'Mínimo (opcional)': 'Minimum (optional)',
  'Nivel de licencia (0-3)': 'License level (0-3)',
  'No admite mods': 'Does not accept mods',
  'No aparece en filtros de equipo': 'Does not appear in equipment filters',
  'No genera acciones de ataque': 'Does not generate attack actions',
  'Nombre': 'Name',
  'Nombre (activo)': 'Name (active)',
  'Nombre (pasivo)': 'Name (passive)',
  'Nombre corto de esta condición de victoria.':
      'Short name for this victory condition.',
  'Nombre corto del efecto especial que no encaja en las categorías normales de resist/vulnerability/immunity, ej. "Shredded".':
      'Short name of the special effect that doesn\'t fit the normal resist/vulnerability/immunity categories, e.g. "Shredded".',
  'Nombre visible de la licencia (normalmente el del frame).':
      "The license's display name (usually the frame's).",
  'Nota de reglas que el GM tiene que aplicar a mano, porque COMP/CON no la automatiza.':
      "Rules note the GM has to apply manually, since COMP/CON doesn't automate it.",
  'Nº de shards': 'Number of shards',
  'Nº de shards por tier': 'Number of shards per tier',
  'Número': 'Number',
  'Objetivo': 'Objective',
  'Oculta la licencia base': 'Hides the base license',
  'Ocultar acción activa': 'Hide active action',
  'Ocultar en Active Mode': 'Hide in Active Mode',
  'Oculto (uso interno de UI)': 'Hidden (internal UI use)',
  'Opciones de respuesta': 'Answer options',
  'Opción': 'Option',
  'Optional class max': 'Optional class max',
  'Optional class min': 'Optional class min',
  'Optional class min (default 0)': 'Optional class min (default 0)',
  'Optional class per tier': 'Optional class per tier',
  'Optional class per tier (cálculo aditivo, ver vault §15.1)':
      'Optional class per tier (additive calculation, see vault §15.1)',
  'Optional max': 'Optional max',
  'Optional min (default 0)': 'Optional min (default 0)',
  'Optional per tier (cálculo aditivo, ver vault §15.1)':
      'Optional per tier (additive calculation, see vault §15.1)',
  'Origen': 'Origin',
  'Origen (ID de NPC Class/Template)': 'Origin (NPC Class/Template ID)',
  'Overwrite': 'Overwrite',
  'Pilot': 'Pilot',
  'Pilot (default true si el padre es Pilot Equipment)':
      'Pilot (default true if the parent is Pilot Equipment)',
  'Pistas narrativas para los jugadores sobre esta capa.':
      'Narrative hints for players about this layer.',
  'Por tier': 'By tier',
  'Powers': 'Powers',
  'Pregunta': 'Question',
  'Preguntas': 'Questions',
  'Prerequisite': 'Prerequisite',
  'Prerrequisito': 'Prerequisite',
  'Profiles': 'Profiles',
  'Progresión, separada por comas (ej. 1d6, 1d6+1d8, 2d6+1d10)':
      'Progression, comma-separated (e.g. 1d6, 1d6+1d8, 2d6+1d10)',
  'Quita special status': 'Removes special status',
  'Qué dispara esta acción cuando es de tipo Reaction, ej. "Cuando el piloto sea alcanzado por un ataque cuerpo a cuerpo".':
      'What triggers this action when it is of type Reaction, e.g. "When the pilot is hit by a melee attack".',
  'Qué dispara esta reaction, en texto libre.':
      'What triggers this reaction, free text.',
  'Qué hace falta para poder elegir este power, si aplica.':
      'What is needed to be able to choose this power, if applicable.',
  'Qué hay que cumplir para que aplique esta condición.':
      'What must be met for this condition to apply.',
  'Qué pasa en la narrativa si gana el bando enemigo.':
      'What happens narratively if the enemy side wins.',
  'Qué pasa en la narrativa si ganan los jugadores.':
      'What happens narratively if the players win.',
  'Qué pasa si la misión termina sin un ganador claro.':
      'What happens if the mission ends with no clear winner.',
  'Qué tienen que conseguir los jugadores en esta misión.':
      'What the players need to achieve in this mission.',
  'Rango de la licencia del frame que el piloto necesita desbloqueado para poder usar esta arma. 0 = disponible desde el rango base.':
      "The frame license rank the pilot needs unlocked to use this weapon. 0 = available from the base rank.",
  'Rango mínimo': 'Minimum rank',
  'Ranks (3 en la práctica de COMP/CON)': 'Ranks (3 in COMP/CON practice)',
  'Reaction': 'Reaction',
  'Recall': 'Recall',
  'Redeploy': 'Redeploy',
  'Repair cap': 'Repair cap',
  'Replace': 'Replace',
  'Resist': 'Resist',
  'Restringido a (opcional)': 'Restricted to (optional)',
  'Resumen de una línea de la clase.': "One-line summary of the class.",
  'Resumen de una línea del talento, si hace falta.':
      'One-line summary of the talent, if needed.',
  'Resumen de una línea, si hace falta un texto más corto que "Efectos".':
      'One-line summary, if a shorter text than "Effects" is needed.',
  'Resumen general de qué va este sitrep.':
      'General summary of what this sitrep is about.',
  'Rol': 'Role',
  'Rules (admite sintaxis {X/Y/Z} sensible a tier)':
      'Rules (supports tier-sensitive {X/Y/Z} syntax)',
  'SP': 'SP',
  'Save': 'Save',
  'Save (stat)': 'Save (stat)',
  'Save (texto libre)': 'Save (free text)',
  'Save estructurado': 'Structured save',
  'Sensor range': 'Sensor range',
  'Shard count': 'Shard count',
  'Shards': 'Shards',
  'Sin victoria': 'No victory',
  'Skills recomendadas (IDs de skills.json)':
      'Recommended skills (IDs from skills.json)',
  'Skirmish': 'Skirmish',
  'Solo estatus Master': 'Master status only',
  'Solo estatus Veteran': 'Veteran status only',
  'Solo si el tamaño no es un número fijo (ej. "1 por punto de estructura perdido"). Si el tamaño es un número normal, usa el campo "Tamaño" de arriba y deja este vacío.':
      'Only if the size is not a fixed number (e.g. "1 per lost structure point"). If the size is a normal number, use the "Size" field above and leave this empty.',
  'Solo si este frame es una variante visual/de nombre de otro — el id o nombre del frame original.':
      "Only if this frame is a visual/name variant of another — the original frame's id or name.",
  'Solo si este frame es variante de otro — el ID del frame principal de esa licencia.':
      "Only if this frame is a variant of another — the ID of that license's primary frame.",
  'Special equipment (IDs)': 'Special equipment (IDs)',
  'Special equipment (IDs, disponible en el selector)':
      'Special equipment (IDs, available in the selector)',
  'Specialty': 'Specialty',
  'Speed': 'Speed',
  'Stat': 'Stat',
  'Stats': 'Stats',
  'Stress': 'Stress',
  'Structure': 'Structure',
  'Synergies': 'Synergies',
  'Synergies (activo)': 'Synergies (active)',
  'Synergies (siempre activas)': 'Synergies (always active)',
  'System': 'System',
  'Sí/No': 'Yes/No',
  'Tactics (nota para el GM)': 'Tactics (note for the GM)',
  'Tags': 'Tags',
  'Tags añadidos (se quitan si el mod se quita)':
      'Added tags (removed if the mod is removed)',
  'Tamaño': 'Size',
  'Tamaño (entero o 0.5)': 'Size (integer or 0.5)',
  'Tamaño (uno o más valores válidos por tier: 0.5, 1, 2, 3)':
      'Size (one or more valid values per tier: 0.5, 1, 2, 3)',
  'Tamaño especial': 'Special size',
  'Tamaños de arma (vacío = any)': 'Weapon sizes (empty = any)',
  'Tamaños de arma (vacío = todos)': 'Weapon sizes (empty = all)',
  'Tamaños permitidos (vacío = todos)': 'Allowed sizes (empty = all)',
  'Tamaños restringidos': 'Restricted sizes',
  'Tamaños restringidos (DEPRECADO)': 'Restricted sizes (DEPRECATED)',
  'Target': 'Target',
  'Tech': 'Tech',
  'Tech attack': 'Tech attack',
  'Templates cuya aplicación conjunta se prohíbe (IDs)':
      'Templates whose joint application is forbidden (IDs)',
  'Terse (resumen ultra-corto)': 'Terse (ultra-short summary)',
  'Texto': 'Text',
  'Texto corto que sustituye al nombre en la UI de COMP/CON, si hace falta.':
      "Short text that replaces the name in COMP/CON's UI, if needed.",
  'Texto de ambientación más largo, sin efecto mecánico.':
      'Longer flavor text, with no mechanical effect.',
  'Texto de ambientación sobre esta clase de NPC.':
      'Flavor text about this NPC class.',
  'Texto de ambientación sobre este background del piloto.':
      "Flavor text about this pilot's background.",
  'Texto de ambientación sobre este entorno/lugar.':
      'Flavor text about this environment/place.',
  'Texto de ambientación sobre este talento.': 'Flavor text about this talent.',
  'Texto de reglas adicional, solo si este core bonus hace algo especial al instalarse en un mount concreto.':
      'Extra rules text, only if this core bonus does something special when installed on a specific mount.',
  'Texto de reglas de ese efecto especial, si hace falta explicarlo.':
      'Rules text for that special effect, if it needs explaining.',
  'Texto de reglas de esta capa. Si un número cambia según el tier del NPC, escribe "{valor_tier1/valor_tier2/valor_tier3}".':
      'Rules text for this layer. If a number changes based on the NPC\'s tier, write "{tier1_value/tier2_value/tier3_value}".',
  'Texto de reglas de esta munición.': 'Rules text for this ammo.',
  'Texto de reglas de esta reserve.': 'Rules text for this reserve.',
  'Texto de reglas de este deployable.': 'Rules text for this deployable.',
  'Texto de reglas de este power.': 'Rules text for this power.',
  'Texto de reglas de este rank.': 'Rules text for this rank.',
  'Texto de reglas de este trait.': 'Rules text for this trait.',
  'Texto de reglas de la parte activa.': "Rules text for the active half.",
  'Texto de reglas de la parte pasiva, siempre activa.':
      'Rules text for the passive half, always active.',
  'Texto de reglas de la synergy — qué gana el piloto/mech.':
      "Rules text for the synergy — what the pilot/mech gains.",
  'Texto de reglas del arma — lo que hace mecánicamente.':
      'Rules text for the weapon — what it does mechanically.',
  'Texto de reglas del core bonus.': 'Rules text for the core bonus.',
  'Texto de reglas del sistema — lo que hace mecánicamente.':
      "Rules text for the system — what it does mechanically.",
  'Texto de reglas del tag. Si el tag lleva un valor numérico al usarse (ej. "Limited X"), escribe "{VAL}" donde debería ir ese número.':
      'Rules text for the tag. If the tag carries a numeric value when used (e.g. "Limited X"), write "{VAL}" where that number should go.',
  'Texto de reglas libre, para cuando no hace falta la forma estructurada de "Active effect".':
      'Free-text rules, for when the structured "Active effect" form isn\'t needed.',
  'Texto de reglas tal cual aparece en la tarjeta, ej. "On a hit, target must succeed a HULL save or take 5 heat."':
      'Rules text exactly as it appears on the card, e.g. "On a hit, target must succeed a HULL save or take 5 heat."',
  'Texto de reglas y/o sabor de este equipo de piloto.':
      'Rules and/or flavor text for this pilot equipment.',
  'Texto de reglas — lo que hace mecánicamente esta acción.':
      'Rules text — what this action does mechanically.',
  'Texto de reglas — lo que hace mecánicamente esta arma de piloto.':
      'Rules text — what this pilot weapon does mechanically.',
  'Texto de reglas — lo que hace mecánicamente este efecto.':
      'Rules text — what this effect does mechanically.',
  'Texto de reglas — qué le pasa a quien tiene este status/condition.':
      'Rules text — what happens to whoever has this status/condition.',
  'Texto de reglas/sabor de este shard.': 'Rules/flavor text for this shard.',
  'Texto de reglas/sabor de este template.':
      'Rules/flavor text for this template.',
  'Texto de sabor sobre el fabricante — quién es, qué hace.':
      'Flavor text about the manufacturer — who they are, what they do.',
  'Texto de sabor/ambientación del core system.':
      "Flavor text for the core system.",
  'Texto de sabor/ambientación del frame.': 'Flavor text for the frame.',
  'Texto de sabor/ambientación, sin efecto mecánico.':
      'Flavor text, with no mechanical effect.',
  'Texto libre combinando tamaño y tipo, tal como se muestra en la tarjeta del NPC, ej. "Heavy Cannon".':
      'Free text combining size and type, as shown on the NPC card, e.g. "Heavy Cannon".',
  'Tier (si se omite, usa el del layer)': 'Tier (if omitted, uses the layer\'s)',
  'Tier 1': 'Tier 1',
  'Tier 2': 'Tier 2',
  'Tier 3': 'Tier 3',
  'Tipo': 'Type',
  'Tipo (Drone | Mine | Deployable | personalizado)':
      'Type (Drone | Mine | Deployable | custom)',
  'Tipo (default: System)': 'Type (default: System)',
  'Tipo (solo agrupa en pestañas de UI)': 'Type (UI tabbing only)',
  'Tipo de alcance': 'Range type',
  'Tipo de arma': 'Weapon type',
  'Tipo de arma ("{Size} {Type}", ej. "Superheavy Rifle")':
      'Weapon type ("{Size} {Type}", e.g. "Superheavy Rifle")',
  'Tipo de ataque': 'Attack type',
  'Tipo de daño': 'Damage type',
  'Tipo de feature': 'Feature type',
  'Tipo de gear': 'Gear type',
  'Tipo de mount seguido de dos puntos y el número máximo de mounts de ese tipo, ej. "main:3" o "flex:1".':
      'Mount type followed by a colon and the maximum number of mounts of that type, e.g. "main:3" or "flex:1".',
  'Tipos': 'Types',
  'Tipos de alcance (vacío = todos)': 'Range types (empty = all)',
  'Tipos de arma (vacío = any)': 'Weapon types (empty = any)',
  'Tipos de arma (vacío = todos)': 'Weapon types (empty = all)',
  'Tipos de daño (vacío = todos)': 'Damage types (empty = all)',
  'Tipos de sistema (vacío = todos)': 'System types (empty = all)',
  'Tipos permitidos (vacío = todos)': 'Allowed types (empty = all)',
  'Tipos restringidos': 'Restricted types',
  'Tipos restringidos (DEPRECADO)': 'Restricted types (DEPRECATED)',
  'Trait': 'Trait',
  'Traits': 'Traits',
  'Trigger': 'Trigger',
  'Trigger (si es Reaction)': 'Trigger (if it is a Reaction)',
  'Título': 'Title',
  'URL a la imagen/banner del frame. Opcional.':
      "URL to the frame's image/banner. Optional.",
  'URL a una imagen de icono, solo si no hay SVG. Opcional.':
      'URL to an icon image, only if there is no SVG. Optional.',
  'Un ideal mayor de este bond, en pocas palabras.':
      "A major ideal of this bond, in a few words.",
  'Un ideal menor de este bond, en pocas palabras.':
      "A minor ideal of this bond, in a few words.",
  'Un valor de dados por cada rango del bonus, separados por comas — el primero para el rango 1, el segundo para el rango 2, etc.':
      "One dice value per bonus rank, comma-separated — the first for rank 1, the second for rank 2, etc.",
  'Una de las preguntas de trasfondo asociadas a este bond.':
      'One of the background questions associated with this bond.',
  'Una frase corta característica del fabricante, entre comillas.':
      "A short characteristic phrase from the manufacturer, in quotes.",
  'Una posible respuesta a la pregunta de arriba.':
      'A possible answer to the question above.',
  'Valor': 'Value',
  'Valor (número o dados)': 'Value (number or dice)',
  'Valor (sin confirmar, ver vault MdD §4)':
      'Value (unconfirmed, see vault MdD §4)',
  'Valor conocido': 'Known value',
  'Valor por defecto': 'Default value',
  'Variant (id o nombre del frame del que es variante)':
      'Variant (id or name of the frame it is a variant of)',
  'Varios': 'Multiple',
  'Victoria de los PCs': 'PC victory',
  'Victoria enemiga': 'Enemy victory',
  'Vulnerability': 'Vulnerability',
  'Weapon': 'Weapon',
  'ej. 10, 1d6': 'e.g. 10, 1d6',
  'ej. 1d6': 'e.g. 1d6',
  'ej. 2d6, 10, 1d6+{grit}': 'e.g. 2d6, 10, 1d6+{grit}',
  'ej. 5': 'e.g. 5',
  'ej. round_start_1, next_turn_start_self':
      'e.g. round_start_1, next_turn_start_self',
  'mount_type:max_mounts (ej. main:3)': 'mount_type:max_mounts (e.g. main:3)',
  'next_turn_start_self, next_turn_end_self, next_turn_start_target, next_turn_end_target, round_start_N, round_end_N':
      'next_turn_start_self, next_turn_end_self, next_turn_start_target, next_turn_end_target, round_start_N, round_end_N',
  'rest, weapon, system, deployable, drone, move, boost, structure, armor, hp, overshield, stress, heat, repair, core_power, overcharge, hull, agility, systems, engineering, pilot_weapon, cascade, o action_<id>':
      'rest, weapon, system, deployable, drone, move, boost, structure, armor, hp, overshield, stress, heat, repair, core_power, overcharge, hull, agility, systems, engineering, pilot_weapon, cascade, or action_<id>',
  'Único': 'Single',
  'Único (los 3 tiers)': 'Single (all 3 tiers)',

  // Argumentos posicionales de funciones que reciben `label` como
  // parámetro (ej. `textOrActiveEffectField(key, label)`,
  // `tierValueField(key, label)`) — no capturados por la extracción
  // automática de `label: '...'` porque en el sitio de llamada no usan
  // esa forma, y el helper las reasigna a `label: label` (una variable,
  // no un literal). Añadidas a mano tras verificar visualmente que el
  // formulario de arma no traducía "Al atacar"/"Al acertar"/etc.
  'Al atacar': 'On attack',
  'Al acertar': 'On hit',
  'Al crítico': 'On crit',
  'Al fallar': 'On miss',
  'Nº de ataques': 'Number of attacks',
  'Evade': 'Evade',
  'Hull': 'Hull',
  'Activations': 'Activations',
  'Agility': 'Agility',
  'Engineering': 'Engineering',
  'Systems': 'Systems',
  'Sensor': 'Sensor',
  'Grapple': 'Grapple',

  // `TextFieldSpec.referenceLabel` — texto corto para el botón "Crear X"
  // (ver `generic_form_view.dart`), key distinta de `label`/`helpText`
  // por eso tampoco capturada por la extracción automática.
  'fabricante': 'manufacturer',
  'frame': 'frame',

  // Cadenas compuestas por interpolación dentro de `textOrActiveEffectField`
  // (`'$label (texto)'`/`'$label (active effect)'`) y `tierValueField`
  // (`'$label por tier'`) — el resultado final es un literal, pero la
  // extracción automática lo descartó por contener `$label` sin resolver.
  'Efecto (texto)': 'Effect (text)',
  'Efecto (active effect)': 'Effect (active effect)',
  'Al atacar (texto)': 'On attack (text)',
  'Al atacar (active effect)': 'On attack (active effect)',
  'Al acertar (texto)': 'On hit (text)',
  'Al acertar (active effect)': 'On hit (active effect)',
  'Al crítico (texto)': 'On crit (text)',
  'Al crítico (active effect)': 'On crit (active effect)',
  'Al fallar (texto)': 'On miss (text)',
  'Al fallar (active effect)': 'On miss (active effect)',
  'Accuracy por tier': 'Accuracy by tier',
  'Activations por tier': 'Activations by tier',
  'Agility por tier': 'Agility by tier',
  'Armor por tier': 'Armor by tier',
  'Attack bonus por tier': 'Attack bonus by tier',
  'Nº de ataques por tier': 'Number of attacks by tier',
  'E-Defense por tier': 'E-Defense by tier',
  'Engineering por tier': 'Engineering by tier',
  'Evade por tier': 'Evade by tier',
  'Heat cap por tier': 'Heat cap by tier',
  'HP por tier': 'HP by tier',
  'Hull por tier': 'Hull by tier',
  'Save por tier': 'Save by tier',
  'Sensor por tier': 'Sensor by tier',
  'Speed por tier': 'Speed by tier',
  'Systems por tier': 'Systems by tier',

  // Títulos de EntityCrearConfig (menú Crear).
  'Crear arma': 'Create weapon',
  'Crear fabricante': 'Create manufacturer',
  'Crear tag': 'Create tag',
  'Crear skill (trigger)': 'Create skill (trigger)',
  'Crear status/condition': 'Create status/condition',
  'Crear sitrep': 'Create sitrep',
  'Crear entorno': 'Create environment',
  'Crear background': 'Create background',
  'Crear bond': 'Create bond',
  'Crear reserve': 'Create reserve',
  'Crear core bonus': 'Create core bonus',
  'Crear talent': 'Create talent',
  'Crear mech system': 'Create mech system',
  'Crear weapon mod': 'Create weapon mod',
  'Crear pilot gear': 'Create pilot gear',
  'Crear frame': 'Create frame',
  'Crear NPC feature': 'Create NPC feature',
  'Crear NPC class': 'Create NPC class',
  'Crear NPC template': 'Create NPC template',
  'Crear eidolon layer': 'Create eidolon layer',
};

/// Traduce [text] a inglés si [locale] es `en` y existe una entrada en el
/// diccionario; si no hay traducción, devuelve el español sin más (nunca
/// deja un campo en blanco).
String translateFieldText(String text, Locale locale) {
  if (locale.languageCode != 'en') return text;
  return esToEnFieldText[text] ?? text;
}
