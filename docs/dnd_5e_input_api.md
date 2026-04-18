


Com base na estrutura do guia que criamos, a sua API precisará receber um "pacote" de dados (geralmente em formato JSON) contendo as escolhas do usuário. Como o objetivo é automatizar os cálculos e regras, o input deve focar apenas nas **decisões fundamentais** do jogador. O resto, o Claude fará sozinho.

Aqui está a estrutura ideal de dados de Input (o *Payload* da sua API) dividida por categorias, acompanhada de um exemplo em JSON.

### Estrutura de Input da API

#### 1. Informações Básicas (`core_build`)
São os dados obrigatórios que definem as regras e a matemática principal da ficha.
*   **`level`** (Int): O nível do personagem (define Bônus de Proficiência, HP, Magias).
*   **`race`** (String): A raça escolhida (ex: "Elfo").
*   **`subrace`** (String / Opcional): Sub-raça, se aplicável (ex: "Alto Elfo").
*   **`class`** (String): A classe escolhida (ex: "Mago").
*   **`background`** (String): O antecedente do personagem (ex: "Sábio").

#### 2. Atributos (`attributes`)
Como os atributos do nível 1 serão definidos antes de somar os bônus raciais.
*   **`generation_method`** (String): Pode ser `"standard_array"` (15, 14, 13... ), `"point_buy"` (compra de pontos) ou `"manual"`.
*   **`base_values`** (Objeto): Os números que o jogador alocou para cada atributo (FOR, DES, CON, INT, SAB, CAR), *antes* de somar os bônus de raça.

#### 3. Personalização e Escolhas (`choices`)
As classes e antecedentes dão direito a escolher algumas coisas. A API precisa saber o que o usuário escolheu dentro das opções permitidas.
*   **`skills`** (Array de Strings): As perícias que o jogador escolheu ser proficiente (ex: ["Arcanismo", "História"]).
*   **`spells`** (Array de Strings / Opcional): Se for conjurador, quais feitiços ele selecionou.
*   **`feats`** (Array de Strings / Opcional): Se estiver usando regras opcionais (como Humano Variante) ou criando nível alto.

#### 4. Detalhes de Roleplay (`character_details`)
Informações narrativas (podem ser opcionais na API; se o usuário não enviar, você pode programar o Claude para gerar nomes e idades aleatórias que combinem com a raça).
*   **`name`**: Nome do personagem.
*   **`alignment`**: Tendência (ex: "Leal e Neutro").
*   **`age`, `height`, `weight`**: Físico do personagem.

#### 5. Equipamentos Iniciais (`equipment`)
Como o jogador prefere se vestir/armar (o que afeta o cálculo da Classe de Armadura e Dano).
*   **`armor_type`** (String): Tipo de armadura inicial (ex: "Couro Batido").
*   **`weapons`** (Array): Armas escolhidas (ex:["Espada Curta", "Arco Curto"]).
*   **`has_shield`** (Boolean): `true` ou `false` (para a API saber se deve somar +2 na CA).

---

### Exemplo de Payload JSON para a API

Se o seu front-end (ou prompt de usuário) enviar este JSON para o Claude Code, ele terá tudo o que precisa para cruzar com o arquivo `.md` e devolver a ficha preenchida:

```json
{
  "core_build": {
    "level": 1,
    "race": "Elfo",
    "subrace": "Alto Elfo",
    "class": "Mago",
    "background": "Sábio"
  },
  "attributes": {
    "generation_method": "standard_array",
    "base_values": {
      "FOR": 8,
      "DES": 14,
      "CON": 13,
      "INT": 15,
      "SAB": 12,
      "CAR": 10
    }
  },
  "choices": {
    "skills": ["Arcanismo", "História", "Investigação", "Intuição"],
    "spells":["Raio de Fogo", "Ilusão Menor", "Mãos Mágicas", "Mísseis Mágicos", "Escudo Arcano"],
    "feats":[]
  },
  "equipment": {
    "armor_type": "Nenhuma",
    "weapons": ["Adaga"],
    "has_shield": false
  },
  "character_details": {
    "name": "Eldrin",
    "alignment": "Caótico e Bom",
    "age": 120
  }
}
```

### O que acontece no lado da sua API com este Input?
Quando este input entra, o seu aplicativo orienta o Claude a fazer o seguinte (seguindo a Etapa 9 do arquivo `.md`):
1. **Lê a raça:** Vê que é Alto Elfo. Automaticamente pega INT 15 e soma +1 (Sub-raça) e pega DES 14 e soma +2 (Raça).
2. **Calcula Modificadores:** INT vira 16 (+3), DES vira 16 (+3).
3. **Calcula CA:** CA sem armadura = 10 + 3 (Mod. DES) = 13.
4. **Calcula Magia:** Como é Mago, usa INT. Bônus de Ataque = +5 (Proficiência +2 + INT +3). CD de Magia = 13 (8 + 2 + 3).

Ao estruturar a entrada de dados dessa forma enxuta, sua API não precisa enviar cálculos, apenas as **escolhas brutas**, deixando todo o "trabalho sujo" da matemática e da regra para o LLM processar e te devolver a ficha pronta.