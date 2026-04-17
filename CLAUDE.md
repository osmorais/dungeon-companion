# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands run from `dungeon-companion-api/`:

```bash
npm run build          # Compile TypeScript to dist/
npm run rebuild        # Clean + full rebuild
npm start              # Rebuild and start server on :3000
npm test               # Run Mocha tests + lint
npm run lint:fix       # Auto-fix ESLint and Prettier issues
npm run docker:build   # Build Docker image
npm run docker:run     # Run Docker container
```

To run a single test file:
```bash
npx mocha --require source-map-support/register dist/__tests__/acceptance/ping.acceptance.js
```

## Architecture

This is a LoopBack 4 REST API (TypeScript) that serves as the backend for a D&D Dungeon Master assistant. It integrates Anthropic's Claude API to power AI agents for character/monster/lore generation.

**Request flow:** HTTP request → LoopBack `sequence.ts` → Controller → Service → Anthropic SDK → structured JSON response

**Key layers:**
- `src/controllers/` — REST endpoints decorated with `@get`/`@post` and OpenAPI metadata. Each controller is auto-discovered by LoopBack's boot component.
- `src/services/` — Business logic. `AiAgentService` wraps the Anthropic SDK and hosts named agents (currently "The Forge" for character generation). Services use `TRANSIENT` binding scope and are injected into controllers.
- `src/application.ts` — Wires up LoopBack, mounts REST explorer at `/explorer`, serves static files from `public/`.

**AI Agent pattern:** Each agent in `AiAgentService` sends a system prompt defining a persona (e.g., "The Forge"), calls `client.messages.create()` with `claude-3-5-sonnet-latest`, then parses the response as JSON (stripping markdown fences if present).

**Environment:** Requires `ANTHROPIC_API_KEY` in a `.env` file at `dungeon-companion-api/`.

**Planned but not yet built:** multi-agent orchestration (Loremaster for RAG, Scribe for persistence), vector DB for lore retrieval, campaign persistence, and a React/Next.js frontend.
