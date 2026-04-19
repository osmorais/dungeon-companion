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

