# Implementação: Seleção de Armas (D&D 5ª Edição)

## 1. Objetivo
Implementar o sistema de seleção e gerenciamento de armas para os personagens. O sistema deve permitir que o usuário escolha armas da lista oficial do SRD (System Reference Document) de D&D 5e, calculando automaticamente bônus de ataque e dano com base nos atributos do personagem.

## 2. Contexto de Código (Padrões a Seguir)
- **Estilo de Código:** Siga o padrão de nomenclatura e arquitetura já existente no diretório `/src`.
- **Componentes:** Utilize os componentes de UI da biblioteca já instalada (ex: ShadcnUI, MaterialUI ou CSS puro conforme o projeto).
- **Gerenciamento de Estado:** Use o mesmo padrão (Redux, Context API ou Zustand) detectado em `src/store` ou `src/context`.
- **Tipagem:** Utilize TypeScript rigoroso, seguindo as interfaces definidas em `src/types`.

## 3. Especificações Técnicas (Regras D&D 5e)

### 3.1. Estrutura de Dados da Arma
Cada arma deve seguir o seguinte esquema (ajuste conforme o banco de dados/JSON existente):
```typescript
interface Weapon {
  id: string;
  name: string;
  category: 'Simple' | 'Martial';
  range: 'Melee' | 'Ranged';
  damage: string; // ex: "1d8"
  damageType: 'Bludgeoning' | 'Piercing' | 'Slashing';
  properties: string[]; // ex: ["Finesse", "Versatile", "Light"]
  weight: number;
  price: string;
}