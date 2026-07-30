/// Tag-instance field bundle and assembler (domain section 6).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';
import 'field_help_texts.dart';

// --- Sección 6: ITagInstance ---

/// Campos de un tag de item (`ITagInstance`): el id del catálogo y, para los
/// tags que llevan un número (Thrown 5, Reliable 2, Limited 3, Blast 1…), su
/// valor — sustituye el token `{VAL}` del catálogo (ver [tagIdHelpText]). El
/// `.lcp` real guarda ese número como tal (`{"id":"tg_reliable","val":2}`),
/// por eso `val` es un campo numérico y no de texto. Compartido por todas las
/// entidades con `tags` (arma, sistema, mod, pilot gear...), en vez de repetir
/// el esquema en cada una.
const tagItemFields = [
  TextFieldSpec(
    key: 'id',
    label: 'ID del tag',
    required: true,
    helpText: tagIdHelpText,
  ),
  NumberFieldSpec(
    key: 'val',
    label: 'Valor (solo si el tag lo lleva, p. ej. Thrown 5)',
    allowDecimal: false,
  ),
];

ITagInstance tagFromItem(Map<String, dynamic> item) => ITagInstance(
  // Se recorta: el id es una referencia de coincidencia EXACTA al catálogo de
  // Lancer; un espacio sobrante (fácil al copiar/teclear, p. ej. `"tg_thrown "`)
  // hace que COMP/CON no reconozca el tag y no lo pinte, sin ningún error
  // visible. Recortar aquí lo evita de raíz.
  id: (item['id'] as String).trim(),
  // `Object?` en el dominio (string|number); en la práctica los tags con
  // valor del Core son numéricos, y el campo es un NumberFieldSpec.
  val: (item['val'] as num?)?.toInt(),
);
