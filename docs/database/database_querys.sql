-- ====================================================================================
-- QUERY: Buscar todos os dados de um personagem pelo ID
-- ====================================================================================

SELECT
  c.id_character,
  c.name,
  c.player_name,
  c.level,
  c.xp_points,
  c.proficiency_bonus,
  c.initiative_value,
  c.armour_class,
  c.current_hit_points,
  c.max_hit_points,
  c.hit_dice,
  c.passive_perception,
  c.inspiration,
  c.total_po,
  c.weight,
  c.height,
  c.others_characteristics,

  -- Lookup tables
  r.name                AS race_name,
  cl.name               AS class_name,
  ar.name               AS armour_name,
  al.name               AS alignment_name,

  -- Background (1:1 via character_background)
  b.id_background,
  b.name                AS background_name,
  b.starting_gold_po    AS background_starting_gold,
  cb.full_history,

  -- Attributes (1:N → aggregated)
  JSON_AGG(
    DISTINCT JSONB_BUILD_OBJECT(
      'id_attribute',    at.id_attribute,
      'name',            at.name,
      'full_name',       at.full_name,
      'bonus_value',     ca.bonus_value,
      'modifier_value',  ca.modifier_value
    )
  ) FILTER (WHERE at.id_attribute IS NOT NULL) AS attributes,

  -- Skills (1:N → aggregated)
  JSON_AGG(
    DISTINCT JSONB_BUILD_OBJECT(
      'id_skill',          s.id_skill,
      'name',              s.name,
      'is_trained',        csk.is_trained,
      'trained_value',     csk.trained_value,
      'level_value',       csk.level_value,
      'total_skill_value', csk.total_skill_value
    )
  ) FILTER (WHERE s.id_skill IS NOT NULL) AS skills,

  -- Spells (1:N → aggregated)
  JSON_AGG(
    DISTINCT JSONB_BUILD_OBJECT(
      'id_spell',       sp.id_spell,
      'name',           sp.name,
      'spelllevel',     sp.spelllevel,
      'school',         sp.school,
      'casting_time',   sp.casting_time,
      'duration',       sp.duration,
      'range_distance', sp.range_distance,
      'is_verbal',      sp.is_verbal,
      'is_somatic',     sp.is_somatic,
      'is_material',    sp.is_material,
      'description',    sp.description
    )
  ) FILTER (WHERE sp.id_spell IS NOT NULL) AS spells,

  -- Weapons (1:N → aggregated)
  JSON_AGG(
    DISTINCT JSONB_BUILD_OBJECT(
      'id_weapon',       w.id_weapon,
      'name',            w.name,
      'damage_die',      w.damage_die,
      'damage_type',     w.damage_type,
      'properties',      w.properties,
      'has_proficiency', cw.has_proficiency
    )
  ) FILTER (WHERE w.id_weapon IS NOT NULL) AS weapons,

  -- Items (1:N → aggregated)
  JSON_AGG(
    DISTINCT JSONB_BUILD_OBJECT(
      'id_item',     i.id_item,
      'name',        i.name,
      'description', i.description,
      'weight',      i.weight,
      'price_value', i.price_value
    )
  ) FILTER (WHERE i.id_item IS NOT NULL) AS items

FROM character c
LEFT JOIN race                r   ON r.id_race          = c.id_race
LEFT JOIN class               cl  ON cl.id_class         = c.id_class
LEFT JOIN armour              ar  ON ar.id_armour         = c.id_armour
LEFT JOIN alignment           al  ON al.id_alignment      = c.id_alignment
LEFT JOIN character_background cb ON cb.id_character      = c.id_character
LEFT JOIN background          b   ON b.id_background      = cb.id_background
LEFT JOIN character_attribute ca  ON ca.id_character      = c.id_character
LEFT JOIN attribute_type      at  ON at.id_attribute      = ca.id_attribute
LEFT JOIN character_skill     csk ON csk.id_character     = c.id_character
LEFT JOIN skill               s   ON s.id_skill           = csk.id_skill
LEFT JOIN character_spell     csp ON csp.id_character     = c.id_character
LEFT JOIN spell               sp  ON sp.id_spell          = csp.id_spell
LEFT JOIN character_weapon    cw  ON cw.id_character      = c.id_character
LEFT JOIN weapon              w   ON w.id_weapon          = cw.id_weapon
LEFT JOIN character_items     ci  ON ci.id_character      = c.id_character
LEFT JOIN item                i   ON i.id_item            = ci.id_item

