-- Criar tabela de Atributos
CREATE TABLE Attribute_Type (
    id_attribute INT PRIMARY KEY,
    name VARCHAR(3) NOT NULL,
    full_name VARCHAR(20) NOT NULL
);

-- Criar tabela de Perícias (Skills)
CREATE TABLE Skill (
    id_skill SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    id_attribute INT,
    CONSTRAINT fk_attribute FOREIGN KEY (id_attribute) REFERENCES Attribute_Type(id_attribute)
);

--- SCRIPTS ABAIXO AINDA NÃO EXECUTADOS:
-- ====================================================================================
-- SCRIPT DE CRIAÇÃO DO BANCO DE DADOS D&D 5E - POSTGRESQL
-- ====================================================================================

--ADICIONAR O CAMPO DESCRIPTION NO ATTRIBUTE_TYPE
-- Ajustar relacionamento character_skill
-- adicionar campo description na tabela skill

-- Limpeza prévia (Opcional - Remove as tabelas se elas já existirem)
DROP TABLE IF EXISTS Character_Items CASCADE;
DROP TABLE IF EXISTS Character_Weapon CASCADE;
DROP TABLE IF EXISTS Character_Spell CASCADE;
DROP TABLE IF EXISTS Character_Attribute CASCADE;
DROP TABLE IF EXISTS Character_Skill CASCADE;
DROP TABLE IF EXISTS Character_Background CASCADE;
DROP TABLE IF EXISTS Character CASCADE;
DROP TABLE IF EXISTS Item CASCADE;
DROP TABLE IF EXISTS Weapon CASCADE;
DROP TABLE IF EXISTS Spell CASCADE;
DROP TABLE IF EXISTS Attribute_Type CASCADE;
DROP TABLE IF EXISTS Skill CASCADE;
DROP TABLE IF EXISTS Armour CASCADE;
DROP TABLE IF EXISTS Background CASCADE;
DROP TABLE IF EXISTS Class CASCADE;
DROP TABLE IF EXISTS Race CASCADE;
DROP TABLE IF EXISTS Alignment CASCADE;

-- ====================================================================================
-- 1. TABELAS INDEPENDENTES (DOMÍNIOS / LOOKUPS)
-- ====================================================================================

CREATE TABLE Alignment (
    id_alignment SERIAL PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);

CREATE TABLE Race (
    id_race SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    movement VARCHAR(50)
);

CREATE TABLE Class (
    id_class SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    starting_gold_po INT
);

CREATE TABLE Background (
    id_background SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    starting_gold_po INT,
    languages_number INT
);

CREATE TABLE Armour (
    id_armour SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    armour_class_base INT,
    is_sum_dexterity BOOLEAN,
    armour_type VARCHAR(50),
    max_dexterity_bonus INT,
    is_stealth_disadvantage BOOLEAN,
    weight FLOAT,
    price_value FLOAT
);

CREATE TABLE Skill (
    id_skill SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE Attribute_Type (
    id_attribute_type SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE Spell (
    id_spell SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    casting_time VARCHAR(255),
    range_distance INT,
    duration VARCHAR(255),
    damage INT,
    is_verbal BOOLEAN,
    is_somatic BOOLEAN,
    is_material BOOLEAN,
    spellLevel INT,
    school VARCHAR(255)
);

CREATE TABLE Weapon (
    id_weapon SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    damage_die VARCHAR(50),
    damage_type VARCHAR(50),
    properties TEXT,
    weight FLOAT,
    price_value FLOAT
);

CREATE TABLE Item (
    id_item SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_value FLOAT,
    weight FLOAT
);


-- ====================================================================================
-- 2. TABELA PRINCIPAL (ENTIDADE CENTRAL)
-- ====================================================================================

CREATE TABLE Character (
    id_character SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    player_name VARCHAR(255),
    xp_points INT DEFAULT 0,
    proficiency_bonus INT DEFAULT 2,
    level INT DEFAULT 1,
    initiative_value INT,
    armour_class INT,
    current_hit_points INT,
    max_hit_points INT,
    hit_dice VARCHAR(50),
    passive_perception VARCHAR(50),
    inspiration INT DEFAULT 0,
    total_po INT DEFAULT 0,
    weight FLOAT,
    height FLOAT,
    others_characteristics TEXT,
    
    -- Chaves Estrangeiras indicadas nos quadros azuis
    id_race INT REFERENCES Race(id_race),
    id_class INT REFERENCES Class(id_class),
    id_armour INT REFERENCES Armour(id_armour),
    id_alignment INT REFERENCES Alignment(id_alignment)
);


-- ====================================================================================
-- 3. TABELAS ASSOCIATIVAS (RELACIONAMENTOS N:M COM O PERSONAGEM)
-- ====================================================================================

CREATE TABLE Character_Background (
    id_character_background SERIAL PRIMARY KEY,
    full_history TEXT,
    
    -- Chaves Estrangeiras
    id_character INT REFERENCES Character(id_character) ON DELETE CASCADE,
    id_background INT REFERENCES Background(id_background)
);

CREATE TABLE Character_Skill (
    id_character_skill SERIAL PRIMARY KEY,
    is_trained BOOLEAN DEFAULT FALSE,
    trained_value INT DEFAULT 0,
    level_value INT DEFAULT 0,
    total_skill_value INT DEFAULT 0,
    
    -- Chaves Estrangeiras
    id_character INT REFERENCES Character(id_character) ON DELETE CASCADE,
    id_skill INT REFERENCES Skill(id_skill),
    id_attribute_type INT REFERENCES Attribute_Type(id_attribute_type)
);

CREATE TABLE Character_Attribute (
    id_character_attribute SERIAL PRIMARY KEY,
    bonus_value INT DEFAULT 0,
    modifier_value INT DEFAULT 0,
    
    -- Chaves Estrangeiras
    id_character INT REFERENCES Character(id_character) ON DELETE CASCADE,
    id_attribute_type INT REFERENCES Attribute_Type(id_attribute_type)
);

CREATE TABLE Character_Spell (
    id_character_spell SERIAL PRIMARY KEY,
    
    -- Chaves Estrangeiras
    id_character INT REFERENCES Character(id_character) ON DELETE CASCADE,
    id_attribute_type INT REFERENCES Attribute_Type(id_attribute_type),
    id_spell INT REFERENCES Spell(id_spell)
);

CREATE TABLE Character_Weapon (
    id_character_weapon SERIAL PRIMARY KEY,
    has_proficiency BOOLEAN DEFAULT FALSE,
    
    -- Chaves Estrangeiras
    id_character INT REFERENCES Character(id_character) ON DELETE CASCADE,
    id_weapon INT REFERENCES Weapon(id_weapon)
);

CREATE TABLE Character_Items (
    id_character_item SERIAL PRIMARY KEY,
    
    -- Chaves Estrangeiras
    id_character INT REFERENCES Character(id_character) ON DELETE CASCADE,
    id_item INT REFERENCES Item(id_item)
);

-- ====================================================================================
-- FIM DO SCRIPT
-- ====================================================================================