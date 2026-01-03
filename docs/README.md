# Claude Code Setup - Användarguide

Din personliga Claude Code-konfiguration för att delegera kodarbete.

---

## Snabbstart

### Starta om Claude Code efter ändringar
```bash
# Avsluta nuvarande session och starta ny
# Ctrl+C, sedan:
claude
```

### Lista tillgängliga commands
```bash
# I Claude Code:
/help
```

---

## Scenario 1: Starta nytt projekt

### Steg 1: Skapa projekt
```bash
mkdir mitt-projekt && cd mitt-projekt
git init
claude
```

### Steg 2: Designa arkitektur
```
/architect e-handelsplattform med React frontend och Node.js backend

# Claude kommer fråga om:
# - Användare och skala
# - Budget/tid
# - Specifika krav
# - Integrationer

# Output: Arkitekturdokument med tech stack, komponenter, datamodell
```

### Steg 3: Skapa projektdokumentation
```
/init

# Skapar CLAUDE.md med:
# - Tech stack
# - Mappstruktur
# - Kommandon (dev, build, test)
# - Kodkonventioner
```

### Steg 4: Estimera arbetet
```
/estimate implementera user authentication

# Output:
# - T-shirt size (S/M/L/XL)
# - Breakdown av deluppgifter
# - Risker och osäkerheter
```

### Steg 5: Börja utveckla
```
Skapa grundstrukturen för projektet enligt arkitekturen

# eller mer specifikt:
Implementera user registration med email verifiering
```

### Steg 6: Granska innan commit
```
/review

# Kör code-reviewer agent
# Hittar onödig komplexitet, förenklingar

/security

# Kör security-reviewer agent
# Hittar sårbarheter
```

### Steg 7: Skapa PR
```
/pr

# Analyserar ändringar
# Genererar PR-beskrivning
# Skapar PR via gh cli
```

---

## Scenario 2: Fortsätta på existerande projekt

### Steg 1: Öppna projektet
```bash
cd mitt-existerande-projekt
claude
```

### Steg 2: Om CLAUDE.md saknas
```
/init

# Analyserar projektet och skapar dokumentation
```

### Steg 3: Vanliga arbetsflöden

#### Ny feature
```
Lägg till dark mode toggle i settings

# Claude:
# 1. Läser CLAUDE.md för att förstå projektet
# 2. Hittar rätt filer
# 3. Implementerar enligt projektets mönster
# 4. Föreslår tester
```

#### Buggfix
```
/debug användare kan inte logga in efter password reset

# Debugger-agent:
# 1. Samlar information
# 2. Formulerar hypoteser
# 3. Hittar root cause
# 4. Föreslår fix + test
```

#### Generera tester
```
/test src/services/userService.ts

# Test-writer agent:
# 1. Analyserar koden
# 2. Identifierar test cases
# 3. Genererar tester med edge cases
```

#### Refaktorering
```
/refactor src/components/Dashboard

# Analyserar och föreslår:
# - Enkla förbättringar
# - Medelstora refaktoreringar
# - Större omstruktureringar
```

#### Förklara kod
```
/explain src/lib/auth.ts

# Pedagogisk förklaring:
# - Vad gör koden
# - Hur fungerar dataflödet
# - Beroenden
```

### Steg 4: Uppgradera dependencies
```
/migrate update dependencies

# Migrator-agent:
# 1. Identifierar föråldrade paket
# 2. Kollar breaking changes
# 3. Skapar migreringsplan
# 4. Genomför stegvis
```

### Steg 5: Förbered deployment
```
/deploy staging

# DevOps-agent:
# 1. Kör pre-deployment checklist
# 2. Verifierar tester och build
# 3. Förbereder deployment
# 4. Dokumenterar rollback-plan
```

---

## Scenario 3: Ta över legacy-projekt

### Steg 1: Första analys
```bash
cd gammalt-php-projekt
claude
```

```
/legacy

# Legacy-analyst agent:
# 1. Identifierar språk/ramverk
# 2. Kartlägger struktur
# 3. Hittar risker (säkerhet, föråldrade deps)
# 4. Identifierar quick wins
# 5. Skapar moderniseringsplan
```

