/// Help texts and Core reference catalogs (manufacturers, tags) shared by
/// the field builders.
library;

/// Referencia de fabricantes/tags del Core de Lancer, para el `helpText`
/// de cualquier campo que referencie su `id` (`bonusCatalogField`'s
/// `source`, el `id` de un tag dentro de una lista...) — verificado
/// contra `lib/manufacturers.json`/`lib/tags.json` en
/// `massif-press/lancer-data` (el mismo repo fuente que el resto del
/// modelo de dominio), no inventado ni copiado de la Wiki. Constante
/// única reutilizada en los ~13 sitios que antes repetían el mismo
/// `helpText` sin esta lista (ver "Principios y decisiones clave").
const String _coreManufacturersList =
    'Fabricantes del Core de Lancer (id → nombre):\n'
    '• GMS → General Massive Systems\n'
    '• IPS-N → IPS-Northstar\n'
    '• SSC → Smith-Shimano Corpro\n'
    '• HORUS → Horus\n'
    '• HA → Harrison Armory';

const String manufacturerIdHelpText =
    'El ID del fabricante (Manufacturer), no su nombre visible.\n\n'
    '$_coreManufacturersList\n\n'
    'Si el fabricante todavía no existe (por ejemplo, es uno propio de tu '
    'homebrew), usa el botón de crear fabricante desde el menú/formulario.';

const String _coreTagsList =
    'Tags del Core de Lancer (id → nombre; {VAL} es un valor numérico '
    'que se rellena aparte):\n'
    '• tg_accurate → Accurate {VAL}\n'
    '• tg_ai → AI\n'
    '• tg_ap → Armor-Piercing (AP)\n'
    '• tg_arcing → Arcing\n'
    '• tg_archaic → Archaic\n'
    '• tg_blast → Blast {VAL}\n'
    '• tg_burn → Burn {VAL}\n'
    '• tg_burst → Burst {VAL}\n'
    '• tg_cone → Cone {VAL}\n'
    '• tg_danger_zone → Danger Zone\n'
    '• tg_deployable → Deployable\n'
    '• tg_drone → Drone\n'
    '• tg_exotic → Exotic Gear\n'
    '• tg_free_action → Free Action\n'
    '• tg_full_action → Full Action\n'
    '• tg_full_tech → Full Tech\n'
    '• tg_gear → Gear\n'
    '• tg_grenade → Grenade\n'
    '• tg_heat_self → Heat {VAL} (Self)\n'
    '• tg_heat_target → Heat {VAL} (Target)\n'
    '• tg_inaccurate → Inaccurate {VAL}\n'
    '• tg_indestructible → Indestructible\n'
    '• tg_invade → Invade\n'
    '• tg_invisible → Invisible\n'
    '• tg_invulnerable → Invulnerable\n'
    '• tg_irreducible → Irreducible\n'
    '• tg_knockback → Knockback {VAL}\n'
    '• tg_limited → Limited {VAL}\n'
    '• tg_line → Line {VAL}\n'
    '• tg_loading → Loading\n'
    '• tg_loading_after → Loading (Multiple Uses)\n'
    '• tg_mine → Mine\n'
    '• tg_mod → Mod\n'
    '• tg_modded → Modded\n'
    '• tg_no_cascade → Prevent Cascade\n'
    '• tg_npc_reaction → NPC Reaction\n'
    '• tg_npc_system → NPC System\n'
    '• tg_npc_tech → NPC Tech Action\n'
    '• tg_npc_trait → NPC Trait\n'
    '• tg_npc_weapon → NPC Weapon\n'
    '• tg_ordnance → Ordnance\n'
    '• tg_overkill → Overkill {VAL}\n'
    '• tg_overshield → Overshield\n'
    '• tg_personal_armor → Personal Armor\n'
    '• tg_pilot_weapon → Pilot Weapon\n'
    '• tg_protocol → Protocol\n'
    '• tg_quick_action → Quick Action\n'
    '• tg_quick_tech → Quick Tech\n'
    '• tg_range → Range ({VAL})\n'
    '• tg_reaction → Reaction\n'
    '• tg_recharge → Recharge {VAL}+\n'
    '• tg_reliable → Reliable {VAL}\n'
    '• tg_resistall → Resistance (All)\n'
    '• tg_resistance → Resistance\n'
    '• tg_round → {VAL}/Round\n'
    '• tg_seeking → Seeking\n'
    '• tg_set_damage_type → Set Damage Type\n'
    '• tg_set_damage_value → Set Damage Value\n'
    '• tg_set_max_uses → Set Max Uses\n'
    '• tg_shield → Shield\n'
    '• tg_sidearm → Sidearm\n'
    '• tg_smart → Smart\n'
    '• tg_threat → Threat {VAL}\n'
    '• tg_thrown → Thrown {VAL}\n'
    '• tg_turn → {VAL}/Turn\n'
    '• tg_unique → Unique\n'
    '• tg_unlimited → Unlimited';

const String tagIdHelpText =
    'El ID del tag (Tag), no su nombre visible.\n\n'
    '$_coreTagsList\n\n'
    'Si el tag todavía no existe (por ejemplo, es uno propio de tu '
    'homebrew), usa el botón de crear tag desde el menú.';
