# Dungeon Companion — Architecture & Stack Guide

This document explains how the application is structured, how the stack fits together, and how to extend it.

---

## Table of Contents

1. [What Is This?](#1-what-is-this)
2. [Technology Stack](#2-technology-stack)
3. [Project Layout](#3-project-layout)
4. [Application Layers](#4-application-layers)
5. [Request Flow](#5-request-flow)
6. [AI Provider System](#6-ai-provider-system)
7. [Agentic Loop (Tool Use)](#7-agentic-loop-tool-use)
8. [Environment Configuration](#8-environment-configuration)
9. [Running Locally](#9-running-locally)
10. [Docker & Infrastructure](#10-docker--infrastructure)
11. [Testing](#11-testing)
12. [Extending the Application](#12-extending-the-application)
13. [Roadmap](#13-roadmap)

---

## 1. What Is This?

Dungeon Companion is a REST API that acts as an AI-powered Dungeon Master assistant for D&D 5e. The backend exposes endpoints that invoke named AI agents — each with a persona, system prompt, and optional tool-use capabilities — to generate structured game content (characters, monsters, lore) as JSON.

The first implemented agent is **The Forge**: a character-generation agent that can either produce a character in a single LLM call or orchestrate a multi-step agentic loop using tools (dice rolling, class feature lookup).

---

## 2. Technology Stack

| Layer | Technology | Version |
|---|---|---|
| Language | TypeScript | 5.2.2 |
| Runtime | Node.js | 20/22/24 |
| Web Framework | LoopBack 4 | 8.x |
| Primary AI Client | Anthropic SDK (`@anthropic-ai/sdk`) | 0.90.0+ |
| Optional AI Client | OpenAI SDK (`openai`) | 6.34.0 |
| Test Runner | Mocha + `@loopback/testlab` | 11.7.5 |
| Linter / Formatter | ESLint + Prettier | 8.57.1 / 3.8.2 |
| Container | Docker (Node 24 slim) | — |
| Config | dotenv | 17.4.2 |

**Why LoopBack 4?**  
LoopBack 4 provides a TypeScript-first decorator-driven approach to REST APIs: controllers and services are auto-discovered on boot, dependency injection is built-in, and an interactive OpenAPI explorer (`/explorer`) is available out of the box.

---

## 3. Project Layout

```
dungeon-companion/
├── CLAUDE.md                        # Developer instructions for Claude Code
├── README.md                        # Project concept and roadmap
├── docs/
│   └── architecture.md              # This file
└── dungeon-companion-api/           # The REST API (all runnable code lives here)
    ├── .env                         # Secret keys (not in version control)
    ├── Dockerfile
    ├── package.json
    ├── tsconfig.json
    └── src/
        ├── index.ts                 # Entry point — boots app and starts server
        ├── application.ts           # App wiring (LoopBack config, explorer, static files)
        ├── sequence.ts              # Custom request middleware sequence
        ├── openapi-spec.ts          # CLI helper to export OpenAPI spec to a file
        ├── controllers/             # HTTP route handlers
        │   ├── ping.controller.ts   # GET /ping — health check
        │   └── character.controller.ts  # GET /api/generate-character[–with-tools]
        ├── services/
        │   └── ai-agent.service.ts  # AI agent logic, tool implementations, JSON parsing
        ├── providers/               # Pluggable AI backends
        │   ├── ai-provider.interface.ts  # Shared contract (IAiProvider, AiTool)
        │   ├── anthropic.provider.ts     # Claude implementation
        │   ├── openai.provider.ts        # OpenAI implementation
        │   └── index.ts                  # Factory function (createAiProvider)
        ├── models/                  # Placeholder — data models (not yet built)
        ├── repositories/            # Placeholder — data access layer (not yet built)
        ├── datasources/             # Placeholder — database connections (not yet built)
        └── __tests__/
            └── acceptance/          # Integration tests (hit real HTTP endpoints)
```

---

## 4. Application Layers

### 4.1 Entry Point (`index.ts`)

Bootstraps the app, starts listening on `PORT` (default `3000`) and `HOST` (default `127.0.0.1`). Includes a 5-second graceful-shutdown timeout.

### 4.2 Application (`application.ts`)

Configures the LoopBack app:
- Registers `MySequence` as the request handler pipeline
- Mounts static files from `public/` at `/` (serves `index.html`)
- Mounts the REST Explorer at `/explorer`
- Tells LoopBack's boot component where to find controllers (`controllers/*.controller.js`)

### 4.3 Sequence (`sequence.ts`)

Extends LoopBack's `MiddlewareSequence`. Currently uses defaults (routing → parsing → invoking → serializing → error handling). This is where you would add cross-cutting concerns like authentication middleware or request logging.

### 4.4 Controllers (`controllers/`)

Thin HTTP layer. Each controller:
- Declares one or more routes with `@get`/`@post` decorators and OpenAPI metadata
- Receives injected services via constructor
- Delegates all logic to the service layer
- Returns the service result directly (LoopBack serializes it as JSON)

```
GET /ping                             → PingController
GET /api/generate-character           → CharacterController.generate()
GET /api/generate-character-with-tools → CharacterController.generateWithTools()
```

### 4.5 Services (`services/`)

Business logic lives here. `AiAgentService`:
- Is `TRANSIENT`-scoped (new instance per injection)
- Initializes the AI provider on construction via `createAiProvider()`
- Defines the tools available to agents (`DND_TOOLS`)
- Implements tool execution server-side (`rollDice`, `getClassFeatures`, `executeTool`)
- Calls the provider and parses the structured JSON response

### 4.6 Providers (`providers/`)

Abstracts the difference between AI backends behind `IAiProvider`:

```typescript
interface IAiProvider {
  chat(systemPrompt: string, userMessage: string): Promise<string>;
  chatWithTools(
    systemPrompt: string,
    userMessage: string,
    tools: AiTool[],
    toolExecutor: (name: string, input: Record<string, unknown>) => string,
  ): Promise<string>;
}
```

`createAiProvider()` reads `AI_PROVIDER` from the environment and returns either `AnthropicProvider` or `OpenAiProvider`.

---

## 5. Request Flow

```
HTTP GET /api/generate-character?class=Rogue&level=3
       │
       ▼
LoopBack Router
  (matches route from CharacterController metadata)
       │
       ▼
MySequence (middleware pipeline)
  parse → authenticate → route → invoke → serialize
       │
       ▼
CharacterController.generate(charClass, level)
  (injects AiAgentService)
       │
       ▼
AiAgentService.generateCharacter(charClass, level)
  builds system prompt ("You are The Forge…")
  builds user message ("Generate a level 3 Rogue…")
       │
       ▼
IAiProvider.chat(systemPrompt, userMessage)
  (AnthropicProvider or OpenAiProvider, selected at startup)
       │
       ▼
Anthropic / OpenAI API
  returns raw text with JSON (possibly in markdown fences)
       │
       ▼
AiAgentService.parseJson(text)
  strips ```json … ``` fences if present
  JSON.parse()
       │
       ▼
HTTP 200  { name, race, class, level, hp, armorClass, stats, inventory }
```

The tool-use variant (`/api/generate-character-with-tools`) inserts an **agentic loop** between the provider and the final JSON — see Section 7.

---

## 6. AI Provider System

### Provider Interface

The `IAiProvider` interface lives in `providers/ai-provider.interface.ts` and defines two methods:

- `chat()` — single-turn, no tools. Used for simple generation.
- `chatWithTools()` — multi-turn agentic loop with tool call/result cycles.

`AiTool` is a provider-agnostic tool definition that both providers translate into their native format internally.

### Anthropic Provider

File: `providers/anthropic.provider.ts`

- Uses `@anthropic-ai/sdk`
- Model env vars: `ANTHROPIC_MODEL` (default `claude-sonnet-4-6`) and `ANTHROPIC_AGENT_MODEL` (default `claude-opus-4-7`)
- Converts `AiTool[]` to Anthropic's `Tool[]` format
- Implements the agentic loop by checking `stop_reason`:
  - `tool_use` → collect tool calls, execute via `toolExecutor`, send `tool_result` messages
  - `end_turn` → extract final text and return

### OpenAI Provider

File: `providers/openai.provider.ts`

- Uses `openai` SDK
- Model env vars: `OPENAI_MODEL` (default `gpt-4o-mini`) and `OPENAI_AGENT_MODEL` (default `gpt-4o`)
- Converts `AiTool[]` to OpenAI's `function` tool format
- Agentic loop driven by `finish_reason`:
  - `tool_calls` → execute all requested tool calls, send results back
  - Other (e.g. `stop`) → return final content

### Switching Providers

Set the environment variable before starting the server:

```bash
AI_PROVIDER=openai npm start    # use OpenAI
AI_PROVIDER=anthropic npm start  # use Claude (default)
```

No code changes required — the factory in `providers/index.ts` handles the selection.

---

## 7. Agentic Loop (Tool Use)

When `generateCharacterWithTools()` is called, the provider runs a conversation loop:

```
1. Send system prompt + user message + tool definitions to the LLM

2. LLM responds with stop_reason = "tool_use"
   └─ One or more tool calls are returned (e.g. roll_dice("4d6"), get_class_features("Rogue", 3))

3. Server executes each tool call via AiAgentService.executeTool()
   └─ roll_dice:          evaluates D&D notation → returns integer sum
   └─ get_class_features: looks up hardcoded 5e feature table → returns string list

4. Tool results are appended to the conversation as "tool_result" messages

5. LLM receives the results and continues → either calls more tools or produces final JSON

6. Loop exits when stop_reason = "end_turn"
   └─ Final message is extracted and returned as a string

7. AiAgentService.parseJson() converts the string to a typed object
```

This pattern is identical across both providers. The service layer never knows which provider is running the loop — it only passes a `toolExecutor` callback.

### Current Tools

| Tool | Input | What It Does |
|---|---|---|
| `roll_dice` | `notation: string` (e.g. `"4d6+2"`) | Evaluates the dice expression, returns the numeric result |
| `get_class_features` | `className: string`, `level: number` | Returns D&D 5e features unlocked at the given level for the given class |

---

## 8. Environment Configuration

All configuration lives in `dungeon-companion-api/.env`. Never commit this file.

| Variable | Required | Default | Purpose |
|---|---|---|---|
| `ANTHROPIC_API_KEY` | Yes (if using Anthropic) | — | Authenticates Claude API calls |
| `OPENAI_API_KEY` | Yes (if using OpenAI) | — | Authenticates OpenAI API calls |
| `AI_PROVIDER` | No | `anthropic` | Selects the active provider (`anthropic` or `openai`) |
| `ANTHROPIC_MODEL` | No | `claude-sonnet-4-6` | Model used for simple `chat()` calls |
| `ANTHROPIC_AGENT_MODEL` | No | `claude-opus-4-7` | Model used for agentic `chatWithTools()` calls |
| `OPENAI_MODEL` | No | `gpt-4o-mini` | Model used for simple `chat()` calls |
| `OPENAI_AGENT_MODEL` | No | `gpt-4o` | Model used for agentic `chatWithTools()` calls |
| `PORT` | No | `3000` | HTTP server port |
| `HOST` | No | `127.0.0.1` | HTTP server host (use `0.0.0.0` in Docker) |

---

## 9. Running Locally

All commands run from `dungeon-companion-api/`:

```bash
# 1. Install dependencies
npm install

# 2. Create .env and add your API key
echo "ANTHROPIC_API_KEY=sk-ant-..." > .env

# 3. Start the server (builds first, then runs)
npm start
# → http://localhost:3000/

# 4. Open the API explorer
# → http://localhost:3000/explorer
```

**Useful endpoints once running:**

| URL | Description |
|---|---|
| `GET /ping` | Health check |
| `GET /api/generate-character?class=Rogue&level=3` | Generate character (single LLM call) |
| `GET /api/generate-character-with-tools?class=Fighter&level=5` | Generate character using agentic tool loop |
| `GET /explorer` | Interactive OpenAPI UI |
| `GET /openapi.json` | Raw OpenAPI spec |

---

## 10. Docker & Infrastructure

### Building and Running

```bash
# From dungeon-companion-api/
npm run docker:build   # builds image tagged 'dungeon-companion-api'
npm run docker:run     # runs container on host port 3000
```

Or manually:

```bash
docker build -t dungeon-companion-api .
docker run -p 3000:3000 -e ANTHROPIC_API_KEY=sk-ant-... dungeon-companion-api
```

### Dockerfile Breakdown

```dockerfile
FROM docker.io/library/node:24-slim    # Slim Node 24 base (~200 MB)
USER node                               # Run as non-root user for security
RUN mkdir -p /home/node/app
WORKDIR /home/node/app
COPY --chown=node package*.json ./
RUN npm install                         # Install deps before copying source (layer cache)
COPY --chown=node . .
RUN npm run build                       # Compile TypeScript inside the image
ENV HOST=0.0.0.0 PORT=3000             # Bind to all interfaces inside the container
EXPOSE 3000
CMD [ "node", "." ]                     # Run compiled entry point directly (no rebuild)
```

**Key points:**
- `HOST=0.0.0.0` is required inside Docker so the server listens on all network interfaces, not just loopback
- API keys must be passed at `docker run` time via `-e` flags (they are not baked into the image)
- The `.dockerignore` excludes `node_modules` and `dist`, so both are rebuilt clean inside the container

### Infrastructure Notes

There is currently no `docker-compose.yml`. The app is stateless (no database yet), so a single container is sufficient. When persistence is added, a `docker-compose.yml` with a database service will be needed.

---

## 11. Testing

Tests live in `src/__tests__/acceptance/` and are run against the compiled output in `dist/`.

```bash
npm test              # rebuild → run all tests → lint
npm run test:dev      # run tests without rebuild (faster during development)

# Run a single test file:
npx mocha --require source-map-support/register dist/__tests__/acceptance/ping.acceptance.js
```

### Test Structure

| File | What It Tests |
|---|---|
| `test-helper.ts` | Shared `setupApplication()` — boots a real app instance for each test |
| `home-page.acceptance.ts` | `GET /` returns HTML; `GET /explorer/` contains LoopBack UI |
| `ping.controller.acceptance.ts` | `GET /ping` returns expected greeting object |

Tests use `@loopback/testlab` which spins up the real application on a random port and issues HTTP requests against it — no mocking of the framework layer. AI service calls are not yet covered by tests.

---

## 12. Extending the Application

### Add a New AI Agent

1. Add a method to `AiAgentService` (e.g. `generateMonster(type, cr)`)
2. Define the system prompt for the new persona
3. Optionally add new tools to `DND_TOOLS` and implement them in `executeTool()`
4. Add a controller method that calls your new service method

### Add a New Tool

1. Add an entry to `DND_TOOLS` in `ai-agent.service.ts`:
   ```typescript
   {
     name: 'my_tool',
     description: 'What the LLM should use this for',
     inputSchema: {
       type: 'object',
       properties: { param: { type: 'string', description: '...' } },
       required: ['param'],
     },
   }
   ```
2. Add a `case 'my_tool':` branch in `executeTool()` that implements the logic and returns a string

Both providers will automatically pick up the new tool definition.

### Add a New AI Provider

1. Create `providers/myprovider.provider.ts` implementing `IAiProvider`
2. Add a branch to `providers/index.ts`:
   ```typescript
   if (provider === 'myprovider') return new MyProvider();
   ```
3. Set `AI_PROVIDER=myprovider` in `.env`

---

## 13. Roadmap

The following features are planned but not yet built:

| Feature | Description |
|---|---|
| **Loremaster agent** | RAG-powered agent for campaign lore retrieval using a vector database |
| **Scribe agent** | Persistence agent for saving campaign state to a database |
| **Multi-agent orchestration** | An orchestrator that coordinates Forge, Loremaster, and Scribe |
| **Campaign persistence** | Database layer (datasources + repositories) for characters and campaigns |
| **React/Next.js frontend** | Web UI that talks to this API |

The LoopBack placeholders (`src/models/`, `src/repositories/`, `src/datasources/`) are where the persistence layer will live when a database is introduced.