### Steg 2: Förstå koden
```
/explain hur fungerar checkout-flödet?

# Förklarar steg-för-steg hur koden fungerar
```

### Steg 3: Säkerhetsgranskning
```
/security

# Prioriterat efter allvarlighet:
# 🔴 Kritisk: SQL injection i login.php
# 🟠 Hög: XSS i kommentarer
# 🟡 Medium: Svag session-hantering
```

### Steg 4: Fixa kritiska problem först
```
Fixa SQL injection i login.php

# Claude fixar och lägger till test
```

### Steg 5: Gradvis modernisering
```
/migrate PHP 5.6 → 8.2

# Stegvis plan:
# 1. Fixa deprecated functions
# 2. Uppgradera syntax
# 3. Lägg till typer
# 4. Testa mellan varje steg
```

### Steg 6: Dokumentera för framtiden
```
/init

# Skapar CLAUDE.md så nästa person förstår projektet
```

---

## Scenario 4: Granska någon annans PR

### Steg 1: Hämta PR lokalt
```bash
gh pr checkout 123
claude
```

### Steg 2: Kör granskning
```
/review

# Kollar efter:
# - Onödig komplexitet
# - Saknade edge cases
# - Förbättringsmöjligheter
```

### Steg 3: Säkerhetskoll
```
/security

# Hittar sårbarheter innan merge
```

### Steg 4: Förstå ändringar
```
/explain vad gör denna PR?

# Sammanfattar ändringar på ett förståeligt sätt
```

---

## Scenario 5: Optimera prestanda

### Steg 1: Identifiera problem
```
Sidan /dashboard laddar långsamt, hjälp mig hitta flaskhalsar

# Performance-analyst aktiveras automatiskt
# Analyserar:
# - N+1 queries
# - Onödiga re-renders
# - Stora bundle sizes
# - Saknad caching
```

### Steg 2: Databasoptimering
```
Analysera och optimera databasqueries i UserRepository

# Kollar:
# - Index som saknas
# - Ineffektiva queries
# - N+1 problem
```

### Steg 3: Frontend optimering
```
Optimera React-komponenter i Dashboard

# Föreslår:
# - useMemo/useCallback
# - Lazy loading
# - Code splitting
```

---

## Scenario 6: Skriva dokumentation

### API-dokumentation
```
Generera OpenAPI spec för alla endpoints i /api

# Docs-writer agent skapar:
# - Endpoint beskrivningar
# - Request/response schemas
# - Exempel
```

### README för projekt
```
Skapa en README för detta projekt

# Inkluderar:
# - Installation
# - Användning
# - API reference
# - Contributing guide
```

### Inline dokumentation
```
Lägg till JSDoc/TSDoc för src/services/

# Dokumenterar:
# - Funktioner och parametrar
# - Return types
# - Exempel
```

---

## Scenario 7: Onboarding på nytt projekt

### Steg 1: Förstå projektet
```bash
cd nytt-projekt
claude
```

```
Förklara detta projekt för mig som om jag är ny i teamet

# Claude:
# 1. Läser CLAUDE.md (om finns)
# 2. Analyserar struktur
# 3. Identifierar tech stack
# 4. Förklarar arkitektur
# 5. Visar viktiga filer
```

### Steg 2: Hitta specifik funktionalitet
```
Var hanteras betalningar?
Hur fungerar autentiseringen?
Vilka API endpoints finns?
```

### Steg 3: Förstå dataflöden
```
/explain hur flödar data från frontend till databas vid checkout?
```

### Steg 4: Sätt upp lokal miljö
```
Hjälp mig komma igång med lokal utveckling

# Guidar genom:
# - Dependencies
# - Environment variables
# - Database setup
# - Starta dev server
```

---

## Scenario 8: Hantera teknisk skuld

### Steg 1: Identifiera skuld
```
Analysera projektet och identifiera teknisk skuld

# Hittar:
# - Föråldrade dependencies
# - Duplicerad kod
# - Saknade tester
# - Dålig felhantering
# - Hårdkodade värden
```

