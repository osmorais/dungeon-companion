
INSERT INTO Attribute_Type (name, full_name, description) VALUES 
('FOR', 'Força', NULL),
('DES', 'Destreza', NULL),
('CON', 'Constituição', NULL),
('INT', 'Inteligência', NULL),
('SAB', 'Sabedoria', NULL),
('CAR', 'Carisma', NULL);

---

INSERT INTO Skill (name, id_attribute, description) VALUES
('Atletismo', 1, NULL),
('Acrobacia', 2, NULL),
('Furtividade', 2, NULL),
('Prestidigitação', 2, NULL),
('Arcanismo', 4, NULL),
('História', 4, NULL),
('Investigação', 4, NULL),
('Natureza', 4, NULL),
('Religião', 4, NULL),
('Adestrar Animais', 5, NULL),
('Intuição', 5, NULL),
('Medicina', 5, NULL),
('Percepção', 5, NULL),
('Sobrevivência', 5, NULL),
('Atuação', 6, NULL),
('Enganação', 6, NULL),
('Intimidação', 6, NULL),
('Persuasão', 6, NULL);

---

INSERT INTO Alignment (id_alignment, name, description) VALUES
('Leal e Bom (LB)', 'Criaturas em que se pode confiar para fazer o que é correto conforme esperado pela sociedade.'),
('Neutro e Bom (NB)', 'Fazem o melhor que podem para ajudar os outros de acordo com suas necessidades.'),
('Caótico e Bom (CB)', 'Agem de acordo com sua própria consciência, ignorando expectativas alheias.'),
('Leal e Neutro (LN)', 'Seguem leis, tradições ou códigos pessoais de forma consistente.'),
('Neutro (N)', 'Evitam tomar partido moral, agindo conforme a situação parece exigir.'),
('Caótico e Neutro (CN)', 'Seguem seus próprios caprichos, priorizando liberdade pessoal acima de tudo.'),
('Leal e Mau (LM)', 'Buscam seus objetivos de forma metódica dentro de leis ou tradições.'),
('Neutro e Mau (NM)', 'Fazem o que desejam sem compaixão ou remorso.'),
('Caótico e Mau (CM)', 'Agem com violência arbitrária movidos por ganância, ódio ou sede de sangue.');

---
INSERT INTO Armour (name, armour_class_base, is_sum_dexterity, armour_type, max_dexterity_bonus, is_stealth_disadvantage, weight, price_value) VALUES 
-- Armaduras Leves
('Acolchoada', 11, TRUE, 'Armadura Leve', NULL, TRUE, 4.0, 5.0),
('Couro', 11, TRUE, 'Armadura Leve', NULL, FALSE, 5.0, 10.0),
('Couro Batido', 12, TRUE, 'Armadura Leve', NULL, FALSE, 6.5, 45.0),

-- Armaduras Médias
('Gibão de Peles', 12, TRUE, 'Armadura Média', 2, FALSE, 6.0, 10.0),
('Camisão de Malha', 13, TRUE, 'Armadura Média', 2, FALSE, 10.0, 50.0),
('Brunea', 14, TRUE, 'Armadura Média', 2, TRUE, 22.5, 50.0),
('Peitoral', 14, TRUE, 'Armadura Média', 2, FALSE, 10.0, 400.0),
('Meia-Armadura', 15, TRUE, 'Armadura Média', 2, TRUE, 20.0, 750.0),

-- Armaduras Pesadas
('Cota de anéis', 14, FALSE, 'Armadura Pesada', NULL, TRUE, 20.0, 30.0),
('Cota de malha', 16, FALSE, 'Armadura Pesada', NULL, TRUE, 27.5, 75.0),
('Cota de talas', 17, FALSE, 'Armadura Pesada', NULL, TRUE, 30.0, 200.0),
('Placas', 18, FALSE, 'Armadura Pesada', NULL, TRUE, 32.5, 1500.0),

-- Escudo
('Escudo', 2, FALSE, 'Escudo', NULL, FALSE, 3.0, 10.0);

---

INSERT INTO Background (id_background, name, starting_gold_po, languages_number) VALUES
(1, 'Acólito', 15, 2),
(2, 'Artesão de Guilda', 15, 1),
(3, 'Artista', 15, 0),
(4, 'Charlatão', 15, 0),
(5, 'Criminoso', 15, 0),
(6, 'Eremita', 5, 1),
(7, 'Forasteiro', 10, 1),
(8, 'Herói do Povo', 10, 0),
(9, 'Marinheiro', 10, 0),
(10, 'Nobre', 25, 1),
(11, 'Órfão', 10, 0),
(12, 'Sábio', 10, 2),
(13, 'Soldado', 10, 0);

-- Ajustar a sequência do SERIAL após o insert manual
SELECT setval(pg_get_serial_sequence('Background', 'id_background'), (SELECT MAX(id_background) FROM Background));

---