WHERE c.id_character = :id   -- substituir pelo ID desejado

GROUP BY
  c.id_character,
  r.name, cl.name, ar.name, al.name,
  b.id_background, b.name, b.starting_gold_po,
  cb.full_history;


-- ====================================================================================
-- QUERIES: Buscar todos os dados de um personagem pelo ID (selects separados)
-- ====================================================================================


-- 1. Dados principais do personagem
SELECT
  c.id_character,
  c.name,
  c.player_name,
  c.level,
  c.xp_points,
  c.proficiency_bonus,
  c.initiative_value,
  c.armour_class,
  c.current_hit_points,
  c.max_hit_points,
  c.hit_dice,
  c.passive_perception,
  c.inspiration,
  c.total_po,
  c.weight,
  c.height,
  c.others_characteristics,
  r.name   AS race_name,
  cl.name  AS class_name,
  ar.name  AS armour_name,
  al.name  AS alignment_name
FROM character c
LEFT JOIN race      r  ON r.id_race       = c.id_race
LEFT JOIN class     cl ON cl.id_class      = c.id_class
LEFT JOIN armour    ar ON ar.id_armour      = c.id_armour
LEFT JOIN alignment al ON al.id_alignment   = c.id_alignment
WHERE c.id_character = :id;


-- 2. Background do personagem
SELECT
  b.id_background,
  b.name              AS background_name,
  b.starting_gold_po,
  b.languages_number,
  cb.full_history
FROM character_background cb
JOIN background b ON b.id_background = cb.id_background
WHERE cb.id_character = :id;


-- 3. Atributos do personagem
SELECT
  at.id_attribute,
  at.name       AS attribute_name,
  at.full_name  AS attribute_full_name,
  ca.bonus_value,
  ca.modifier_value
FROM character_attribute ca
JOIN attribute_type at ON at.id_attribute = ca.id_attribute
WHERE ca.id_character = :id;


-- 4. Perícias do personagem
SELECT
  s.id_skill,
  s.name             AS skill_name,
  csk.is_trained,
  csk.trained_value,
  csk.level_value,
  csk.total_skill_value
FROM character_skill csk
JOIN skill s ON s.id_skill = csk.id_skill
WHERE csk.id_character = :id;


-- 5. Magias do personagem
SELECT
  sp.id_spell,
  sp.name,
  sp.spelllevel     AS spell_level,
  sp.school,
  sp.casting_time,
  sp.duration,
  sp.range_distance,
  sp.is_verbal,
  sp.is_somatic,
  sp.is_material,
  sp.description
FROM character_spell csp
JOIN spell sp ON sp.id_spell = csp.id_spell
WHERE csp.id_character = :id;


-- 6. Armas do personagem
SELECT
  w.id_weapon,
  w.name,
  w.damage_die,
  w.damage_type,
  w.properties,
  w.weight,
  w.price_value,
  cw.has_proficiency
FROM character_weapon cw
JOIN weapon w ON w.id_weapon = cw.id_weapon
WHERE cw.id_character = :id;


-- 7. Itens do personagem
SELECT
  i.id_item,
  i.name,
  i.description,
  i.weight,
  i.price_value
FROM character_items ci
JOIN item i ON i.id_item = ci.id_item
WHERE ci.id_character = :id;