### Steg 2: Prioritera
```
/estimate fixa all teknisk skuld

# Breakdown med prioritet:
# 🔴 Kritisk: Säkerhetsproblem
# 🟠 Hög: Föråldrade deps med CVEs
# 🟡 Medium: Saknade tester
# 🟢 Låg: Kodstil
```

### Steg 3: Åtgärda stegvis
```
Fixa de kritiska säkerhetsproblemen först

# Sedan:
/migrate update dependencies
```

---

## Scenario 9: Skapa API från scratch

### Steg 1: Designa API
```
/architect REST API för bokningssystem

# Output:
# - Endpoints
# - Datamodell
# - Autentisering
# - Felhantering
```

### Steg 2: Generera kod
```
Skapa grundstrukturen för API:t enligt arkitekturen
```

### Steg 3: Lägg till validering
```
Lägg till input-validering för alla endpoints
```

### Steg 4: Generera tester
```
/test generera tester för alla endpoints
```

### Steg 5: Dokumentera
```
Generera OpenAPI dokumentation
```

---

## Scenario 10: Felsök produktionsproblem

### Steg 1: Samla information
```
/debug användare rapporterar 500-fel vid checkout

# Input:
# - Felmeddelanden
# - Stack traces
# - Loggar
# - Senaste deployments
```

### Steg 2: Analysera
```
# Debugger-agent:
# 1. Formulerar hypoteser
# 2. Identifierar trolig orsak
# 3. Föreslår fix
```

### Steg 3: Hotfix
```
Skapa hotfix för produktionsproblemet

# Minimal fix
# Inkluderar test
```

### Steg 4: Deploy fix
```
/deploy prod

# Verifierar allt är redo
# Dokumenterar rollback
```

---

## Scenario 11: Migrera till ny teknologi

### Från JavaScript till TypeScript
```
/migrate javascript → typescript för src/

# Stegvis:
# 1. Lägg till tsconfig
# 2. Byt namn på filer
# 3. Lägg till typer
# 4. Fixa errors
```

### Från REST till GraphQL
```
/architect migrera REST API till GraphQL

# Plan:
# 1. Behåll REST parallellt
# 2. Bygg GraphQL schema
# 3. Migrera endpoint för endpoint
# 4. Fasa ut REST
```

### Från monolith till microservices
```
/architect bryt ut user-service från monolith

# Identifierar:
# - Vilken kod som hör ihop
# - Beroenden
# - Dataägande
# - Kommunikation mellan tjänster
```

---

## Scenario 12: CI/CD Setup

### GitHub Actions från scratch
```
Skapa CI/CD pipeline med GitHub Actions

# DevOps-agent skapar:
# - Test workflow
# - Build workflow
# - Deploy workflow
# - Caching
```

### Docker setup
```
Skapa Dockerfile och docker-compose för projektet

# Optimerad multi-stage build
# Development compose
# Production-ready
```

### Deployment till molnet
```
/deploy konfigurera deployment till Vercel/AWS/GCP

# Guider genom:
# - Environment variables
# - Build settings
# - Domain setup
```

---

## Scenario 13: Snabbstarta nytt projekt

### Med projektmallar
```
/new react myapp

# Skapar komplett React-projekt med:
# - TypeScript + Vite
# - ESLint + Prettier
# - Vitest
# - GitHub Actions
# - CLAUDE.md
```

### Tillgängliga mallar
```
# Frontend
/new react          /new next           /new expo

# Backend
/new api            /new api-go         /new api-rust
/new laravel        /new fastapi

# Fullstack
/new fullstack      /new t3

# Specialiserade
/new ml             /new edge           /new llm
/new cli
```

---

## Scenario 14: Machine Learning Projekt

### Steg 1: Utforska data
```
Analysera datasetet i data/raw/sales.csv och ge mig en översikt

# Data Science skill aktiveras
# - Laddar data
# - Visar statistik
# - Identifierar saknade värden
# - Visar korrelationer
```

### Steg 2: Feature Engineering
```
Skapa features för att förutsäga kundchurn baserat på detta dataset

# Föreslår:
# - Numeriska transformationer
# - Kategorisk encoding
# - Datum-features
# - Interaktionsfeatures
```

