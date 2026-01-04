# Personliga Preferenser

## Språk & Kommunikation
- Föredrar svenska för kommunikation, engelska för kod och kommentarer
- Koncisa svar utan onödigt fluff
- Inga emojis om inte explicit begärt

## Kodstil

### Generellt
- 2 spaces indentation (inte tabs)
- Maximal radlängd: 100 tecken
- Föredrar explicita typer framför implicit typning
- Undvik kommentarer - skriv självdokumenterande kod istället

### Namngivning
- camelCase för variabler och funktioner
- PascalCase för klasser och komponenter
- SCREAMING_SNAKE_CASE för konstanter
- Beskrivande namn framför korta (getUserById > getUser)

### Git
- Conventional commits: `type(scope): description`
- Typer: feat, fix, docs, style, refactor, test, chore
- Branch-namn: `feature/`, `bugfix/`, `hotfix/`, `docs/`
- Squash commits före merge till main
- **VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI, eller liknande i commits, PR-beskrivningar eller kodkommentarer**

### Arbetsflöde - Git som versionshantering, inte filnamn
- **ALDRIG** parallella filer (script-v1.sh, script-alt.sh) - använd git istället
- Vid ny approach: commit → radera → implementera ny → testa
- Om ny approach misslyckas: `git checkout` för att återställa
- **Git worktrees för parallella experiment:**
  - `git worktree add ../projekt-experiment experiment/feature-x`
  - Subagenter kan jobba i olika worktrees samtidigt
  - Jämför resultat, behåll bästa, ta bort resten
  - `git worktree remove ../projekt-experiment`

## Verktyg & Preferenser
- pnpm > yarn > npm
- Vitest för testning (JavaScript/TypeScript)
- ESLint + Prettier för linting/formattering
- TypeScript strikt mode (för frontend)

## Backend-språkval (kontextbaserat)

Välj språk baserat på projektbehov, inte vana:

| Projekttyp | Förstaval | Alternativ |
|------------|-----------|------------|
| REST/GraphQL API | Go | Rust |
| Fullstack web | Go + React | Next.js |
| Realtime/WebSockets | Go | Rust |
| CLI-verktyg | Go | Rust |
| Serverless/Edge | TypeScript | Go |
| ML/AI backend | Python | Go |
| Laravel-projekt | PHP | - |

### Ramverksval per språk
- **Go:** stdlib > Chi > Echo
- **Rust:** Axum > Actix
- **TypeScript:** Hono > Elysia (på Bun)
- **Python:** FastAPI > Flask

### Undvik för ny backend
- Node.js med Express/Fastify (välj Go)
- Next.js API routes för ren backend (välj Go)

## Infrastruktur & Ekonomi
- **Open source först** - välj alltid OSS framför proprietärt när möjligt
- **Billig drift** - appar ska vara kostnadseffektiva att driva
- **Europeiska servrar** - prioritera EU/svenska alternativ (GDPR, latens)

### Undvik (om inte nödvändigt)
- AWS → Hetzner, Scaleway, GleSYS (svensk)
- Vercel Pro → Cloudflare Pages, Coolify, egen VPS
- MongoDB Atlas → självhostad PostgreSQL/SQLite

### Case-by-case
- Prisma OK för snabb prototyp, föredra Drizzle/Kysely för produktion

### Föredra
- **Databas:** PostgreSQL, SQLite, Turso
- **ORM:** Drizzle, Kysely, raw SQL
- **Hosting:** Hetzner, Scaleway, Cloudflare, GleSYS
- **Edge:** Cloudflare Workers
- **Container:** Coolify, Dokku (självhostad PaaS)
- **Object storage:** Cloudflare R2, MinIO

## Principer
- YAGNI - You Ain't Gonna Need It
- KISS - Keep It Simple, Stupid
- DRY - men duplicering är OK tills mönster uppstår (3+ gånger)
- Testa beteende, inte implementation
