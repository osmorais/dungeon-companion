# Dungeon Companion

Um assistente para Dungeon Masters de D&D com inteligência artificial. A aplicação ajuda os DMs durante as sessões gerando fichas de personagens, blocos de status de monstros e informações de lore — tudo via agentes de IA utilizando a API Claude da Anthropic.

---

## Visão Geral do Projeto

O sistema é dividido em dois pacotes:

```
dungeon-companion/
├── dungeon-companion-api/   # REST API LoopBack 4 (Node.js + TypeScript)
└── dungeon-companion-web/   # Frontend Angular 21 (TypeScript + SCSS)
```

### Arquitetura

```
Navegador (Angular)
    │
    │  HTTP POST /api/character-sheet
    ▼
Controller LoopBack 4
    │
    ▼
AiAgentService
    │  Envia prompt estruturado
    ▼
Anthropic Claude API
    │  Retorna JSON
    ▼
Resposta estruturada de volta ao navegador
```

### Agente de IA — "The Forge"

O agente de IA principal está em `dungeon-companion-api/src/services/ai-agent.service.ts`. Ele envia um system prompt definindo uma persona chamada **The Forge**, chama o modelo `claude-3-5-sonnet-latest` e faz o parse da resposta como JSON estruturado. O wizard do frontend coleta as escolhas de criação do personagem e as envia como corpo da requisição.

### Funcionalidades planejadas (ainda não implementadas)

- **The Loremaster** — Agente RAG com Vector DB para recuperação de lore e SRD do D&D
- **The Scribe** — Agente de persistência de campanhas (PostgreSQL/MongoDB)
- **Orquestração multi-agente** — Roteador que delega tarefas para sub-agentes especializados
- **Rastreador de combate** e **importador de aventuras**

---

## Configuração do Backend (`dungeon-companion-api`)

### Requisitos

- Node.js `20`, `22` ou `24`
- Uma [chave de API da Anthropic](https://console.anthropic.com/)

### Instalação

```bash
cd dungeon-companion-api
npm install
```

### Variáveis de Ambiente

Crie um arquivo `.env` dentro de `dungeon-companion-api/`:

```env
ANTHROPIC_API_KEY=sua_chave_aqui
```

### Executando

```bash
# Build + inicia o servidor em http://localhost:3000
npm start
```

### Outros comandos

```bash
npm run build        # Compila TypeScript para dist/
npm run rebuild      # Limpa + rebuild completo
npm test             # Executa testes Mocha + lint
npm run lint:fix     # Corrige automaticamente ESLint e Prettier
npm run docker:build # Gera imagem Docker
npm run docker:run   # Executa container Docker na porta 3000
```

### API Explorer

Com o servidor em execução, acesse `http://localhost:3000/explorer` para a documentação interativa OpenAPI.

### Endpoints principais

| Método | Caminho | Descrição |
|--------|---------|-----------|
| `GET` | `/ping` | Health check |
| `POST` | `/api/character-sheet` | Gera uma ficha de personagem via IA |

---

## Configuração do Frontend (`dungeon-companion-web`)

### Requisitos

- Node.js `20+`
- Angular CLI `21+`

### Instalação

```bash
# Instala o Angular CLI globalmente (apenas uma vez)
npm install -g @angular/cli

cd dungeon-companion-web
npm install
```

### Executando

```bash
npm start
# ou
ng serve
```

Acesse a aplicação em `http://localhost:4200`.

### Build para produção

```bash
npm run build
# Saída: dist/dungeon-companion-web/
```

### Comandos principais

```bash
npm start        # Servidor de desenvolvimento com hot reload na porta 4200
npm run build    # Bundle de produção
npm test         # Testes unitários (Vitest)
```

---

## Wizard de Criação de Personagem

O frontend possui um wizard de 7 etapas com tema Pixel Art para criação de fichas de D&D:

| Etapa | Tela |
|-------|------|
| 1 | Construção Básica (nível, raça, classe, antecedente) |
| 2 | Detalhes do Personagem (nome, idade, alinhamento) |
| 3 | Atributos (FOR, DES, CON, INT, SAB, CAR) |
| 4 | Magias |
| 5 | Perícias |
| 6 | Equipamento (armadura, escudo) |
| 7 | Ficha de resumo + **Salvar** (envia para a API) |

Ao clicar em **SALVAR JOGO** na tela final, é enviada uma requisição `POST` para `http://127.0.0.1:3000/api/character-sheet` com os dados completos do personagem em JSON.

---

## Stack Tecnológica

| Camada | Tecnologia |
|--------|-----------|
| Framework backend | [LoopBack 4](https://loopback.io/) |
| Linguagem | TypeScript |
| SDK de IA | `@anthropic-ai/sdk` |
| Modelo de IA | `claude-3-5-sonnet-latest` |
| Framework frontend | Angular 21 (standalone components) |
| Estilização | SCSS + tema Pixel Art (fonte `Press Start 2P`) |
| Cliente HTTP | Angular `HttpClient` |

---

## Observações de Desenvolvimento

- A API exige que `ANTHROPIC_API_KEY` esteja configurada antes de iniciar.
- O frontend faz requisições para `http://127.0.0.1:3000` — certifique-se de que a API está rodando antes de submeter formulários.
- Os dois projetos são independentes e podem ser iniciados em qualquer ordem.