### Steg 3: Modellering
```
Bygg en klassificeringsmodell för churn prediction med PyTorch

# ML skill aktiveras
# - Skapar Dataset klass
# - Definierar modellarkitektur
# - Training loop med validation
# - Experiment tracking
```

### Steg 4: Utvärdering
```
Utvärdera modellen och visualisera resultaten

# - Confusion matrix
# - ROC curve
# - Feature importance
# - Error analysis
```

### Steg 5: Deployment
```
Skapa en FastAPI endpoint för modellen

# - ONNX export
# - Inference server
# - Docker container
```

### Vanliga ML-uppgifter
```
# Hyperparameter tuning
Optimera hyperparameters för RandomForest med GridSearchCV

# Transfer learning
Finjustera BERT för sentiment analysis på mitt dataset

# Data augmentation
Lägg till data augmentation för bildklassificering

# Model comparison
Jämför XGBoost, LightGBM och CatBoost på detta dataset
```

---

## Scenario 15: Bygga LLM-applikation

### Steg 1: Skapa projekt
```
/new llm customer-support-bot
```

### Steg 2: Bygga RAG-pipeline
```
Skapa en RAG-pipeline för att svara på frågor baserat på vår dokumentation

# LLM-apps skill aktiveras
# - Document loading
# - Chunking strategi
# - Vector store setup
# - Retrieval chain
```

### Steg 3: Lägg till AI-agent
```
Skapa en agent som kan söka i dokumentation och skapa support-ärenden

# Multi-tool agent med:
# - Dokumentsökning
# - Ärendehantering
# - Uppföljningsfrågor
```

### Steg 4: Säkra applikationen
```
Lägg till prompt injection protection och rate limiting

# AI-säkerhet:
# - Input sanitization
# - Output validation
# - Rate limiting
# - Logging
```

---

## Scenario 16: Edge-first Applikation

### Steg 1: Skapa edge-projekt
```
/new edge global-api
```

### Steg 2: Implementera API
```
Skapa ett REST API med Hono som körs på Cloudflare Workers

# Edge skill aktiveras
# - Hono routing
# - KV för data
# - D1 för SQL
# - Caching
```

### Steg 3: Lägg till realtid
```
Implementera WebSocket-stöd för live-uppdateringar

# Event-driven skill aktiveras
# - Durable Objects för state
# - WebSocket connections
# - Broadcast till rum
```

### Steg 4: Global deployment
```
/deploy edge

# Multi-region deployment
# - Cloudflare edge network
# - Automatisk failover
# - Global caching
```

---

## Scenario 17: Event-Driven System

### Steg 1: Designa arkitektur
```
/architect event-driven order system med Kafka

# Designar:
# - Event types
# - Topics och partitioner
# - Consumer groups
# - CQRS read models
```

### Steg 2: Implementera producers
```
Skapa order-service som publicerar events till Kafka

# Inkluderar:
# - Event schema
# - Idempotency
# - Error handling
```

### Steg 3: Implementera consumers
```
Skapa inventory-service som lyssnar på order events

# Mönster:
# - Consumer group
# - Retry logic
# - Dead letter queue
```

### Steg 4: Lägg till monitoring
```
Konfigurera monitoring för Kafka och consumers

# Metrics:
# - Consumer lag
# - Throughput
# - Error rates
```

---

## Agents - När använda vilken?

| Situation | Agent | Command |
|-----------|-------|---------|
| Designa nytt system | `architect` | `/architect` |
| Granska kodkvalitet | `code-reviewer` | `/review` |
| Hitta säkerhetshål | `security-reviewer` | `/security` |
| Felsöka bugg | `debugger` | `/debug` |
| Skriva tester | `test-writer` | `/test` |
| Skriva dokumentation | `docs-writer` | - |
| Optimera prestanda | `performance-analyst` | - |
| Uppgradera versioner | `migrator` | `/migrate` |
| CI/CD och deploy | `devops` | `/deploy` |
| Analysera gammal kod | `legacy-analyst` | `/legacy` |

---

## Skills - Automatiskt aktiverade

