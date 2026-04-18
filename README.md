# Dungeon Companion

A D&D Dungeon Master assistant powered by AI. The application helps DMs during sessions by generating character sheets, monster stat blocks, and lore — all via AI agents backed by Anthropic's Claude API.

---

## Project Overview

The system is split into two packages:

```
dungeon-companion/
├── dungeon-companion-api/   # LoopBack 4 REST API (Node.js + TypeScript)
└── dungeon-companion-web/   # Angular 21 frontend (TypeScript + SCSS)
```

### Architecture

```
Browser (Angular)
    │
    │  HTTP POST /api/character-sheet
    ▼
LoopBack 4 Controller
    │
    ▼
AiAgentService
    │  Sends structured prompt
    ▼
Anthropic Claude API
    │  Returns JSON
    ▼
Structured response back to browser
```

### AI Agent — "The Forge"

The core AI agent lives in `dungeon-companion-api/src/services/ai-agent.service.ts`. It sends a system prompt defining a persona called **The Forge**, calls `claude-3-5-sonnet-latest`, and parses the response as structured JSON. The frontend wizard collects the character build choices from the user and sends them as the request body.

### Planned features (not yet built)

- **The Loremaster** — RAG agent with a Vector DB for D&D lore and SRD retrieval
- **The Scribe** — Campaign persistence agent (PostgreSQL/MongoDB)
- **Multi-agent orchestration** — Router that delegates to specialized sub-agents
- **Combat tracker** and **adventure importer**

---

## Backend Setup (`dungeon-companion-api`)

### Requirements

- Node.js `20`, `22`, or `24`
- An [Anthropic API key](https://console.anthropic.com/)

### Installation

```bash
cd dungeon-companion-api
npm install
```

### Environment

Create a `.env` file inside `dungeon-companion-api/`:

```env
ANTHROPIC_API_KEY=your_api_key_here
```

### Running

```bash
# Build + start server on http://localhost:3000
npm start
```

### Other commands

```bash
npm run build        # Compile TypeScript to dist/
npm run rebuild      # Clean + full rebuild
npm test             # Run Mocha tests + lint
npm run lint:fix     # Auto-fix ESLint and Prettier issues
npm run docker:build # Build Docker image
npm run docker:run   # Run Docker container on port 3000
```

### API Explorer

With the server running, visit `http://localhost:3000/explorer` for the interactive OpenAPI docs.

### Key endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/ping` | Health check |
| `POST` | `/api/character-sheet` | Generate a character sheet via AI |

---

## Frontend Setup (`dungeon-companion-web`)

### Requirements

- Node.js `20+`
- Angular CLI `21+`

### Installation

```bash
# Install Angular CLI globally (only needed once)
npm install -g @angular/cli

cd dungeon-companion-web
npm install
```

### Running

```bash
npm start
# or
ng serve
```

Access the app at `http://localhost:4200`.

### Build for production

```bash
npm run build
# Output: dist/dungeon-companion-web/
```

### Key commands

```bash
npm start        # Dev server with hot reload on :4200
npm run build    # Production bundle
npm test         # Unit tests (Vitest)
```

---

## Character Creation Wizard

The frontend features a 7-step Pixel Art wizard for creating D&D character sheets:

| Step | Screen |
|------|--------|
| 1 | Core Build (level, race, class, background) |
| 2 | Character Details (name, age, alignment) |
| 3 | Attributes (FOR, DES, CON, INT, SAB, CAR) |
| 4 | Spells |
| 5 | Skills |
| 6 | Equipment (armor, shield) |
| 7 | Summary sheet + **Save** (sends to API) |

Clicking **SALVAR JOGO** on the final screen sends a `POST` request to `http://127.0.0.1:3000/api/character-sheet` with the full character data as JSON.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend framework | [LoopBack 4](https://loopback.io/) |
| Language | TypeScript |
| AI SDK | `@anthropic-ai/sdk` |
| AI Model | `claude-3-5-sonnet-latest` |
| Frontend framework | Angular 21 (standalone components) |
| Styling | SCSS + Pixel Art theme (`Press Start 2P` font) |
| HTTP client | Angular `HttpClient` |

---

## Development Notes

- The API requires `ANTHROPIC_API_KEY` to be set before starting.
- The frontend proxies to `http://127.0.0.1:3000` — make sure the API is running before submitting forms.
- Both projects are independent; they can be started in any order.
