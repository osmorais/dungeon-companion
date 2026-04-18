# Guia Estruturado: Resposta da API (Output de Ficha D&D 5e)
**Objetivo:** Definir o padrão de resposta (JSON) que a API / Claude Code deve retornar após processar as regras matemáticas e o input do usuário. O retorno deve conter a ficha completa e calculada.

---

## Estrutura do JSON de Retorno

O retorno deve ser um objeto JSON dividido nas seguintes chaves principais:
1. `header`: Informações de identidade.
2. `combat_stats`: HP, CA, Iniciativa, Deslocamento e Proficiência.
3. `attributes_and_saves`: Valores, modificadores e testes de resistência já calculados.
4. `skills`: Lista completa de perícias com os bônus finais.
5. `combat_actions`: Armas e ataques calculados (Bônus de acerto e dano).
6. `features_and_traits`: Habilidades de raça, classe e antecedente.
7. `proficiencies_and_languages`: Idiomas e proficiências gerais.
8. `equipment`: Inventário.
9. `spellcasting`: Magias e cálculos mágicos (se aplicável).

---

## Exemplo de Retorno (JSON Payload)

Baseado no input do nível 1 (Mago, Alto Elfo, Sábio), a API deve realizar as somas matemáticas e retornar este payload exato:

```json
{
  "character_sheet": {
    "header": {
      "name": "Eldrin",
      "class_and_level": "Mago 1",
      "race": "Alto Elfo",
      "background": "Sábio",
      "alignment": "Caótico e Bom",
      "experience_points": 0
    },
    
    "combat_stats": {
      "proficiency_bonus": 2,
      "armor_class": 13, 
      "initiative": 3,
      "speed": "9m (30 pés)",
      "hit_points": {
        "max": 7,
        "current": 7,
        "temporary": 0
      },
      "hit_dice": "1d6",
      "passive_perception": 13
    },

    "attributes_and_saves": {
      "STR": { "score": 8, "modifier": -1, "save": -1, "save_proficiency": false },
      "DEX": { "score": 16, "modifier": 3, "save": 3, "save_proficiency": false },
      "CON": { "score": 13, "modifier": 1, "save": 1, "save_proficiency": false },
      "INT": { "score": 16, "modifier": 3, "save": 5, "save_proficiency": true },
      "WIS": { "score": 12, "modifier": 1, "save": 3, "save_proficiency": true },
      "CHA": { "score": 10, "modifier": 0, "save": 0, "save_proficiency": false }
    },

    "skills": {
      "acrobatics": { "stat": "DEX", "bonus": 3, "proficient": false },
      "animal_handling": { "stat": "WIS", "bonus": 1, "proficient": false },
      "arcana": { "stat": "INT", "bonus": 5, "proficient": true },
      "athletics": { "stat": "STR", "bonus": -1, "proficient": false },
      "deception": { "stat": "CHA", "bonus": 0, "proficient": false },
      "history": { "stat": "INT", "bonus": 5, "proficient": true },
      "insight": { "stat": "WIS", "bonus": 3, "proficient": true },
      "intimidation": { "stat": "CHA", "bonus": 0, "proficient": false },
      "investigation": { "stat": "INT", "bonus": 5, "proficient": true },
      "medicine": { "stat": "WIS", "bonus": 1, "proficient": false },
      "nature": { "stat": "INT", "bonus": 3, "proficient": false },
      "perception": { "stat": "WIS", "bonus": 3, "proficient": true },
      "performance": { "stat": "CHA", "bonus": 0, "proficient": false },
      "persuasion": { "stat": "CHA", "bonus": 0, "proficient": false },
      "religion": { "stat": "INT", "bonus": 3, "proficient": false },
      "sleight_of_hand": { "stat": "DEX", "bonus": 3, "proficient": false },
      "stealth": { "stat": "DEX", "bonus": 3, "proficient": false },
      "survival": { "stat": "WIS", "bonus": 1, "proficient": false }
    },

    "combat_actions": {
      "weapons":[
        {
          "name": "Adaga",
          "attack_bonus": 5,
          "damage": "1d4 + 3",
          "damage_type": "Perfurante",
          "properties":["Acuidade", "Leve", "Arremesso (6/18m)"]
        }
      ]
    },

    "features_and_traits":[
      { "name": "Visão no Escuro", "source": "Raça", "description": "Você enxerga na meia-luz a até 18 metros como se fosse luz plena." },
      { "name": "Ancestralidade Feérica", "source": "Raça", "description": "Vantagem contra ser enfeitiçado, magia não pode adormecê-mo." },
      { "name": "Transe", "source": "Raça", "description": "Você não precisa dormir, apenas medita por 4 horas." },
      { "name": "Recuperação Arcana", "source": "Classe", "description": "Recupera espaços de magia gastos após um descanso curto." },
      { "name": "Pesquisador", "source": "Antecedente", "description": "Se você não sabe de algo, geralmente sabe onde encontrar a informação." }
    ],

    "proficiencies_and_languages": {
      "armor": ["Nenhuma"],
      "weapons":["Adagas", "Dardos", "Fundas", "Bastões", "Bestas Leves", "Espadas Longas", "Espadas Curtas", "Arcos Longos", "Arcos Curtos"],
      "tools": ["Nenhuma"],
      "languages":["Comum", "Élfico", "Anão", "Dracônico"]
    },

    "equipment": {
      "currency": { "cp": 0, "sp": 0, "ep": 0, "gp": 10, "pp": 0 },
      "items":[
        "Adaga",
        "Grimório",
        "Foco Arcano (Varinha)",
        "Pacote de Estudioso",
        "Tinteiro e Pena",
        "Faca pequena",
        "Carta de um colega morto",
        "Roupas comuns"
      ]
    },

    "spellcasting": {
      "is_spellcaster": true,
      "spellcasting_ability": "INT",
      "spell_save_dc": 13,
      "spell_attack_bonus": 5,
      "slots_total": { "level_1": 2 },
      "slots_expended": { "level_1": 0 },
      "spells_known": {
        "cantrips":["Raio de Fogo", "Ilusão Menor", "Mãos Mágicas", "Prestidigitação"],
        "level_1":["Mísseis Mágicos", "Escudo Arcano", "Armadura Arcana", "Detectar Magia", "Identificar", "Sono"]
      }
    }
  }
}