Skills aktiveras automatiskt baserat på projekttyp:

| Projekttyp | Skills som används |
|------------|-------------------|
| React/Next.js | typescript, react, nextjs, testing |
| Node.js API | typescript, api-design, database, testing |
| Laravel | laravel, database, testing |
| Go backend | go, api-design, database |
| Rust | rust, testing |
| iOS | swift |
| Android | kotlin |
| Legacy PHP | legacy, database |
| DevOps | devops, git |
| Machine Learning | ml, python, data-science |
| Data Analysis | data-science, python |
| LLM/RAG Apps | llm-apps, python |
| Edge/Serverless | edge, typescript |
| Event-Driven | event-driven, database |

---

## Tips för effektiv delegering

### 1. Var specifik
```
# ❌ Vagt
Gör det bättre

# ✅ Specifikt
Refaktorera UserService för att minska komplexiteten,
extrahera email-validering till egen funktion
```

### 2. Ge kontext
```
# ❌ Utan kontext
Lägg till caching

# ✅ Med kontext
Lägg till Redis-caching för getUser() - vi har 10k requests/minut
och databasen är flaskhalsen
```

### 3. Dela upp stora uppgifter
```
# ❌ För stort
Bygg ett CRM-system

# ✅ Uppdelat
/architect CRM-system med kontakthantering
/estimate kontakthantering-modul
Implementera Contact model och CRUD API
```

### 4. Använd /estimate för okända uppgifter
```
/estimate migrera från REST till GraphQL

# Ger dig:
# - Komplexitet
# - Risker
# - Vad som behöver göras
```

### 5. Granska alltid innan commit
```
# Kör dessa innan varje PR:
/review
/security
/test (om tester saknas)
```

---

## Mappar och filer

```
~/.claude/
├── CLAUDE.md              # Dina personliga preferenser
├── settings.json          # Hooks och inställningar
├── README.md              # Denna fil
├── agents/
│   ├── architect.md
│   ├── code-reviewer.md
│   ├── debugger.md
│   ├── devops.md
│   ├── docs-writer.md
│   ├── legacy-analyst.md
│   ├── migrator.md
│   ├── performance-analyst.md
│   ├── security-reviewer.md
│   └── test-writer.md
├── commands/
│   ├── architect.md
│   ├── debug.md
│   ├── deploy.md
│   ├── estimate.md
│   ├── explain.md
│   ├── init.md
│   ├── legacy.md
│   ├── migrate.md
│   ├── new.md            # Projektmallar
│   ├── pr.md
│   ├── refactor.md
│   ├── review.md
│   ├── security.md
│   └── test.md
├── skills/
│   ├── api-design/
│   ├── database/
│   ├── data-science/
│   ├── devops/
│   ├── edge/             # Edge & Serverless
│   ├── event-driven/     # Kafka, WebSockets, CQRS
│   ├── git/
│   ├── go/
│   ├── kotlin/
│   ├── laravel/
│   ├── legacy/
│   ├── llm-apps/         # LangChain, RAG, AI agents
│   ├── ml/               # PyTorch, TensorFlow
│   ├── nextjs/
│   ├── python/
│   ├── react/
│   ├── rust/
│   ├── swift/
│   ├── testing/
│   └── typescript/
└── hooks/
    ├── post-write.sh      # Auto-formattering
    └── pre-bash.sh        # Säkerhetskontroll
```

---

## Felsökning

### Commands fungerar inte
```bash
# Starta om Claude Code
# Ctrl+C, sedan:
claude
```

### Hooks fungerar inte
```bash
# Kontrollera att de är körbara
chmod +x ~/.claude/hooks/*.sh
```

### Agent hittas inte
```bash
# Lista agents
ls ~/.claude/agents/

# Kontrollera syntax i agent-filen
cat ~/.claude/agents/agent-name.md
```

---

## Kom ihåg

1. **Nämn ALDRIG Claude/AI i commits eller PRs**
2. **Granska alltid genererad kod** - du är ansvarig
3. **Kör tester** innan du pushar
4. **Starta om Claude Code** efter konfigurationsändringar
