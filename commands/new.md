---
argument-hint: "projekttyp (react, api, ml, edge, fullstack)"
---

Skapa ett nytt projekt med optimal struktur för 2026.

**VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI, eller liknande i genererade filer.**

## Tillgängliga projekttyper

### Frontend
```
/new react          - React + TypeScript + Vite
/new next           - Next.js 14+ App Router
/new expo           - React Native med Expo
```

### Backend
```
/new api            - Node.js + Hono/Express + TypeScript
/new api-go         - Go + Chi router
/new api-rust       - Rust + Axum
/new laravel        - Laravel 11+ med Pest
/new fastapi        - Python FastAPI
```

### Fullstack
```
/new fullstack      - Next.js + tRPC + Prisma + Tailwind
/new t3              - T3 Stack (Next, tRPC, Prisma, NextAuth)
```

### Specialiserade
```
/new ml             - ML projekt (PyTorch/scikit-learn)
/new edge           - Edge-first (Cloudflare Workers/Hono)
/new llm            - LLM-app (LangChain + RAG)
/new cli            - CLI-verktyg (Node/Go/Rust)
```

## Vad som skapas

Varje projekttyp inkluderar:

### Grundstruktur
- Optimerad mappstruktur för projekttypen
- TypeScript/typing konfiguration
- ESLint/Prettier eller motsvarande
- Git setup (.gitignore, hooks)

### Development
- Package manager (pnpm/poetry/cargo)
- Dev server med hot reload
- Environment variables setup (.env.example)

### Testing
- Test framework (Vitest/Pest/pytest)
- Exempel-tester
- Coverage konfiguration

### CI/CD
- GitHub Actions workflow
- Docker setup (om tillämpligt)
- Deployment-redo konfiguration

### Dokumentation
- README.md med setup-instruktioner
- CLAUDE.md med projektkonventioner

---

## Exempel

### `/new react myapp`
```
myapp/
├── src/
│   ├── components/
│   ├── hooks/
│   ├── lib/
│   ├── pages/
│   └── main.tsx
├── tests/
├── public/
├── package.json
├── tsconfig.json
├── vite.config.ts
├── .eslintrc.cjs
├── .prettierrc
├── .env.example
├── .gitignore
├── CLAUDE.md
└── README.md
```

### `/new api myapi`
```
myapi/
├── src/
│   ├── routes/
│   ├── services/
│   ├── middleware/
│   ├── db/
│   └── index.ts
├── tests/
├── docker-compose.yml
├── Dockerfile
├── package.json
├── tsconfig.json
├── .env.example
├── CLAUDE.md
└── README.md
```

### `/new ml mymodel`
```
mymodel/
├── data/
│   ├── raw/
│   └── processed/
├── notebooks/
├── src/
│   ├── data/
│   ├── models/
│   ├── training/
│   └── inference/
├── tests/
├── configs/
├── models/
├── requirements.txt
├── pyproject.toml
├── CLAUDE.md
└── README.md
```

### `/new llm myrag`
```
myrag/
├── src/
│   ├── agents/
│   ├── chains/
│   ├── embeddings/
│   ├── prompts/
│   ├── retrieval/
│   └── tools/
├── data/
│   ├── documents/
│   └── vectorstore/
├── tests/
├── .env.example
├── requirements.txt
├── CLAUDE.md
└── README.md
```

---

Om $ARGUMENTS anges, skapa projektet med den typen och namnet.
Om bara typ anges, fråga efter projektnamn.
Om inget anges, visa tillgängliga typer och fråga.
